import 'dart:async';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/chat/chat_room/add_person/add_person_screen.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room_manager.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/image/image_viewer.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/color/color.dart';
import '../../../utils/date_check.dart';
import '../../../utils/get_people_data.dart';
import '../../../utils/image/image_picker.dart';
import '../../../utils/platform_check.dart';
import '../../../utils/screen_movement.dart';
import '../../../utils/screen_size.dart';
import '../create_chat/creat_chat_data.dart';
import 'chat_room_data.dart';
import 'chat_room_dialog.dart';
import 'chat_room_widget.dart';

// 채팅방 화면
class ChatRoomScreen extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;
  final List<ChatPeopleClass> chatPeopleList;

  const ChatRoomScreen({super.key, required this.chatRoomSimpleData, required this.chatPeopleList});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late CollectionReference _collectionRef; // 실시간으로 데이터를 파이어베이스에서 받기 위한 변수
  final TextEditingController _textEditingController = TextEditingController();
  final _scrollController = ScrollController();
  late ChatRoomSimpleData _chatRoomSimpleData;
  late ChatRoomData _chatRoomData;
  late MessageDataClass _messageDataClass;
  late StreamSubscription _subscription;
  late FriendData _singleFriendData;
  String _title = '채팅방 타이틀';
  int _chatLength = 50;
  bool _selected = false;
  bool _discontinuedText = false;
  bool _keyBoardSelelted = false;
  bool _firstMessagebool = false;
  List<ChatPeopleClass> _chatPeopleList = [];
  bool _checkManager = false;
  bool _checkGroup = false;
  String _managerName = '';
  String _managerUid = '';

  // 메세지 프로필 사진과 시간을 연속적으로 나타내지 않기 위한 변수들
  String _messageBefore = '';
  String _message = '';
  String _messageAfter = '';
  String _uidBefore = '';
  String _uid = '';
  String _uidAfter = '';
  String _timeBefore = '';
  String _time = '';
  String _timeAfter = '';

  // ManagerDelegationDialog에서 setState를 사용하기 위한 함수
  void _refresh(String delegationUid) {
    setState(() {
      chatRoomDataList[_chatRoomData.chatRoomUid]?.chatRoomManager = delegationUid;
      _getManager();
    });
  }

  // 맴버가 변경되었을때 화면을 새로고침하기 위한 함수
  void _refreshMember() async {
    List<ChatPeopleClass> newchatPeopleList = await getPeopleData(_chatRoomSimpleData.chatRoomUid);
    setState(() {
      _chatPeopleList = newchatPeopleList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomSimpleData = widget.chatRoomSimpleData;
    _chatPeopleList = widget.chatPeopleList;
    _scrollController.addListener(_scrollListener);

    // DB의 특정 문서의 변경을 감지하기 위한 경로를 가지고 있는 변수
    _collectionRef = FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatRoomSimpleData.chatRoomUid)
        .collection('chat');

    _chatRoomData = chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!;
    _chatSystemCheck();
    _getManager();

    // 문서 변경이 감지되었을시 새로운 메세지를 추가하거나 새로운 맴버를 추가하는 기능
    _subscription = _collectionRef
        .orderBy('timestamp', descending: true)
        .limit(_chatLength)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added &&
            !messageMapData.containsKey(change.doc['messageid'])) {
          if (change.doc['messagetype'] == 'system') {
            _refreshMember();
          }
          setState(() {
            messageList.insert(
                0,
                MessageDataClass(
                    change.doc['messageid'],
                    change.doc['message'],
                    change.doc['useruid'],
                    change.doc['username'],
                    change.doc['userprofile'],
                    change.doc['messagetype'],
                    (change.doc['timestamp'] as Timestamp).toDate()));
          });
        }
      }
    });

    _setSingleFriendData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _subscription.cancel();
    super.dispose();
  }

  // 사용자가 해당 채팅방의 매니저인지 확인과 해당 채팅방이 그룹채팅방인지 1대1채팅방인지 구분하기 위한 함수
  void _chatSystemCheck() {
    if (_chatRoomSimpleData.chatRoomUid.length <= 8 &&
        chatRoomDataList[_chatRoomSimpleData.chatRoomUid]?.chatRoomManager == myData.myUID) {
      _checkManager = true;
    }
    if (_chatRoomSimpleData.chatRoomUid.length > 8) {
      _checkGroup = false;
    } else {
      _checkGroup = true;
    }
  }

  // 메세지 보내기 버튼을 눌렀을때 실행되는 함수이며
  // 메세지를 DB에 저장후 화면 새로고침과 텍스트필드의 데이터를 없에고 키보드를 사라지게 만드는 함수
  Future<void> _onFieldSubmitted() async {
    DateTime dateTime = DateTime.now();
    await setChatData(
        _chatRoomSimpleData.chatRoomUid, _textEditingController.text, 'text', dateTime);
    await setChatRealTimeData(_chatRoomData.peopleList, _chatRoomSimpleData.chatRoomUid,
        _textEditingController.text, dateTime);

    setState(() {});
    // 스크롤 위치를 맨 아래로 이동 시킴
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _textEditingController.text = '';
  }

  // 사용자가 채팅을 맨 위로 올렸을때 그것을 감지해서 실행하는 함수
  // 최초에 50개만 출력되는 메세지를 50개씩 더 추가해주는 기능
  void _scrollListener() async {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        messageList.length >= _chatLength) {
      EasyLoading.show();
      await getChatDataAfter(_chatRoomSimpleData.chatRoomUid);
      setState(() {
        _chatLength += 50;
      });
      EasyLoading.dismiss();
    }
  }

  // 채팅방을 나갈때 조건을 확인하는 함수 조건이 맞을시 leaveChatRoomDialog생성
  void leaveRoom() {
    if (_chatRoomData.chatRoomManager != myData.myUID) {
      leaveChatRoomDialog(context, _chatRoomData.chatRoomUid);
    } else if (!_checkGroup) {
      snackBarErrorMessage(context, '개인채팅방은 방을 떠날수 없습니다.');
    } else {
      snackBarErrorMessage(context, '매니저는 방을 떠날수 없습니다. 매니저를 위임해주고 다시 시도해 주세요');
    }
  }

  // 이미지와 비디오를 업로드 하기 위한 함수
  void _uploadMedia(ImageSource imageSource) async {
    XFile? imageFile;
    CroppedFile? croppedFile;
    String imgURL;
    DateTime dateTime = DateTime.now();
    imageFile = await getVideo(imageSource);
    bool isImageFile =
        imageFile != null && (imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.png'));
    if (isImageFile) {
      croppedFile = await cropImageInChatRoom(imageFile);
      imgURL = await uploadChatImage(croppedFile, _chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'image', dateTime);
        await setChatRealTimeData(
            _chatRoomData.peopleList, _chatRoomSimpleData.chatRoomUid, '이미지', dateTime);
      }
    } else {
      imgURL = await uploadChatVideo(imageFile!, _chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'video', dateTime);
        await setChatRealTimeData(
            _chatRoomData.peopleList, _chatRoomSimpleData.chatRoomUid, '비디오', dateTime);
      }
    }
    setState(() {});
  }

  // 여러 이미지를 채팅에 업로드 하기 위한 함수
  void _uploadMultipleMedia() async {
    List<XFile>? mediaFile;
    String imgURL;
    DateTime dateTime = DateTime.now();

    mediaFile = await getMultipleMedia(); // getImage 함수 비동기 호출

    for (var file in mediaFile!) {
      imgURL = await uploadChatMultiImage(file, _chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'image', dateTime);
        await setChatRealTimeData(
            _chatRoomData.peopleList, _chatRoomSimpleData.chatRoomUid, '이미지', dateTime);
      }
    }
    setState(() {});
  }

  // 여러 이미지를 채팅에 업로드 하기 위한 함수
  void _uploadMultipleMediaV2() async {
    List<XFile>? mediaFile;
    String imgURL;
    bool isImageFile;
    DateTime dateTime = DateTime.now();

    mediaFile = await getMultipleMediaV2(); // getImage 함수 비동기 호출

    for (var file in mediaFile!) {
      isImageFile = (file.path.endsWith('.jpg') || file.path.endsWith('.png'));

      if (isImageFile) {
        imgURL = await uploadChatMultiImageV2(file, _chatRoomSimpleData.chatRoomUid, 'image');
        if (imgURL.isNotEmpty) {
          await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'image', dateTime);
          await setChatRealTimeData(
              _chatRoomData.peopleList, _chatRoomSimpleData.chatRoomUid, '이미지', dateTime);
        }
      } else {
        imgURL = await uploadChatMultiImageV2(file, _chatRoomSimpleData.chatRoomUid, 'video');
        if (imgURL.isNotEmpty) {
          await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'video', dateTime);
          await setChatRealTimeData(
              _chatRoomData.peopleList, _chatRoomSimpleData.chatRoomUid, '비디오', dateTime);
        }
      }
    }
    setState(() {});
  }

  // 해당 채팅방의 매니저의 데이터를 가져오기 위한 함수
  void _getManager() {
    for (var item in _chatPeopleList) {
      if (_chatRoomData.chatRoomManager == item.uid) {
        _managerName = item.name;
        _managerUid = item.uid;
      }
    }
  }

  // 화면의 타이틀을 설정하는 함수
  // 개인채팅방일경우 상대방의 이름을 기본설젇으로 등록함
  void _setSingleFriendData() {
    String getTitle = chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!.chatRoomName;
    if (_chatRoomSimpleData.chatRoomCustomName.isNotEmpty) {
      _title = _chatRoomSimpleData.chatRoomCustomName;
    } else if (getTitle == '1대1 채팅방') {
      for (var item in _chatPeopleList) {
        if (myData.myUID != item.uid) {
          _title = item.name;
          _singleFriendData = friendList[friendListUidKey[item.uid]]!;
        }
      }
    } else {
      _title = getTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                screenMovementLeftToRight(const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              otherAccountsPictures: [
                GestureDetector(
                  onTap: () {
                    if (_chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageViewer(imageURL: _chatRoomSimpleData.chatRoomCustomProfile),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: _chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty
                        ? NetworkImage(_chatRoomSimpleData.chatRoomCustomProfile) as ImageProvider
                        : null,
                    child: _chatRoomSimpleData.chatRoomCustomProfile.isEmpty
                        ? Icon(
                            Icons.image,
                            size: screenSize.getHeightPerSize(3.5),
                            color: mainColor,
                          )
                        : null,
                  ),
                ),
              ],
              currentAccountPicture: GestureDetector(
                onTap: () {
                  if (_chatRoomData.chatRoomProfile.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewer(imageURL: _chatRoomData.chatRoomProfile),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundImage: _chatRoomData.chatRoomProfile.isNotEmpty
                      ? NetworkImage(_chatRoomData.chatRoomProfile) as ImageProvider
                      : _chatRoomData.chatRoomUid.length > 8 &&
                              _singleFriendData.friendProfile.isNotEmpty
                          ? NetworkImage(_singleFriendData.friendProfile)
                          : null,
                  child: _chatRoomData.chatRoomProfile.isEmpty &&
                          _chatRoomData.chatRoomUid.length < 8 &&
                          _singleFriendData.friendProfile.isEmpty
                      ? Icon(
                          Icons.image,
                          size: screenSize.getHeightPerSize(6),
                          color: mainColor,
                        )
                      : null,
                ),
              ),
              accountName: _chatRoomSimpleData.chatRoomUid.length <= 8
                  ? Text('${_chatRoomData.chatRoomName} (${_chatRoomData.chatRoomUid})')
                  : Text(_title),
              accountEmail:
                  _chatRoomSimpleData.chatRoomUid.length <= 8 ? Text('매니저 : $_managerName') : null,
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: ListTile(
                    leading: Icon(Icons.people),
                    title: Text('채팅방 인원'),
                  ),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(15),
                  child: Visibility(
                    visible: _checkGroup,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPersonScreen(
                              chatRoomSimpleData: _chatRoomSimpleData,
                              chatPeopleList: _chatPeopleList,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                height: screenSize.getHeightPerSize(6) * _chatPeopleList.length,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.5),
                    bottom: BorderSide(width: 0.5),
                  ),
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _chatPeopleList.length,
                  itemBuilder: (context, index) {
                    bool checkManager = false;
                    if (_chatRoomData.chatRoomUid.length <= 8 &&
                        _managerUid == _chatPeopleList[index].uid) {
                      checkManager = true;
                    } else {
                      checkManager = false;
                    }
                    String name = _chatPeopleList[index].name;
                    String proFile = _chatPeopleList[index].profile;

                    return SizedBox(
                      height: screenSize.getHeightPerSize(6),
                      child: ListTile(
                        leading: proFile.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                proFile,
                              ))
                            : const Icon(Icons.person),
                        title: Row(
                          children: [
                            Text(name ?? '에러'),
                            checkManager
                                ? const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  )
                                : const Text('')
                          ],
                        ),
                        onTap: () {
                          goDetailInfomation(context, _chatPeopleList[index].uid,
                              _chatPeopleList[index].name, _chatPeopleList[index].profile);
                        },
                        onLongPress: () {
                          //내가 이 방의 매니저일경우 혹은 단체채팅방일 경우에만 실행
                          if (_chatRoomData.chatRoomUid.length <= 8 &&
                              _managerUid == myData.myUID) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ManagerDelegationDialog(
                                  chatRoomUid: _chatRoomData.chatRoomUid,
                                  delegationUid: _chatPeopleList[index].uid,
                                  refresh: _refresh,
                                );
                              },
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            // 해당 채팅방의 매니저일경우에만 나타나는 리스트 타일
            Visibility(
              visible: _checkManager,
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('채팅방 설정 (매니저 전용)'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingRoomManager(
                        chatRoomSimpleData: _chatRoomSimpleData,
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('채팅방 설정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingRoom(
                      chatRoomSimpleData: _chatRoomSimpleData,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                '채팅방 나가기',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                leaveRoom();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: chatRoomColorMap['BackgroundColor'],
              child: Align(
                alignment: Alignment.topCenter,
                child: StreamBuilder(
                    stream: _collectionRef.snapshots(),
                    builder: (context, snapshot) {
                      return ListView.separated(
                        shrinkWrap: true,
                        reverse: true,
                        controller: _scrollController,
                        itemCount: messageList.length,
                        itemBuilder: (context, index) {
                          // 제일 첫번째 메세지가 아닐경우 전에 사용한 메세지 데이터를 Before데이터에 넣는 작업
                          if (index != 0) {
                            _messageBefore = _message;
                            _uidBefore = _uid;
                            _timeBefore = _time;
                          }

                          // 첫번째 메세지이거나 제일 마지막 메세지일경우 messageList의 index위치에 있는 데이터를 가져오는 작업
                          // 둘다 아닐경우 After데이터들을 현재 메세지 데이터에 넣는 작업
                          if (index == 0 || index == messageList.length - 1) {
                            _messageDataClass = messageList[index];
                            _message = _messageDataClass.message;
                            _uid = _messageDataClass.userUid;
                            _time = dateTimeConvert(_messageDataClass.timestamp);
                          } else {
                            _message = _messageAfter;
                            _uid = _uidAfter;
                            _time = _timeAfter;
                          }

                          // 마지막 메세지가 아닐경우 messageList에 index + 1 위치의 메세지 데이터를 가져오는 작업
                          // 가져온 데이터를 After데이터에 넣는 작업
                          if (index != messageList.length - 1) {
                            _messageDataClass = messageList[index + 1];
                            _messageAfter = _messageDataClass.message;
                            _uidAfter = _messageDataClass.userUid;
                            _timeAfter = dateTimeConvert(_messageDataClass.timestamp);
                          }

                          // 동일한 인물이 보낸 메세지 중 같은 시간에 보낸 메세지들을 확인하기 위한 작업
                          if (index > 0 && _uid == _uidBefore && _time == _timeBefore) {
                            _discontinuedText = false;
                          } else {
                            _discontinuedText = true;
                          }

                          // 동일한 인물이 보낸 메세지 중 같은 시간에 보낸 메세지들중 가장 첫번째로 보낸 메세지를 찾기 위한 작업
                          if (index < messageList.length - 1 &&
                              _uid == _uidAfter &&
                              _time == _timeAfter) {
                            _firstMessagebool = false;
                          } else {
                            _firstMessagebool = true;
                          }

                          // 구별한 데이터를 메세지 위젯에 등록
                          return messageWidget(context, screenSize, messageList[index],
                              _discontinuedText, _firstMessagebool);
                        },
                        // 아이템 간의 간격 조절
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: screenSize.getHeightPerSize(0.5),
                          );
                        },
                      );
                    }),
              ),
            ),
          ),
          Container(
            height: screenSize.getHeightPerSize(5),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenSize.getWidthPerSize(10),
                  child: IconButton(
                      style: IconButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        if (!_selected) {
                          setState(() {
                            _selected = true;
                          });
                        } else {
                          setState(() {
                            _selected = false;
                          });
                        }
                        ;
                      },
                      icon: const Icon(Icons.add)),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onTapOutside: (event) {
                      _keyBoardSelelted = false;
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onTap: () {
                      _keyBoardSelelted = true;
                      _selected = false;
                    },
                  ),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(10),
                  child: IconButton(
                    style: IconButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () async {
                      if (_textEditingController.text.isNotEmpty) {
                        _onFieldSubmitted();
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: mainColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 사진이나 동영상등 각종 기능이 있는 컨테이너이며 나타날때 사라질때 애니메이션효과를 생성
          AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            height: _selected ? screenSize.getHeightPerSize(8) : 0,
            width: screenSize.getWidthSize(),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            onPressed: () {
                              _uploadMedia(ImageSource.camera);
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              size: screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        '카메라',
                        style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            onPressed: () {
                              _uploadMedia(ImageSource.gallery);
                            },
                            icon: Icon(
                              Icons.image,
                              size: screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        '갤러리',
                        style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            onPressed: () {
                              _uploadMultipleMediaV2();
                            },
                            icon: Icon(
                              Icons.photo_library,
                              size: screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        '다중 이미지',
                        style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 사용하는 기기가 ios를 사용중이면 ui 맨 아래쪽에 여백을 생성하여 하단이 잘리지 않게 하는 작업
          Visibility(
            visible: !(getPlatform() != 'IOS' || _keyBoardSelelted),
            child: Container(
              height: screenSize.getHeightPerSize(3),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenSize.getWidthPerSize(10),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(10),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

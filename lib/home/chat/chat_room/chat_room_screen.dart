import 'dart:async';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/chat/chat_room/add_person/add_person_screen.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room_manager.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room_widget.dart';
import 'package:chattingapp/home/friend/request/friend_request_screen.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/data_refresh.dart';
import 'package:chattingapp/utils/image_viewer.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/color.dart';
import '../../../utils/date_check.dart';
import '../../../utils/get_people_data.dart';
import '../../../utils/image_picker.dart';
import '../../../utils/platform_check.dart';
import '../../../utils/screen_movement.dart';
import '../../../utils/screen_size.dart';
import '../create_chat/creat_chat_data.dart';
import 'chat_room_data.dart';
import 'chat_room_widget.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;
  final List<ChatPeopleClass> chatPeopleList;

  const ChatRoomScreen({super.key, required this.chatRoomSimpleData, required this.chatPeopleList});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late ScreenSize _screenSize;
  late CollectionReference _collectionRef;
  final TextEditingController _textEditingController = TextEditingController();
  bool _selected = false;
  late ChatRoomSimpleData _chatRoomSimpleData;
  late ChatRoomData _chatRoomData;
  final _scrollController = ScrollController();
  bool _discontinuedText = false;
  bool _keyBoardSelelted = false;
  bool _firstMessagebool = false;

  late MessageDataClass _messageDataClass;
  String _messageBefore = "";
  String _message = "";
  String _messageAfter = "";

  String _uidBefore = "";
  String _uid = "";
  String _uidAfter = "";

  String _timeBefore = "";
  String _time = "";
  String _timeAfter = "";

  late StreamSubscription _subscription;

  List<ChatPeopleClass> _chatPeopleList = [];

  bool _checkManager = false;
  bool _checkGroup = false;

  String _managerName = '';
  String _managerUid = '';

  void _refresh(String delegationUid) {
    setState(() {
      chatRoomDataList[_chatRoomData.chatRoomUid]?.chatRoomManager = delegationUid;
      _getManager();
    });
  }

  void refreshMember() async {
    setState(() async {
      _chatPeopleList = await getPeopleData(_chatRoomSimpleData.chatRoomUid);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomSimpleData = widget.chatRoomSimpleData;
    _chatPeopleList = widget.chatPeopleList;
    _scrollController.addListener(_scrollListener);
    _collectionRef = FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatRoomSimpleData.chatRoomUid)
        .collection('chat');

    _chatRoomData = chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!;
    _chatSystemCheck();
    _getManager();

    _subscription = _collectionRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added &&
            !messageMapData.containsKey(change.doc['messageid'])) {
          if (change.doc['messagetype'] == 'system') {
            refreshMember();
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _subscription.cancel();
    super.dispose();
  }

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

  Future<void> onFieldSubmitted() async {
    await setChatData(_chatRoomSimpleData.chatRoomUid, _textEditingController.text, "text");
    setState(() {});
    // 스크롤 위치를 맨 아래로 이동 시킴
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _textEditingController.text = '';
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
      print('맨 위에 도달했습니다.');
      // 여기에 특정 기능을 추가하세요.
    }
  }

  void leaveRoom() {
    if (_chatRoomData.chatRoomManager != myData.myUID) {
      leaveChatRoomDialog(context, _chatRoomData.chatRoomUid);
    } else if (!_checkGroup) {
      snackBarErrorMessage(context, '개인채팅방은 방을 떠날수 없습니다.');
    } else {
      snackBarErrorMessage(context, '매니저는 방을 떠날수 없습니다. 매니저를 위임해주고 다시 시도해 주세요');
    }
  }

  void uploadMedia(ImageSource imageSource) async {
    XFile? imageFile;
    CroppedFile? croppedFile;
    String imgURL;
    imageFile = await getVideo(imageSource); // getImage 함수 비동기 호출
    bool isImageFile =
        imageFile != null && (imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.png'));
    if (isImageFile) {
      croppedFile = await cropImage(imageFile);
      imgURL = await uploadChatImage(croppedFile, _chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, "image");
      }
    } else {
      imgURL = await uploadChatVideo(imageFile!, _chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, "video");
      }
    }
    setState(() {});
  }

  // 이미지를 채팅에 업로드 하기 위한 함수
  void uploadMultipleMedia() async {
    List<XFile>? mediaFile;
    String imgURL;

    mediaFile = await getMultipleMedia(); // getImage 함수 비동기 호출

    for (var file in mediaFile!) {
      imgURL = await uploadChatMultiImage(file, _chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'image');
      }
    }
    setState(() {});
  }

  // 이미지를 채팅에 업로드 하기 위한 함수
  void uploadMultipleMediaV2() async {
    List<XFile>? mediaFile;
    String imgURL;
    bool isImageFile;

    mediaFile = await getMultipleMediaV2(); // getImage 함수 비동기 호출

    for (var file in mediaFile!) {
      isImageFile = (file.path.endsWith('.jpg') || file.path.endsWith('.png'));

      if (isImageFile) {
        imgURL = await uploadChatMultiImageV2(file, _chatRoomSimpleData.chatRoomUid, 'image');
        if (imgURL.isNotEmpty) {
          await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'image');
        }
      } else {
        imgURL = await uploadChatMultiImageV2(file, _chatRoomSimpleData.chatRoomUid, 'video');
        if (imgURL.isNotEmpty) {
          await setChatData(_chatRoomSimpleData.chatRoomUid, imgURL, 'video');
        }
      }
    }
    setState(() {});
  }

  void _getManager() {
    for (var item in _chatPeopleList) {
      if (_chatRoomData.chatRoomManager == item.uid) {
        _managerName = item.name;
        _managerUid = item.uid;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_chatRoomSimpleData.chatRoomCustomName.isNotEmpty
            ? _chatRoomSimpleData.chatRoomCustomName
            : chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!.chatRoomName),
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
                              builder: (context) => ImageViewer(
                                  imageURL: _chatRoomSimpleData.chatRoomCustomProfile)));
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: _chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty
                        ? NetworkImage(_chatRoomSimpleData.chatRoomCustomProfile) as ImageProvider
                        : null,
                    child: _chatRoomSimpleData.chatRoomCustomProfile.isEmpty
                        ? Icon(
                            Icons.image,
                            size: _screenSize.getHeightPerSize(3.5),
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
                            builder: (context) =>
                                ImageViewer(imageURL: _chatRoomData.chatRoomProfile)));
                  }
                },
                child: CircleAvatar(
                  backgroundImage: _chatRoomData.chatRoomProfile.isNotEmpty
                      ? NetworkImage(_chatRoomData.chatRoomProfile) as ImageProvider
                      : null,
                  child: _chatRoomData.chatRoomProfile.isEmpty
                      ? Icon(
                          Icons.image,
                          size: _screenSize.getHeightPerSize(6),
                          color: mainColor,
                        )
                      : null,
                ),
              ),
              accountName: _chatRoomSimpleData.chatRoomUid.length <= 8
                  ? Text('${_chatRoomData.chatRoomName} (${_chatRoomData.chatRoomUid})')
                  : const Text('1대1 채팅방'),
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
                  width: _screenSize.getWidthPerSize(15),
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
                                    )),
                          );
                        },
                        icon: const Icon(Icons.add)),
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                height: _screenSize.getHeightPerSize(6) * _chatPeopleList.length,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5))),
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
                    String? name = _chatPeopleList[index].name;
                    String proFile = _chatPeopleList[index].profile;

                    return SizedBox(
                      height: _screenSize.getHeightPerSize(6),
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
                                : Text('')
                          ],
                        ),
                        onTap: () {
                          goDetailInfomation(context, _chatPeopleList[index].uid,
                              _chatPeopleList[index].name, _chatPeopleList[index].profile);
                        },
                        onLongPress: () {
                          //내가 이 방의 매니저일경우, 단체채팅방일경우에만 실행
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
            //j6OwaXM0iuSqFJubNrqt26Mezs32
            //xoIlnIxqaPeYlDM9Os2tDbtlb933
            Visibility(
              visible: _checkManager,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: const Text('채팅방 설정 (매니저 전용)'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingRoomManager(
                                chatRoomSimpleData: _chatRoomSimpleData,
                              )));
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('채팅방 설정'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingRoom(
                              chatRoomSimpleData: _chatRoomSimpleData,
                            )));
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
                          if (index != 0) {
                            _messageBefore = _message;
                            _uidBefore = _uid;
                            _timeBefore = _time;
                          }

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

                          return messageWidget(context, _screenSize, messageList[index],
                              _discontinuedText, _firstMessagebool);
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                              height: _screenSize.getHeightPerSize(0.5)); // 아이템 간의 간격 조절
                        },
                      );
                    }),
              ),
            ),
          ),
          Container(
            height: _screenSize.getHeightPerSize(5),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _screenSize.getWidthPerSize(10),
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
                  width: _screenSize.getWidthPerSize(80),
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      //contentPadding: EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 설정
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
                  width: _screenSize.getWidthPerSize(10),
                  child: IconButton(
                      style: IconButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () async {
                        if (_textEditingController.text.isNotEmpty) {
                          onFieldSubmitted();
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: mainColor,
                      )),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            height: _selected ? _screenSize.getHeightPerSize(8) : 0,
            width: _screenSize.getWidthSize(),
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
                              uploadMedia(ImageSource.camera);
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              size: _screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "카메라",
                        style: TextStyle(fontSize: _screenSize.getHeightPerSize(1.5)),
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
                              uploadMedia(ImageSource.gallery);
                            },
                            icon: Icon(
                              Icons.image,
                              size: _screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "갤러리",
                        style: TextStyle(fontSize: _screenSize.getHeightPerSize(1.5)),
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
                              uploadMultipleMediaV2();
                            },
                            icon: Icon(
                              Icons.photo_library,
                              size: _screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "다중 이미지",
                        style: TextStyle(fontSize: _screenSize.getHeightPerSize(1.5)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !(getPlatform() != "IOS" || _keyBoardSelelted),
            child: Container(
              height: _screenSize.getHeightPerSize(3),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _screenSize.getWidthPerSize(10),
                  ),
                  SizedBox(
                    width: _screenSize.getWidthPerSize(80),
                  ),
                  SizedBox(
                    width: _screenSize.getWidthPerSize(10),
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

import 'dart:async';
import 'package:chattingapp/home/chat/chat_data.dart';
import 'package:chattingapp/home/chat/chat_room/add_person/add_person_screen.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room_manager.dart';
import 'package:chattingapp/home/friend/request/friend_request_screen.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/image_viewer.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/color.dart';
import '../../../utils/date_check.dart';
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
  late ScreenSize screenSize;
  late CollectionReference _collectionRef;
  TextEditingController textEditingController = TextEditingController();
  bool selected = false;
  late ChatRoomSimpleData chatRoomSimpleData;
  late ChatRoomData _chatRoomData;
  final scrollController = ScrollController();
  bool discontinuedText = false;
  bool keyBoardSelelted = false;
  bool firstCheck = false;
  bool firstMessagebool = false;
  String firstMessageString = "";

  late MessageDataClass messageDataClass;
  String messageBefore = "";
  String message = "";
  String messageAfter = "";

  String uidBefore = "";
  String uid = "";
  String uidAfter = "";

  String timeBefore = "";
  String time = "";
  String timeAfter = "";

  late StreamSubscription _subscription;

  late String chattingRoomUid;

  List<ChatPeopleClass> chatPeopleList = [];

  bool _checkManager = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatRoomSimpleData = widget.chatRoomSimpleData;
    chatPeopleList = widget.chatPeopleList;
    scrollController.addListener(_scrollListener);
    _collectionRef = FirebaseFirestore.instance
        .collection('chat')
        .doc(chatRoomSimpleData.chatRoomUid)
        .collection('chat');

    _chatRoomData = chatRoomDataList[chatRoomSimpleData.chatRoomUid]!;
    managerCheck();

    _subscription = _collectionRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added &&
            !messageMapData.containsKey(change.doc['messageid'])) {
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
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    _subscription.cancel();
    super.dispose();
  }

  void managerCheck() {
    if (chatRoomSimpleData.chatRoomUid.length <= 8 &&
        chatRoomDataList[chatRoomSimpleData.chatRoomUid]?.chatRoomManager == myData.myUID) {
      _checkManager = true;
    }
  }

  Future<void> onFieldSubmitted() async {
    await setChatData(chatRoomSimpleData.chatRoomUid, textEditingController.text, "text");
    setState(() {});
    // 스크롤 위치를 맨 아래로 이동 시킴
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    textEditingController.text = '';
  }

  void _scrollListener() {
    if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
      print('맨 위에 도달했습니다.');
      // 여기에 특정 기능을 추가하세요.
    }
  }

  // 이미지를 채팅에 업로드 하기 위한 함수
  // void uploadImage(ImageSource imageSource) async {
  //   XFile? imageFile;
  //   CroppedFile? croppedFile;
  //   String imgURL;
  //
  //   imageFile = await getImage(imageSource); // getImage 함수 비동기 호출
  //
  //   if (imageFile != null) {
  //     croppedFile = await cropImage(imageFile);
  //     imgURL = await uploadChatImage(croppedFile, chatRoomSimpleData.chatRoomUid);
  //     if (imgURL.isNotEmpty) {
  //       await setChatData(chatRoomSimpleData.chatRoomUid, imgURL, "image");
  //     }
  //   }
  //   setState(() {});
  // }

  void uploadMedia(ImageSource imageSource) async {
    XFile? imageFile;
    CroppedFile? croppedFile;
    String imgURL;
    imageFile = await getVideo(imageSource); // getImage 함수 비동기 호출
    bool isImageFile =
        imageFile != null && (imageFile.path.endsWith('.jpg') || imageFile.path.endsWith('.png'));
    if (isImageFile) {
      croppedFile = await cropImage(imageFile);
      imgURL = await uploadChatImage(croppedFile, chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(chatRoomSimpleData.chatRoomUid, imgURL, "image");
      }
    } else {
      imgURL = await uploadChatVideo(imageFile!, chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(chatRoomSimpleData.chatRoomUid, imgURL, "video");
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
      imgURL = await uploadChatMultiImage(file, chatRoomSimpleData.chatRoomUid);
      if (imgURL.isNotEmpty) {
        await setChatData(chatRoomSimpleData.chatRoomUid, imgURL, 'image');
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
        imgURL = await uploadChatMultiImageV2(file, chatRoomSimpleData.chatRoomUid, 'image');
        if (imgURL.isNotEmpty) {
          await setChatData(chatRoomSimpleData.chatRoomUid, imgURL, 'image');
        }
      } else {
        imgURL = await uploadChatMultiImageV2(file, chatRoomSimpleData.chatRoomUid, 'video');
        if (imgURL.isNotEmpty) {
          await setChatData(chatRoomSimpleData.chatRoomUid, imgURL, 'video');
        }
      }
    }
    setState(() {});
  }

  String _getManager() {
    String managerName = '';
    for (var item in chatPeopleList) {
      if (_chatRoomData.chatRoomManager == item.uid) {
        managerName = item.name;
      }
    }
    return managerName;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(chatRoomSimpleData.chatRoomCustomName.isNotEmpty
            ? chatRoomSimpleData.chatRoomCustomName
            : chatRoomDataList[chatRoomSimpleData.chatRoomUid]!.chatRoomName),
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
                    if (chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImageViewer(imageURL: chatRoomSimpleData.chatRoomCustomProfile)));
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty
                        ? NetworkImage(chatRoomSimpleData.chatRoomCustomProfile) as ImageProvider
                        : null,
                    child: chatRoomSimpleData.chatRoomCustomProfile.isEmpty
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
                          size: screenSize.getHeightPerSize(6),
                          color: mainColor,
                        )
                      : null,
                ),
              ),
              accountName: chatRoomSimpleData.chatRoomUid.length <= 8
                  ? Text('${_chatRoomData.chatRoomName} (${_chatRoomData.chatRoomUid})')
                  : const Text('1대1 채팅방'),
              accountEmail: chatRoomSimpleData.chatRoomUid.length <= 8
                  ? Text('매니저 : ${_getManager()}')
                  : null,
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
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddPersonScreen(
                                    chatRoomSimpleData: chatRoomSimpleData,
                                    chatPeopleList: chatPeopleList,
                                  )),
                        );
                      },
                      icon: const Icon(Icons.add)),
                )
              ],
            ),
            Expanded(
              child: Container(
                height: screenSize.getHeightPerSize(6) * chatPeopleList.length,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5))),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: chatPeopleList.length,
                  itemBuilder: (context, index) {
                    String? name = chatPeopleList[index].name;
                    String proFile = chatPeopleList[index].profile;

                    return SizedBox(
                      height: screenSize.getHeightPerSize(6),
                      child: ListTile(
                        leading: proFile.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                proFile,
                              ))
                            : const Icon(Icons.person),
                        title: Text(name ?? '에러'),
                        onTap: () {
                          goDetailInfomation(context, chatPeopleList[index].uid,
                              chatPeopleList[index].name, chatPeopleList[index].profile);
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
                                chatRoomSimpleData: chatRoomSimpleData,
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
                              chatRoomSimpleData: chatRoomSimpleData,
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
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: mainBackgroundColor,
              child: Align(
                alignment: Alignment.topCenter,
                child: StreamBuilder(
                    stream: _collectionRef.snapshots(),
                    builder: (context, snapshot) {
                      return ListView.separated(
                        shrinkWrap: true,
                        reverse: true,
                        controller: scrollController,
                        itemCount: messageList.length,
                        itemBuilder: (context, index) {
                          if (index != 0) {
                            messageBefore = message;
                            uidBefore = uid;
                            timeBefore = time;
                          }

                          if (index == 0 || index == messageList.length - 1) {
                            messageDataClass = messageList[index];
                            message = messageDataClass.message;
                            uid = messageDataClass.userUid;
                            time = dateTimeConvert(messageDataClass.timestamp);
                          } else {
                            message = messageAfter;
                            uid = uidAfter;
                            time = timeAfter;
                          }

                          if (index != messageList.length - 1) {
                            messageDataClass = messageList[index + 1];
                            messageAfter = messageDataClass.message;
                            uidAfter = messageDataClass.userUid;
                            timeAfter = dateTimeConvert(messageDataClass.timestamp);
                          }

                          // 동일한 인물이 보낸 메세지 중 같은 시간에 보낸 메세지들을 확인하기 위한 작업
                          if (index > 0 && uid == uidBefore && time == timeBefore) {
                            discontinuedText = false;
                          } else {
                            discontinuedText = true;
                          }

                          // 동일한 인물이 보낸 메세지 중 같은 시간에 보낸 메세지들중 가장 첫번째로 보낸 메세지를 찾기 위한 작업
                          if (index < messageList.length - 1 &&
                              uid == uidAfter &&
                              time == timeAfter) {
                            firstMessagebool = false;
                          } else {
                            firstMessagebool = true;
                          }

                          return messageWidget(context, screenSize, messageList[index],
                              discontinuedText, firstMessagebool);
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: screenSize.getHeightPerSize(0.5)); // 아이템 간의 간격 조절
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
                        if (!selected) {
                          setState(() {
                            selected = true;
                          });
                        } else {
                          setState(() {
                            selected = false;
                          });
                        }
                        ;
                      },
                      icon: const Icon(Icons.add)),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      //contentPadding: EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 설정
                    ),
                    onTapOutside: (event) {
                      keyBoardSelelted = false;
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onTap: () {
                      keyBoardSelelted = true;
                      selected = false;
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
                        if (textEditingController.text.isNotEmpty) {
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
            height: selected ? screenSize.getHeightPerSize(8) : 0,
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
                              uploadMedia(ImageSource.camera);
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              size: screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "카메라",
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
                              uploadMedia(ImageSource.gallery);
                            },
                            icon: Icon(
                              Icons.image,
                              size: screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "갤러리",
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
                              uploadMultipleMediaV2();
                            },
                            icon: Icon(
                              Icons.photo_library,
                              size: screenSize.getHeightPerSize(4),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "다중 이미지",
                        style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !(getPlatform() != "IOS" || keyBoardSelelted),
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

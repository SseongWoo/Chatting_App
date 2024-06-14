import 'dart:async';
import 'package:chattingapp/home/chat/chat_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
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
import '../../../utils/screen_size.dart';
import 'chat_room_data.dart';
import 'chat_room_widget.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;

  const ChatRoomScreen({super.key, required this.chatRoomSimpleData});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late ScreenSize screenSize;
  late CollectionReference _collectionRef;
  TextEditingController textEditingController = TextEditingController();
  bool selected = false;
  late ChatRoomSimpleData chatRoomSimpleData;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatRoomSimpleData = widget.chatRoomSimpleData;
    scrollController.addListener(_scrollListener);
    _collectionRef = FirebaseFirestore.instance
        .collection('chat')
        .doc(chatRoomSimpleData.chatRoomUid)
        .collection('chat');

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

  Future<void> onFieldSubmitted() async {
    await setChatData(chatRoomSimpleData.chatRoomUid, textEditingController.text, "text");
    //await getChatData(chatRoomSimpleData.chatRoomUid);
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

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(chatRoomSimpleData.chatRoomCustomName),
        // actions: [
        //   IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        // ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageViewer(imageURL: myData.myProfile)));
                },
                child: CircleAvatar(
                  //backgroundImage: AssetImage('assets/bunny.gif'),
                  backgroundImage: NetworkImage(myData.myProfile),
                ),
              ),
              accountEmail: Text(myData.myEmail),
              accountName: Text(myData.myNickName),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            const ListTile(
              leading: Icon(Icons.people),
              title: Text('채팅방 인원'),
            ),
            Container(
              height: screenSize.getHeightPerSize(6) *
                  chatRoomDataList[chatRoomSimpleData.chatRoomUid]!.peopleList.length,
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5))),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: chatRoomDataList[chatRoomSimpleData.chatRoomUid]!.peopleList.length,
                itemBuilder: (context, index) {
                  String uid = chatRoomDataList[chatRoomSimpleData.chatRoomUid]!
                      .peopleList[chatRoomDataSequence[index]]!;
                  String name = friendListUidKey[uid]!;

                  return SizedBox(
                    height: screenSize.getHeightPerSize(6),
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(name),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('버튼 1'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('버튼2'),
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

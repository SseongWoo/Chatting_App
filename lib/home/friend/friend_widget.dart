import 'package:animate_do/animate_do.dart';
import 'package:chattingapp/home/friend/detail/detail_change_screen.dart';
import 'package:chattingapp/home/friend/detail/detail_information_screen.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../utils/color.dart';
import '../../utils/get_people_data.dart';
import '../../utils/image_viewer.dart';
import '../../utils/screen_movement.dart';
import '../../utils/screen_size.dart';
import '../chat/chat_data.dart';
import '../chat/chat_room/chat_room_data.dart';
import '../chat/chat_room/chat_room_screen.dart';
import '../chat/create_chat/creat_chat_data.dart';
import 'friend_data.dart';

class FriendWidget extends StatefulWidget {
  final FriendData friendData;

  const FriendWidget({super.key, required this.friendData});

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  late ScreenSize screenSize;
  bool selected = false;
  late FriendData friendData;
  late ChatRoomSimpleData chatRoomSimpleData;
  bool dataChaek = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friendData = widget.friendData;
    if (chatRoomList.containsKey(friendData.friendInherentChatRoom)) {
      chatRoomSimpleData = chatRoomList[friendData.friendInherentChatRoom]!;
    } else {
      dataChaek = false;
    }
  }

  void moveChatRoom() async {
    EasyLoading.show();
    await getChatData(chatRoomSimpleData.chatRoomUid);
    List<ChatPeopleClass> chatPeople = await getPeopleData(chatRoomSimpleData.chatRoomUid);
    EasyLoading.dismiss();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
                  chatRoomSimpleData: chatRoomSimpleData,
                  chatPeopleList: chatPeople,
                )));
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    String name;
    if (friendData.friendCustomName.isNotEmpty) {
      name = friendData.friendCustomName;
    } else {
      name = friendData.friendNickName;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selected = !selected;
            });
          },
          onLongPress: () {
            friendWidgetDialog(context, screenSize, friendData);
          },
          child: Container(
            height: screenSize.getHeightPerSize(8),
            width: screenSize.getWidthSize(),
            color: Colors.white,
            child: Column(children: [
              SizedBox(
                height: screenSize.getHeightPerSize(8),
                child: Row(
                  children: [
                    SizedBox(
                      width: screenSize.getWidthPerSize(2),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImageViewer(imageURL: friendData.friendProfile)),
                        );
                      },
                      child: SizedBox(
                        height: screenSize.getHeightPerSize(6),
                        width: screenSize.getHeightPerSize(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            friendData.friendProfile,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenSize.getWidthPerSize(2),
                    ),
                    SizedBox(
                      height: screenSize.getHeightPerSize(6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: FadeInRight(
            animate: selected,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: Colors.blue,
              height: screenSize.getHeightPerSize(8),
              width: screenSize.getWidthPerSize(16),
              child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: const BeveledRectangleBorder(),
                  ),
                  onPressed: () async {
                    if (dataChaek) {
                      moveChatRoom();
                    } else {
                      snackBarErrorMessage(context, '작업을 수행하는데 문제가 발생하였습니다.\n친구를 삭제하였다가 다시 추가해주세요');
                    }
                  },
                  icon: const Icon(
                    Icons.chat,
                    color: Colors.white,
                  )),
            ),
          ),
        )
      ],
    );
  }
}

void friendWidgetDialog(BuildContext context, ScreenSize screenSize, FriendData friendData) {
  String name;
  if (friendData.friendCustomName.isNotEmpty) {
    name = "${friendData.friendCustomName}(${friendData.friendNickName})";
  } else {
    name = friendData.friendNickName;
  }

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: screenSize.getHeightPerSize(1),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenSize.getWidthPerSize(3), screenSize.getHeightPerSize(1.5), 0, 0),
              child: Text(
                name,
                style: TextStyle(fontSize: screenSize.getHeightPerSize(2.5)),
              ),
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(1),
            ),
            SizedBox(
                height: screenSize.getHeightPerSize(4.5),
                width: double.infinity,
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: const BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailInformationScreen(
                                    friendData: friendData,
                                  )));
                    },
                    child: Text(
                      "상세 정보",
                      style: TextStyle(
                          color: Colors.black, fontSize: screenSize.getHeightPerSize(1.5)),
                    ))),
            SizedBox(
                height: screenSize.getHeightPerSize(4.5),
                width: double.infinity,
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: const BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailChangeScreen(
                                    friendData: friendData,
                                  )));
                    },
                    child: Text(
                      "정보 수정",
                      style: TextStyle(
                          color: Colors.black, fontSize: screenSize.getHeightPerSize(1.5)),
                    ))),
            SizedBox(
                height: screenSize.getHeightPerSize(4.5),
                width: double.infinity,
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: const BeveledRectangleBorder(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      friendDeleteDialog(context, friendData);
                    },
                    child: Text(
                      "친구 삭제",
                      style:
                          TextStyle(color: Colors.red, fontSize: screenSize.getHeightPerSize(1.5)),
                    ))),
            SizedBox(
              height: screenSize.getHeightPerSize(1.5),
            )
          ],
        ),
      );
    },
  );
}

void friendDeleteDialog(BuildContext getContext, FriendData friendData) {
  showDialog(
    context: getContext,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("친구 추가"),
        content: const Text("정말로 삭제하시겠습니까?"),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                EasyLoading.show();
                await deleteFriend(context, friendData.friendUID);
                EasyLoading.dismiss();
                Navigator.of(context).pushAndRemoveUntil(
                  screenMovementZero(const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("삭제")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소")),
        ],
      );
    },
  );
}

void friendCustomNickNameDialog(BuildContext getContext, FriendData friendData) {
  TextEditingController controller = TextEditingController();
  if (friendData.friendCustomName.isNotEmpty) {
    controller.text = friendData.friendCustomName;
  }

  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("이름 설정"),
        content: TextField(
            maxLength: 8,
            controller: controller,
            keyboardType: TextInputType.text,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            }),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                EasyLoading.show();
                await updateFriendName(friendData, controller.text);
                EasyLoading.dismiss();
              },
              child: const Text("변경")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소")),
        ],
      );
    },
  );
}

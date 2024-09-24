import 'package:chattingapp/home/friend/detail/detail_change_screen.dart';
import 'package:chattingapp/home/friend/detail/detail_information_screen.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../utils/get_people_data.dart';
import '../../utils/image/image_viewer.dart';
import '../../utils/screen_movement.dart';
import '../../utils/screen_size.dart';
import '../chat/chat_list_data.dart';
import '../chat/chat_room/chat_room_data.dart';
import '../chat/chat_room/chat_room_screen.dart';
import '../chat/create_chat/creat_chat_data.dart';
import 'friend_data.dart';

// 친구 리스트 위젯
class FriendWidget extends StatefulWidget {
  final FriendData friendData;

  const FriendWidget({super.key, required this.friendData});

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  late FriendData friendData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friendData = widget.friendData;
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
            friendWidgetDialog(context, screenSize, friendData);
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
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // 이미지 로드 완료
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder:
                                (BuildContext context, Object error, StackTrace? stackTrace) {
                              return const Center(
                                child: Text('이미지 로딩 실패'),
                              );
                            },
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
      ],
    );
  }
}

// FriendWidget을 길게 눌렀을때 나타나는 다이얼로그 상세정보, 정보수정, 친구삭제 메뉴로 구성
void friendWidgetDialog(BuildContext context, ScreenSize screenSize, FriendData friendData) {
  String name;
  late ChatRoomSimpleData chatRoomSimpleData;
  bool selected = false;
  bool dataChaek = true;
  if (friendData.friendCustomName.isNotEmpty) {
    name = '${friendData.friendCustomName}(${friendData.friendNickName})';
  } else {
    name = friendData.friendNickName;
  }

  // 해당 친구와 1대1채팅방이 있는지 확인하는 작업
  if (chatRoomList.containsKey(friendData.friendInherentChatRoom)) {
    chatRoomSimpleData = chatRoomList[friendData.friendInherentChatRoom]!;
  } else {
    dataChaek = false;
  }

  // 채팅방으로 이동하는 함수
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

  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(name),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              if (dataChaek) {
                moveChatRoom();
              } else {
                snackBarErrorMessage(context, '작업을 수행하는데 문제가 발생하였습니다.\n친구를 삭제하였다가 다시 추가해주세요');
              }
            },
            child: const Text('채팅하기'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailInformationScreen(
                    friendData: friendData,
                  ),
                ),
              );
            },
            child: const Text('상세정보'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailChangeScreen(
                    friendData: friendData,
                  ),
                ),
              );
            },
            child: const Text('정보수정'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              friendDeleteDialog(context, friendData);
            },
            child: const Text('친구삭제'),
          ),
        ],
      );
    },
  );
}

// 친구 삭제 다이얼로그
void friendDeleteDialog(BuildContext getContext, FriendData friendData) {
  showDialog(
    context: getContext,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('친구 추가'),
        content: const Text('정말로 삭제하시겠습니까?'),
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
            child: const Text('삭제'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
        ],
      );
    },
  );
}

// 친구 커스텀 닉네임을 설정하는 다이얼로그
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
        title: const Text('이름 설정'),
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
              child: const Text('변경')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소')),
        ],
      );
    },
  );
}

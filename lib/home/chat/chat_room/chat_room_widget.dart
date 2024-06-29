import 'package:chattingapp/home/chat/chat_room/chat_room_data.dart';
import 'package:chattingapp/home/friend/detail/detail_information_screen.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/date_check.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../utils/data_refresh.dart';
import '../../../utils/image_viewer.dart';
import '../../home_screen.dart';
import '../../information/information_data.dart';

void goDetailInfomation(BuildContext context, String userUid, String userName, String userProfile) {
  FriendData friendData;

  if (userUid != myData.myUID && friendList.containsKey(friendListUidKey[userUid]!)) {
    friendData = friendList[friendListUidKey[userUid]]!;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailInformationScreen(friendData: friendData)),
    );
  } else if (userUid == myData.myUID) {
    friendData = FriendData(
        myData.myUID, myData.myEmail, myData.myNickName, myData.myProfile, "", "", "", [], false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailInformationScreen(friendData: friendData)),
    );
  } else {
    friendData = FriendData(userUid, "", userName, userProfile, "", "", "", [], false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailInformationScreen(friendData: friendData)),
    );
  }
}

Widget messageWidget(BuildContext context, ScreenSize screenSize, MessageDataClass messageDataClass,
    bool visCheck, bool firstMessage) {
  switch (messageDataClass.messageType) {
    case 'text':
      if (messageDataClass.userUid == myData.myUID) {
        return messageTextType1(screenSize, messageDataClass, visCheck);
      } else {
        return messageTextType2(context, screenSize, messageDataClass, firstMessage, visCheck);
      }

    case 'image':
      if (messageDataClass.userUid == myData.myUID) {
        return messageImageType1(context, screenSize, messageDataClass, visCheck);
      } else {
        return messageImageType2(context, screenSize, messageDataClass, firstMessage, visCheck);
      }

    case 'video':
      if (messageDataClass.userUid == myData.myUID) {
        return messageVideoType1(context, screenSize, messageDataClass, visCheck);
      } else {
        return messageVideoType2(context, screenSize, messageDataClass, firstMessage, visCheck);
      }
    case 'system':
      return systemMessage(screenSize, messageDataClass);
    default:
      return Container();
  }
}

Widget messageTextType2(BuildContext context, ScreenSize screenSize,
    MessageDataClass messageDataClass, bool firstMessage, bool visTime) {
  String name = getName(messageDataClass);
  String imagePath = 'assets/images/blank_profile.png';

  return Container(
    width: screenSize.getWidthSize(),
    padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: screenSize.getWidthPerSize(10),
          width: screenSize.getWidthPerSize(10),
          child: Visibility(
            visible: firstMessage,
            child: GestureDetector(
              onTap: () {
                goDetailInfomation(context, messageDataClass.messageUid, messageDataClass.userName,
                    messageDataClass.userProfile);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: messageDataClass.userProfile.isNotEmpty
                    ? Image.network(
                        messageDataClass.userProfile,
                      )
                    : Image.asset(
                        imagePath,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenSize.getWidthPerSize(1.5),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: firstMessage,
              child: Text(
                name,
                style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.getWidthPerSize(60), // 최대 너비
                    maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
                  ),
                  child: Container(
                    padding: EdgeInsets.all(screenSize.getWidthPerSize(2)),
                    decoration: BoxDecoration(
                        color: chatRoomColorMap['FriendChatColor'],
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      messageDataClass.message,
                      style: TextStyle(
                          fontSize: screenSize.getHeightPerSize(1.6),
                          color: chatRoomColorMap['FriendChatStringColor']),
                      maxLines: null, // 줄바꿈을 허용
                      overflow: TextOverflow.visible, // 텍스트가 넘어갈 경우 줄바꿈
                    ),
                  ),
                ),
                Visibility(
                  visible: visTime,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        screenSize.getWidthPerSize(1), 0, 0, screenSize.getWidthPerSize(1)),
                    child: Text(
                      dateTimeConvert(messageDataClass.timestamp),
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget messageTextType1(ScreenSize screenSize, MessageDataClass messageDataClass, bool visTime) {
  String time = dateTimeConvert(messageDataClass.timestamp);
  return Container(
    width: screenSize.getWidthSize(),
    padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: visTime,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                0, 0, screenSize.getWidthPerSize(1), screenSize.getWidthPerSize(1)),
            child: Text(
              time,
              style: TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.getWidthPerSize(70), // 최대 너비
            maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
          ),
          child: Container(
            padding: EdgeInsets.all(screenSize.getWidthPerSize(2)),
            decoration: BoxDecoration(
                color: chatRoomColorMap['MyChatColor'], borderRadius: BorderRadius.circular(10)),
            child: Text(
              messageDataClass.message,
              style: TextStyle(
                  fontSize: screenSize.getHeightPerSize(1.6),
                  color: chatRoomColorMap['MyChatStringColor']),
              maxLines: null, // 줄바꿈을 허용
              overflow: TextOverflow.visible, // 텍스트가 넘어갈 경우 줄바꿈
            ),
          ),
        ),
      ],
    ),
  );
}

Widget messageImageType1(
    BuildContext context, ScreenSize screenSize, MessageDataClass messageDataClass, bool visTime) {
  return Container(
    width: screenSize.getWidthSize(),
    padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: visTime,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                0, 0, screenSize.getWidthPerSize(1), screenSize.getWidthPerSize(1)),
            child: Text(
              dateTimeConvert(messageDataClass.timestamp),
              style: TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.getWidthPerSize(60), // 최대 너비
            maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageViewer(imageURL: messageDataClass.message)),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                messageDataClass.message,
                loadingBuilder:
                    (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // 이미지가 로딩 완료된 경우
                  }
                  return SizedBox(
                    height: screenSize.getHeightPerSize(15),
                    width: screenSize.getWidthPerSize(60),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget messageImageType2(BuildContext context, ScreenSize screenSize,
    MessageDataClass messageDataClass, bool firstMessage, bool visTime) {
  String name = getName(messageDataClass);
  String imagePath = 'assets/images/blank_profile.png';

  return Container(
    width: screenSize.getWidthSize(),
    padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: screenSize.getWidthPerSize(10),
          width: screenSize.getWidthPerSize(10),
          child: Visibility(
            visible: firstMessage,
            child: GestureDetector(
              onTap: () {
                print("따로 다이얼로그를 만들어서 UI제공예정");
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: messageDataClass.userProfile.isNotEmpty
                    ? Image.network(
                        messageDataClass.userProfile,
                      )
                    : Image.asset(
                        imagePath,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenSize.getWidthPerSize(1.5),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: firstMessage,
              child: Text(
                name,
                style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.getWidthPerSize(60), // 최대 너비
                    maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageViewer(imageURL: messageDataClass.message)),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        messageDataClass.message,
                        loadingBuilder:
                            (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // 이미지가 로딩 완료된 경우
                          }
                          return SizedBox(
                            height: screenSize.getHeightPerSize(15),
                            width: screenSize.getWidthPerSize(60),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: mainColor,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder:
                            (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: visTime,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        screenSize.getWidthPerSize(1), 0, 0, screenSize.getWidthPerSize(1)),
                    child: Text(
                      dateTimeConvert(messageDataClass.timestamp),
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget messageVideoType1(
    BuildContext context, ScreenSize screenSize, MessageDataClass messageDataClass, bool visTime) {
  return Container(
    width: screenSize.getWidthSize(),
    padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: visTime,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                0, 0, screenSize.getWidthPerSize(1), screenSize.getWidthPerSize(1)),
            child: Text(
              dateTimeConvert(messageDataClass.timestamp),
              style: TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.getWidthPerSize(60), // 최대 너비
            maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
          ),
          child: Container(
            padding: EdgeInsets.all(screenSize.getWidthPerSize(2)),
            decoration: BoxDecoration(
                color: chatRoomColorMap['MyChatColor'], borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.file_download_rounded)),
                Text(
                  '다운로드 버튼을 클릭하여\n동영상 파일을 다운로드하세요',
                  style: TextStyle(
                      fontSize: screenSize.getHeightPerSize(1.5),
                      color: chatRoomColorMap['MyChatStringColor']),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget messageVideoType2(BuildContext context, ScreenSize screenSize,
    MessageDataClass messageDataClass, bool firstMessage, bool visTime) {
  String name = getName(messageDataClass);
  String imagePath = 'assets/images/blank_profile.png';

  return Container(
    width: screenSize.getWidthSize(),
    padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: screenSize.getWidthPerSize(10),
          width: screenSize.getWidthPerSize(10),
          child: Visibility(
            visible: firstMessage,
            child: GestureDetector(
              onTap: () {
                print("따로 다이얼로그를 만들어서 UI제공예정");
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: messageDataClass.userProfile.isNotEmpty
                    ? Image.network(
                        messageDataClass.userProfile,
                      )
                    : Image.asset(
                        imagePath,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenSize.getWidthPerSize(1.5),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: firstMessage,
              child: Text(
                name,
                style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.getWidthPerSize(60), // 최대 너비
                    maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
                  ),
                  child: Container(
                    padding: EdgeInsets.all(screenSize.getWidthPerSize(2)),
                    decoration: BoxDecoration(
                        color: chatRoomColorMap['FriendChatColor'],
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '다운로드 버튼을 클릭하여\n동영상 파일을 다운로드하세요',
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(1.5),
                              color: chatRoomColorMap['FriendChatStringColor']),
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.file_download_rounded)),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: visTime,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        screenSize.getWidthPerSize(1), 0, 0, screenSize.getWidthPerSize(1)),
                    child: Text(
                      dateTimeConvert(messageDataClass.timestamp),
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget systemMessage(ScreenSize screenSize, MessageDataClass messageDataClass) {
  return Container(
      width: screenSize.getWidthSize(),
      margin:
          EdgeInsets.fromLTRB(screenSize.getWidthPerSize(5), 0, screenSize.getWidthPerSize(5), 0),
      child: Text(
        messageDataClass.message,
        textAlign: TextAlign.center,
      ));
}

void leaveChatRoomDialog(BuildContext getContext, String roomUid) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("채팅방 삭제"),
        content: const Text('정말로 채팅방을 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                EasyLoading.show();
                await leaveChatRoom(roomUid);
                await refreshData();
                EasyLoading.dismiss();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              )),
        ],
      );
    },
  );
}

class ManagerDelegationDialog extends StatelessWidget {
  final String chatRoomUid;
  final String delegationUid;
  final Function(String) refresh;
  const ManagerDelegationDialog(
      {super.key, required this.chatRoomUid, required this.delegationUid, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("매니저 위임"),
      content: const Text('매니저를 위임하시겠습니까?'),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.black),
            )),
        TextButton(
            onPressed: () async {
              EasyLoading.show();
              await managerDelegation(chatRoomUid, delegationUid);
              refresh(delegationUid);
              EasyLoading.dismiss();
              Navigator.of(context).pop();
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.black),
            )),
      ],
    );
  }
}

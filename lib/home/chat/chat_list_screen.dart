import 'package:flutter/material.dart';

import '../../utils/screen_size.dart';
import 'chat_list_data.dart';
import 'chat_list_widget.dart';

class ChatScreen extends StatefulWidget {
  final bool groupChaeck;
  const ChatScreen({super.key, required this.groupChaeck});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScreenSize _screenSize;
  late bool _groupCheck; // true일경우 그룹 채팅 리스트 화면, false일경우 개인 채팅 리스트 화면
  late List<String> _chatRoomSequence = [];
  String text = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 개인채팅인지 그룹채팅인지 확인하고 리스트뷰에 적용하는 작업
    _groupCheck = widget.groupChaeck;
    _chatRoomSequence.clear();
    if (_groupCheck) {
      _chatRoomSequence = groupChatRoomSequence;
      text = '그룹';
    } else {
      _chatRoomSequence = chatRoomSequence;
      text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
        body: _chatRoomSequence.isNotEmpty
            ? ListView.separated(
                itemCount: _chatRoomSequence.length,
                itemBuilder: (context, index) {
                  return ChatListWidget(
                    chatRoomSimpleData: chatRoomList[_chatRoomSequence[index]]!,
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: _screenSize.getHeightPerSize(1)); // 아이템 간의 간격 조절
                },
              )
            : Center(child: Text("현재 참여 중인 $text채팅방이 없습니다.")));
  }
}

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   late ScreenSize _screenSize;
//
//   @override
//   Widget build(BuildContext context) {
//     _screenSize = ScreenSize(MediaQuery.of(context).size);
//     return Scaffold(
//         body: chatRoomSequence.isNotEmpty
//             ? ListView.separated(
//           itemCount: chatRoomSequence.length,
//           itemBuilder: (context, index) {
//             return ChatListWidget(
//               chatRoomSimpleData: chatRoomList[chatRoomSequence[index]]!,
//             );
//           },
//           separatorBuilder: (context, index) {
//             return SizedBox(height: _screenSize.getHeightPerSize(1)); // 아이템 간의 간격 조절
//           },
//         )
//             : Center(child: Text("현재 참여 중인 채팅방이 없습니다.")));
//   }
// }
//
// class GroupChatScreen extends StatefulWidget {
//   const GroupChatScreen({super.key});
//
//   @override
//   State<GroupChatScreen> createState() => _GroupChatScreen();
// }
//
// class _GroupChatScreen extends State<GroupChatScreen> {
//   late ScreenSize _screenSize;
//
//   @override
//   Widget build(BuildContext context) {
//     _screenSize = ScreenSize(MediaQuery.of(context).size);
//     return Scaffold(
//         body: groupChatRoomSequence.isNotEmpty
//             ? ListView.separated(
//           itemCount: groupChatRoomSequence.length,
//           itemBuilder: (context, index) {
//             return ChatListWidget(
//               chatRoomSimpleData: chatRoomList[groupChatRoomSequence[index]]!,
//             );
//           },
//           separatorBuilder: (context, index) {
//             return SizedBox(height: _screenSize.getHeightPerSize(1)); // 아이템 간의 간격 조절
//           },
//         )
//             : Center(child: Text("현재 참여 중인 채팅방이 없습니다.")));
//   }
// }
//

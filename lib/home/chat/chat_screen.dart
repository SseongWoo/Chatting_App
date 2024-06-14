import 'package:flutter/material.dart';

import '../../utils/screen_size.dart';
import 'chat_data.dart';
import 'chat_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScreenSize screenSize;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
        body: chatRoomSequence.isNotEmpty
            ? ListView.separated(
                itemCount: chatRoomSequence.length,
                itemBuilder: (context, index) {
                  return ChatListWidget(
                    index: index,
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: screenSize.getHeightPerSize(1)); // 아이템 간의 간격 조절
                },
              )
            : Center(child: Text("현재 참여 중인 채팅방이 없습니다.")));
  }
}

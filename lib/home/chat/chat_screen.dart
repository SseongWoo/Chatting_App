import 'package:flutter/material.dart';

import '../../utils/screen_size.dart';
import 'chat_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
        body: ListView.separated(
          itemCount: 3,
          itemBuilder: (context, index) {
            return ChatListWidget();
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: screenSize.getHeightPerSize(1)); // 아이템 간의 간격 조절
          },
        )
    );
  }
}

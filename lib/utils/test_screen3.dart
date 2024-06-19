import 'package:chattingapp/home/chat/chat_room/chat_room_widget.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';

class TestScreen3 extends StatefulWidget {
  const TestScreen3({super.key});

  @override
  State<TestScreen3> createState() => _TestScreen3State();
}

class _TestScreen3State extends State<TestScreen3> {
  late ScreenSize screenSize;
  List<String> person = [
    '홍길동',
    '홍길동',
    '홍길동',
    '홍길동',
    '홍길동',
    '홍길동',
  ];

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: mainBackgroundColor,
      appBar: AppBar(),
      body: addPersonMessage(screenSize, person),
    );
  }
}

Widget addPersonMessage(ScreenSize screenSize, List<String> addPersonList) {
  String message = '${myData.myNickName}님이';

  for (int i = 0; i < addPersonList.length; i++) {
    if (i == addPersonList.length - 1) {
      message = '$message ${addPersonList[i]}님을 초대하였습니다.';
    } else {
      message = '$message ${addPersonList[i]}님,';
    }
  }

  return Container(
      width: screenSize.getWidthSize(),
      color: Colors.blue,
      margin:
          EdgeInsets.fromLTRB(screenSize.getWidthPerSize(5), 0, screenSize.getWidthPerSize(5), 0),
      child: Text(
        message,
        textAlign: TextAlign.center,
      ));
}

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

  for (var item in addPersonList) {
    message = '$message $item님';
  }
  message = '$message을 초대하였습니다.';

  return Container(
      height: screenSize.getHeightPerSize(6),
      width: screenSize.getWidthSize(),
      color: Colors.blue,
      child: Center(
          child: Text(
        message,
        textAlign: TextAlign.center,
      )));
}

import 'package:chattingapp/home/chat/chat_room/chat_room_widget.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';

class TestScreen3 extends StatefulWidget {
  const TestScreen3({super.key});

  @override
  State<TestScreen3> createState() => _TestScreen3State();
}

class _TestScreen3State extends State<TestScreen3> {
  late ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
        backgroundColor: mainBackgroundColor,
        appBar: AppBar(),
        body: Container(
          height: screenSize.getHeightPerSize(8),
          width: screenSize.getWidthPerSize(60),
          color: Colors.blue,
          child: Row(
            children: [
              Container(
                width: screenSize.getWidthPerSize(15),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.file_download_rounded,
                  size: screenSize.getHeightPerSize(5),
                ),
              ),
              Expanded(child: Text("다운로드 버튼을 클릭하여 동영상 파일을 다운로드하세요"))
            ],
          ),
        ));
  }
}

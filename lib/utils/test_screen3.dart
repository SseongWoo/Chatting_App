import 'package:chattingapp/home/friend/request/friend_request_screen.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/platform_check.dart';
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
      appBar: AppBar(),
      body: getPlatform() == "AOS" ? aosWidget(screenSize) : iosWidget(screenSize),
    );
  }
}

Widget aosWidget(ScreenSize screenSize){
  return Column(
    children: [
      Expanded(
        child: Container(
          color: mainColor,
        ),
      ),
      Container(
        height: screenSize.getHeightPerSize(5),
        color: Colors.yellow,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.purple,
              height: screenSize.getHeightPerSize(5),
              width: screenSize.getWidthPerSize(10),
              child: IconButton(onPressed: () {

              }, icon: Icon(Icons.add)),
            ),
            Container(
              color: Colors.grey,
              height: screenSize.getHeightPerSize(5),
              width: screenSize.getWidthPerSize(80),
            ),
            Container(
              color: Colors.purple,
              height: screenSize.getHeightPerSize(5),
              width: screenSize.getWidthPerSize(10),
              child: IconButton(onPressed: () {

              }, icon: Icon(Icons.add)),
            ),
          ],
        ),
      )
    ],
  );
}

Widget iosWidget(ScreenSize screenSize){
  return Column(
    children: [
      Expanded(
        child: Container(
          color: mainColor,
        ),
      ),
      Container(
        height: screenSize.getHeightPerSize(8),
        color: Colors.yellow,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.purple,
              width: screenSize.getWidthPerSize(10),
              child: IconButton(onPressed: () {

              }, icon: Icon(Icons.add)),
            ),
            Container(
              color: Colors.grey,
              width: screenSize.getWidthPerSize(80),
            ),
            Container(
              color: Colors.purple,
              width: screenSize.getWidthPerSize(10),
              child: IconButton(onPressed: () {

              }, icon: Icon(Icons.add)),
            ),
          ],
        ),
      )
    ],
  );
}

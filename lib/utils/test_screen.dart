//import 'package:chattingapp/home/chat/chat_room/chat_room_screen.dart';
import 'package:chattingapp/home/friend/category/category_data.dart';
import 'package:chattingapp/home/friend/friend_widget.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/image_viewer.dart';
import 'package:chattingapp/utils/platform_check.dart';
import 'package:chattingapp/utils/screen_movement.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/test_screen2.dart';
import 'package:chattingapp/utils/test_screen3.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../home/friend/friend_data.dart';
import '../login/login_screen.dart';
import '../login/registration/authentication.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late ScreenSize screenSize;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text("로그아웃")),
            ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //     builder: (context) => ChatRoomScreen()));
                },
                child: Text("테스트 버튼 1 (채팅창 스크린)")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen3()));
                },
                child: Text("테스트 버튼 2 (메세지 위젯)")),
            ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).pushAndRemoveUntil(screenMovementLeftToRight(const TestScreen3()),
                  //       (Route<dynamic> route) => false,
                  // );
                },
                child: Text("테스트 버튼 3")),
            SizedBox(
              height: screenSize.getHeightPerSize(10),
            ),
            Container(
              color: subBackgroundColor2,
            )
          ],
        ),
      ),
    );
  }
}

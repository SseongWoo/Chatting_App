import 'package:chattingapp/home/information/delete_user_information/delete_user_information_screen.dart';
import 'package:chattingapp/home/information/update_information/update_information_screen.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../home/information/information_data.dart';
import '../login/registration/authentication.dart';
import 'color_picker.dart';

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
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const ChatRoomChangeColorScreen()),
                  // );
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DeleteUserInformationScreen()));
                },
                child: Text("테스트 버튼 2 (메세지 위젯)")),
            ElevatedButton(
                onPressed: () {
                  snackBarErrorMessage(context, '그룹채팅방중 사용자가 방장인 그룹채팅방이 있습니다. 방장을 위임해주고 다시 시도해주세요');
                  // Navigator.of(context).pushAndRemoveUntil(screenMovementLeftToRight(const TestScreen3()),
                  //       (Route<dynamic> route) => false,
                  // );
                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return StatefulColorPickerDialog(
                  //       type: 'MyChatColor',
                  //     );
                  //   },
                  // );
                },
                child: Text("테스트 버튼 3")),
            ElevatedButton(
                onPressed: () async {
                  // EasyLoading.show();
                  // await setSharedPreferencese();
                  // EasyLoading.dismiss();
                },
                child: Text("set")),
            ElevatedButton(
                onPressed: () async {
                  EasyLoading.show();
                  await getSharedPreferencese();
                  EasyLoading.dismiss();
                },
                child: Text("get")),
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

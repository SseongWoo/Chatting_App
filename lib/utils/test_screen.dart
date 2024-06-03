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
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: Text("로그아웃")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => TestScreen3()));
                },
                child: Text("테스트 버튼 1 (채팅창 스크린)")),
            ElevatedButton(
                onPressed: () {
                  print(getPlatform());
                },
                child: Text("테스트 버튼 2")),
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
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customButton: Icon(
                    Icons.menu,
                    size: 46,
                    color: mainBoldColor,
                  ),
                  items: [
                    ...MenuItems.firstItems.map(
                          (item) => DropdownMenuItem<MenuItem>(
                        value: item,
                        child: MenuItems.buildItem(item),
                      ),
                    ),
                    const DropdownMenuItem<Divider>(enabled: false, child: Divider()),
                    ...MenuItems.secondItems.map(
                          (item) => DropdownMenuItem<MenuItem>(
                        value: item,
                        child: MenuItems.buildItem(item),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    MenuItems.onChanged(context, value! as MenuItem);
                  },
                  dropdownStyleData: DropdownStyleData(
                    width: 160,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    offset: const Offset(0, 8),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    customHeights: [
                      ...List<double>.filled(MenuItems.firstItems.length, 48),
                      8,
                      ...List<double>.filled(MenuItems.secondItems.length, 48),
                    ],
                    padding: const EdgeInsets.only(left: 16, right: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.text,
  });

  final String text;
}
abstract class MenuItems {
  static const List<MenuItem> firstItems = [changeName, changeSequence, lockSequence];
  static const List<MenuItem> secondItems = [delete];

  static const changeName = MenuItem(text: "이름 수정");
  static const changeSequence = MenuItem(text: "순서 변경");
  static const lockSequence = MenuItem(text: "순서 고정?");
  static const delete = MenuItem(text: "삭제");

  static Widget buildItem(MenuItem item) {
    return Text(
      item.text,
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }

  static void onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.changeName:
      //Do something
        break;
      case MenuItems.changeSequence:
      //Do something
        break;
      case MenuItems.lockSequence:
      //Do something
        break;
      case MenuItems.delete:
      //Do something
        break;
    }
  }
}

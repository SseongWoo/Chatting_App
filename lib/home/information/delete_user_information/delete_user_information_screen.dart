import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../login/registration/authentication.dart';
import '../information_data.dart';

class DeleteUserInformationScreen extends StatefulWidget {
  const DeleteUserInformationScreen({super.key});

  @override
  State<DeleteUserInformationScreen> createState() => _DeleteUserInformationScreenState();
}

class _DeleteUserInformationScreenState extends State<DeleteUserInformationScreen> {
  late ScreenSize _screenSize;
  bool _isChecked = false;
  bool _errorPW = false;
  final TextEditingController _passWordEditingController = TextEditingController();

  void _startDeleteUser() async {
    EasyLoading.show();
    if (await signIn(myData.myEmail, _passWordEditingController.text)) {
      await deleteUser(context);
    } else {
      setState(() {
        _errorPW = true;
      });
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 탈퇴'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '정말 탈퇴하시겠습니까?',
              style: TextStyle(fontSize: _screenSize.getHeightPerSize(2.5)),
            ),
            SizedBox(
              height: _screenSize.getHeightPerSize(3),
            ),
            Text(
              '탈퇴하시면 모든 데이터가 삭제되어 복구할수가 없습니다.\n회원 탈퇴를 계속 하시려면 아래 비밀번호 입력과\n동의 버튼을 눌러 주세요.',
              style: TextStyle(fontSize: _screenSize.getHeightPerSize(1.7)),
            ),
            SizedBox(
              height: _screenSize.getHeightPerSize(2),
            ),
            SizedBox(
              width: _screenSize.getWidthPerSize(80),
              child: TextField(
                controller: _passWordEditingController,
                decoration:
                    const InputDecoration(border: OutlineInputBorder(), hintText: '비밀번호를 입력해 주세요'),
                obscureText: true,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onTap: () {},
              ),
            ),
            Visibility(
                visible: _errorPW,
                child: SizedBox(
                  width: _screenSize.getWidthPerSize(80),
                  child: const Text(
                    '비밀번호를 잘못 입력했습니다.',
                    style: TextStyle(color: Colors.red),
                  ),
                )),
            SizedBox(
              width: _screenSize.getWidthPerSize(80),
              child: Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: mainColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _isChecked = !_isChecked;
                        });
                      },
                      child: const Text('회원 탈퇴에 동의합니다.')),
                ],
              ),
            ),
            SizedBox(
              height: _screenSize.getHeightPerSize(1),
            ),
            ElevatedButton(
                onPressed: _isChecked && _passWordEditingController.text.isNotEmpty
                    ? () {
                        if (_isChecked) {
                          _startDeleteUser();
                        }
                      }
                    : null,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  '회원 탈퇴',
                  style: TextStyle(color: Colors.black),
                )),
            SizedBox(
              height: _screenSize.getHeightPerSize(6),
            ),
          ],
        ),
      ),
    );
  }
}

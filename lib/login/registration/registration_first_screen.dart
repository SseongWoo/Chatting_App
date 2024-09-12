import 'package:chattingapp/login/registration/registration_dialog.dart';
import 'package:chattingapp/login/registration/registration_second_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../utils/screen_size.dart';
import 'authentication.dart';
import 'dart:io';

// 계정 생성 첫번째 화면
class RegistrationFirstScreen extends StatefulWidget {
  const RegistrationFirstScreen({super.key});

  @override
  State<RegistrationFirstScreen> createState() => _RegistrationFirstScreenState();
}

class _RegistrationFirstScreenState extends State<RegistrationFirstScreen> {
  late ScreenSize _screenSize;
  final _registrationFirstFormKey = GlobalKey<FormState>();
  final TextEditingController _controllerID = TextEditingController();
  final TextEditingController _controllerPW = TextEditingController();
  final TextEditingController _controllerPWCheck = TextEditingController();
  final FocusNode _focusNodeID = FocusNode();
  final FocusNode _focusNodePW = FocusNode();
  final FocusNode _focusNodePWCheck = FocusNode();

  @override
  dispose() {
    _controllerID.dispose();
    _controllerPW.dispose();
    super.dispose();
  }

  // 생성할 이메일이 이상이 없을 경우 해당 이메일에 이메일을 발송후 다음화면으로 넘어가는 함수
  void _checkAccount() async {
    EasyLoading.show();
    if (_registrationFirstFormKey.currentState!.validate()) {
      String message = await createUserWithEmailAndPassword(_controllerID.text, _controllerPW.text);
      if (mounted) {
        if (message == '') {
          EasyLoading.dismiss();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RegistrationSecondScreen(
                      email: _controllerID.text,
                      password: _controllerPW.text,
                    )),
          );
        } else {
          firebaseAuthError(context, message);
        }
      }
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ),
      body: SizedBox(
        height: _screenSize.getHeightSize(),
        child: Stack(
          children: [
            Form(
              key: _registrationFirstFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: _screenSize.getHeightPerSize(5),
                    ),
                    SizedBox(
                      width: _screenSize.getWidthPerSize(80),
                      child: Text(
                        '회원정보를\n입력해주세요',
                        style: TextStyle(fontSize: _screenSize.getHeightPerSize(4)),
                      ),
                    ),
                    SizedBox(
                      height: _screenSize.getHeightPerSize(5),
                    ),
                    SizedBox(
                      height: _screenSize.getHeightPerSize(12),
                      width: _screenSize.getWidthPerSize(80),
                      child: TextFormField(
                        focusNode: _focusNodeID,
                        controller: _controllerID,
                        decoration:
                            const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) return '이메일을 입력해 주세요';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return '이메일 형식이 아닙니다.';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: _screenSize.getHeightPerSize(12),
                      width: _screenSize.getWidthPerSize(80),
                      child: TextFormField(
                        focusNode: _focusNodePW,
                        controller: _controllerPW,
                        decoration: const InputDecoration(
                            labelText: '비밀번호',
                            border: OutlineInputBorder(),
                            hintText: '8글자 이상의 비밀번호를 만들어 주세요'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) return '비밀번호를 입력해 주세요';
                          if (value!.length < 7) return '비밀번호를 8글자 이상 입력해주세요';
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: _screenSize.getHeightPerSize(12),
                      width: _screenSize.getWidthPerSize(80),
                      child: TextFormField(
                        focusNode: _focusNodePWCheck,
                        controller: _controllerPWCheck,
                        decoration: const InputDecoration(
                          labelText: '비밀번호 확인',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value != _controllerPW.text) {
                            return '비밀번호가 동일하지 않습니다.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(microseconds: Platform.isIOS ? 300000 : 130000),
              curve: Curves.easeInOut,
              bottom: _focusNodeID.hasFocus || _focusNodePW.hasFocus || _focusNodePWCheck.hasFocus
                  ? -_screenSize.getHeightPerSize(8)
                  : 0,
              child: SizedBox(
                height: _screenSize.getHeightPerSize(8),
                width: _screenSize.getWidthPerSize(100),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _checkAccount();
                  },
                  child: Text(
                    '다음',
                    style:
                        TextStyle(fontSize: _screenSize.getHeightPerSize(3), color: Colors.black),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

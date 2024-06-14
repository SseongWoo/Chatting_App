import 'package:chattingapp/login/registration/registration_dialog.dart';
import 'package:chattingapp/login/registration/registration_second_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../utils/screen_size.dart';
import 'authentication.dart';
import 'dart:io';

class RegistrationFirstScreen extends StatefulWidget {
  const RegistrationFirstScreen({super.key});

  @override
  State<RegistrationFirstScreen> createState() => _RegistrationFirstScreenState();
}

class _RegistrationFirstScreenState extends State<RegistrationFirstScreen> {
  late ScreenSize screenSize;
  final _registrationFirstFormKey = GlobalKey<FormState>();
  TextEditingController controllerID = TextEditingController();
  TextEditingController controllerPW = TextEditingController();
  TextEditingController controllerPWCheck = TextEditingController();
  final FocusNode focusNodeID = FocusNode();
  final FocusNode focusNodePW = FocusNode();
  final FocusNode focusNodePWCheck = FocusNode();
  bool loadingState = false;

  @override
  dispose() {
    controllerID.dispose();
    controllerPW.dispose();
    super.dispose();
  }

  void checkAccount() async {
    setState(() {
      loadingState = true;
    });
    if (_registrationFirstFormKey.currentState!.validate()) {
      String message = await createUserWithEmailAndPassword(controllerID.text, controllerPW.text);
      if (mounted) {
        if (message == "") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RegistrationSecondScreen(
                      email: controllerID.text,
                      password: controllerPW.text,
                    )),
          );
        } else {
          firebaseAuthError(context, message);
        }
      }
    } else {
      setState(() {
        loadingState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ),
      body: SizedBox(
        height: screenSize.getHeightSize(),
        child: Stack(
          children: [
            Form(
              key: _registrationFirstFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: screenSize.getHeightPerSize(5),
                    ),
                    SizedBox(
                      width: screenSize.getWidthPerSize(80),
                      child: Text(
                        "회원정보를\n입력해주세요",
                        style: TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                      ),
                    ),
                    SizedBox(
                      height: screenSize.getHeightPerSize(5),
                    ),
                    SizedBox(
                      height: screenSize.getHeightPerSize(12),
                      width: screenSize.getWidthPerSize(80),
                      child: TextFormField(
                        focusNode: focusNodeID,
                        controller: controllerID,
                        decoration:
                            const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) return '이메일을 입력해 주세요';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!))
                            return "이메일 형식이 아닙니다.";
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenSize.getHeightPerSize(12),
                      width: screenSize.getWidthPerSize(80),
                      child: TextFormField(
                        focusNode: focusNodePW,
                        controller: controllerPW,
                        decoration: const InputDecoration(
                            labelText: '비밀번호',
                            border: OutlineInputBorder(),
                            hintText: "8글자 이상의 비밀번호를 만들어 주세요"),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) return "비밀번호를 입력해 주세요";
                          if (value!.length < 7) return "비밀번호를 8글자 이상 입력해주세요";
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenSize.getHeightPerSize(12),
                      width: screenSize.getWidthPerSize(80),
                      child: TextFormField(
                        focusNode: focusNodePWCheck,
                        controller: controllerPWCheck,
                        decoration: const InputDecoration(
                          labelText: '비밀번호 확인',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value != controllerPW.text) {
                            return "비밀번호가 동일하지 않습니다.";
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
              bottom: focusNodeID.hasFocus || focusNodePW.hasFocus || focusNodePWCheck.hasFocus
                  ? -screenSize.getHeightPerSize(8)
                  : 0,
              child: SizedBox(
                height: screenSize.getHeightPerSize(8),
                width: screenSize.getWidthPerSize(100),
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
                      if (!loadingState) {
                        checkAccount();
                      }
                    },
                    child: loadingState
                        ? const SpinKitThreeInOut(
                            color: Colors.white,
                          )
                        : Text(
                            "다음",
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                          )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

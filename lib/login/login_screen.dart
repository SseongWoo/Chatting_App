import 'package:chattingapp/login/registration/registration_first_screen.dart';
import 'package:chattingapp/login/registration/registration_third_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/screen_size.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ScreenSize screenSize;
  bool isChecked = true;
  bool loginFail = false;
  String loginFailReason = "";

  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  TextEditingController controllerID = TextEditingController();
  TextEditingController controllerPW = TextEditingController();

  @override
  void dispose() {
    controllerID.dispose();
    controllerPW.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: screenSize.getWidthPerSize(25),
            top: screenSize.getHeightPerSize(10),
            child: SizedBox(
              width: screenSize.getWidthPerSize(50),
              height: screenSize.getWidthPerSize(50),
              //color: Colors.blueAccent,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  height: screenSize.getHeightPerSize(6),
                  child: TextField(
                    controller: controllerID,
                    decoration: const InputDecoration(labelText: '아이디'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(3),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  height: screenSize.getHeightPerSize(6),
                  child: TextField(
                    controller: controllerPW,
                    decoration: const InputDecoration(labelText: "비밀번호"),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onSubmitted: (value) {
                      print(value);
                    },
                  ),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(75),
                  child: Row(
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                          child: const Text("자동 로그인")),
                    ],
                  ),
                ),
                Visibility(
                    visible: loginFail,
                    child: SizedBox(
                      width: screenSize.getWidthPerSize(65),
                      height: screenSize.getHeightPerSize(3),
                      child: Text(
                        loginFailReason,
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(1.5),
                            color: Colors.red),
                      ),
                    )),
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  height: screenSize.getHeightPerSize(5),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (controllerID.text == "") {
                          loginFailReason = "아이디를 입력해 주세요";
                          loginFail = true;
                        } else if (controllerPW.text == "") {
                          loginFailReason = "비밀번호를 입력해 주세요";
                          loginFail = true;
                        }
                      });
                    },
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(2),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationFirstScreen()),
                            );
                          },
                          child: Text(
                            "회원가입",
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(1.5)),
                          )),
                      TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           const AccountFindScreen()),
                            // );
                          },
                          child: Text(
                            "계정 찾기",
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(1.5)),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  height: screenSize.getHeightPerSize(5),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RegistrationThirdScreen(),
                          ));
                    },
                    child: Text(
                      '테스트 버튼',
                      style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

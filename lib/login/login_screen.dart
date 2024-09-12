import 'package:chattingapp/login/registration/authentication.dart';
import 'package:chattingapp/login/registration/registration_first_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../home/chat/chat_list_data.dart';
import '../home/friend/friend_data.dart';
import '../home/home_screen.dart';
import '../utils/my_data.dart';
import '../utils/screen_size.dart';
import '../utils/shared_preferences.dart';
import 'find/account_find_first_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ScreenSize screenSize;
  bool isChecked = true;
  bool loginFail = false;
  String loginFailReason = '';
  bool loadingState = false;
  bool keyboardVisibilty = false;

  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  TextEditingController controllerID = TextEditingController();
  TextEditingController controllerPW = TextEditingController();

  @override
  void dispose() {
    controllerID.dispose();
    controllerPW.dispose();
    super.dispose();
  }

  // 로그인을 하기위해 DB에서 정보를 가지고와 내부 저장소에 저장하고 로그인을 완료하는 함수
  void _login() async {
    if (await signIn(controllerID.text, controllerPW.text)) {
      await getFriendDataList();
      await getMyData();
      await getChatRoomData();
      await getChatRoomDataList();
      await getSharedPreferencese();
      await getRealTimeData();
      initializationTap();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    } else {
      setState(() {
        loadingState = false;
        loginFailReason = '이메일 또는 비밀번호를 잘못 입력했습니다.';
        loginFail = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: screenSize.getHeightPerSize(12),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                firstChild: SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  height: screenSize.getHeightPerSize(10),
                  child: Center(
                      child: Text(
                    'Flutter Talk',
                    style: TextStyle(
                        color: const Color(0xff53c5f8), fontSize: screenSize.getHeightPerSize(5)),
                  )),
                ),
                secondChild: SizedBox(
                  width: screenSize.getWidthPerSize(80),
                  height: screenSize.getWidthPerSize(50),
                  child: Image.asset('assets/images/logo.png'),
                ),
                crossFadeState:
                    keyboardVisibilty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(4),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(80),
                height: screenSize.getHeightPerSize(6),
                child: TextField(
                    controller: controllerID,
                    decoration: const InputDecoration(labelText: '아이디'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onTap: () => keyboardVisibilty = true,
                    onTapOutside: (event) {
                      keyboardVisibilty = false;
                      FocusManager.instance.primaryFocus?.unfocus();
                    }),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(3),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(80),
                height: screenSize.getHeightPerSize(6),
                child: TextField(
                    controller: controllerPW,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onTap: () => keyboardVisibilty = true,
                    onTapOutside: (event) {
                      keyboardVisibilty = false;
                      FocusManager.instance.primaryFocus?.unfocus();
                    }),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(2),
              ),
              // SizedBox(
              //   width: screenSize.getWidthPerSize(80),
              //   child: Row(
              //     children: [
              //       Checkbox(
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(15)),
              //         value: isChecked,
              //         onChanged: (value) {
              //           setState(() {
              //             isChecked = value!;
              //           });
              //         },
              //         activeColor: Colors.green,
              //         checkColor: Colors.white,
              //       ),
              //       GestureDetector(
              //           onTap: () {
              //             setState(() {
              //               isChecked = !isChecked;
              //             });
              //           },
              //           child: const Text('자동 로그인')),
              //     ],
              //   ),
              // ),
              Visibility(
                  visible: loginFail,
                  child: SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    height: screenSize.getHeightPerSize(3),
                    child: Text(
                      loginFailReason,
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1.5), color: Colors.red),
                    ),
                  )),
              SizedBox(
                width: screenSize.getWidthPerSize(80),
                height: screenSize.getHeightPerSize(5),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (controllerID.text == '') {
                        loginFailReason = '아이디를 입력해 주세요';
                        loginFail = true;
                      } else if (controllerPW.text == '') {
                        loginFailReason = '비밀번호를 입력해 주세요';
                        loginFail = true;
                      } else {
                        loadingState = true;
                        _login();
                      }
                    });
                  },
                  child: loadingState
                      ? const SpinKitThreeInOut(
                          color: Colors.white,
                        )
                      : Text(
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
                                builder: (context) => const RegistrationFirstScreen()),
                          );
                        },
                        child: Text(
                          '회원가입',
                          style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountFindFirstScreen()),
                          );
                        },
                        child: Text(
                          '계정 찾기',
                          style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                        )),
                  ],
                ),
              ),
              // SizedBox(
              //   width: screenSize.getWidthPerSize(80),
              //   height: screenSize.getHeightPerSize(5),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) =>
              //                 const AccountFindSecondScreen(email: 'email',),
              //           ));
              //     },
              //     child: Text(
              //       '테스트 버튼',
              //       style: TextStyle(
              //         fontSize: screenSize.getHeightPerSize(2),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

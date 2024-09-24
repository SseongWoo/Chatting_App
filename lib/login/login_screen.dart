import 'package:chattingapp/login/registration/authentication.dart';
import 'package:chattingapp/login/registration/registration_first_screen.dart';
import 'package:chattingapp/utils/color/color.dart';
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
  bool _isChecked = true;
  bool _loginFail = false;
  String _loginFailReason = '';
  bool _loadingState = false;
  bool _keyboardVisibilty = false;

  final TextEditingController _controllerID = TextEditingController();
  final TextEditingController _controllerPW = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// 데모 ///
    _controllerID.text = 'testid1@test.com';
    _controllerPW.text = '123456789';
  }

  @override
  void dispose() {
    _controllerID.dispose();
    _controllerPW.dispose();
    super.dispose();
  }

  void _getID() async {
    String? getid = await getIDShared();
    _controllerID.text = getid.toString();
  }

  // 로그인을 하기위해 DB에서 정보를 가지고와 내부 저장소에 저장하고 로그인을 완료하는 함수
  void _login() async {
    if (await signIn(_controllerID.text, _controllerPW.text)) {
      if (_isChecked) {
        await setIDShared(_controllerID.text);
      } else {
        await setIDShared('');
      }
      await getMyData();
      await getFriendDataList();
      await getChatRoomData();
      await getChatRoomDataList();
      await getTapShared();
      await getRealTimeData();
      initializationTap();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    } else {
      setState(() {
        _loadingState = false;
        _loginFailReason = '이메일 또는 비밀번호를 잘못 입력했습니다.';
        _loginFail = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    _getID();
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
                    _keyboardVisibilty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(4),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(80),
                height: screenSize.getHeightPerSize(6),
                child: TextField(
                    controller: _controllerID,
                    decoration: const InputDecoration(labelText: '아이디'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onTap: () => _keyboardVisibilty = true,
                    onTapOutside: (event) {
                      _keyboardVisibilty = false;
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
                    controller: _controllerPW,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onTap: () => _keyboardVisibilty = true,
                    onTapOutside: (event) {
                      _keyboardVisibilty = false;
                      FocusManager.instance.primaryFocus?.unfocus();
                    }),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(2),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(85),
                child: Row(
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        },
                        child: const Text('아이디 저장')),
                  ],
                ),
              ),
              Visibility(
                  visible: _loginFail,
                  child: SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    height: screenSize.getHeightPerSize(3),
                    child: Text(
                      _loginFailReason,
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1.5), color: Colors.red),
                    ),
                  )),
              SizedBox(
                width: screenSize.getWidthPerSize(80),
                height: screenSize.getHeightPerSize(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: mainLightColor),
                  onPressed: () {
                    setState(() {
                      if (_controllerID.text == '') {
                        _loginFailReason = '아이디를 입력해 주세요';
                        _loginFail = true;
                      } else if (_controllerPW.text == '') {
                        _loginFailReason = '비밀번호를 입력해 주세요';
                        _loginFail = true;
                      } else {
                        _loadingState = true;
                        _login();
                      }
                    });
                  },
                  child: _loadingState
                      ? const SpinKitThreeInOut(
                          color: Colors.white,
                        )
                      : Text(
                          '로그인',
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(2), color: Colors.white),
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
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(1.5), color: mainColor),
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
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(1.5), color: mainColor),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/login/login_screen.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'home/chat/chat_data.dart';
import 'home/friend/friend_data.dart';
import 'login/registration/authentication.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ScreenSize screenSize;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String loadingMessage = "";
  Future<void>? _delayedAction;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      checkLoginData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _delayedAction = null;
    super.dispose();
  }

  void checkLoginData() async {
    // 5초 후에 실행할 함수
    _delayedAction = Future.delayed(const Duration(seconds: 5), () {
      // 여기에 실행할 코드를 추가하세요.
      if (mounted) {
        signOut();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      }
    });
    setState(() {
      loadingMessage = "로그인 데이터를 불러오는중";
    });
    if (auth.currentUser != null) {
      await loadData();
      setState(() {
        loadingMessage = "마무리중";
      });
      Timer(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  Future<void> loadData() async {
    await getFriendDataList();
    //await getCategoryList();
    await getMyData();
    await getChatRoomData();
    await getChatRoomDataList();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);

    //auth.currentUser != null ? const HomeScreen() : const LoginScreen(),
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xff53c5f8),
          body: Stack(children: [
            Center(
                child: SizedBox(
                    width: screenSize.getWidthPerSize(50),
                    child: Image.asset('assets/images/logo.png'))),
            Positioned(
                left: screenSize.getWidthPerSize(45),
                bottom: screenSize.getHeightPerSize(20),
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: screenSize.getWidthPerSize(10),
                )),
            Positioned(
                left: screenSize.getWidthPerSize(15),
                bottom: screenSize.getHeightPerSize(15),
                child: SizedBox(
                  width: screenSize.getWidthPerSize(70),
                  height: screenSize.getHeightPerSize(5),
                  child: Center(
                      child: Text(
                    loadingMessage,
                    style: const TextStyle(color: Colors.white),
                  )),
                ))
          ]),
        ));
  }
}

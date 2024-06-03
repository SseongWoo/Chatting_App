import 'dart:async';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/login/login_screen.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'home/friend/category/category_data.dart';
import 'home/friend/friend_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ScreenSize screenSize;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String loadingMessage = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      checkLoginData();
    });
  }

  void checkLoginData() async{
    setState(() {
      loadingMessage = "로그인 데이터를 불러오는중";
    });
    if (auth.currentUser != null) {
      await loadData();
      setState(() {
        loadingMessage = "마무리중";
      });
      Timer(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) => const HomeScreen()), (route) => false);
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  Future<void> loadData() async {
    await getFriendDataList();
    await getCategoryList();
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
                )
            ),
            Positioned(
              left: screenSize.getWidthPerSize(15),
              bottom: screenSize.getHeightPerSize(15),
                child: SizedBox(
              width: screenSize.getWidthPerSize(70),
              height: screenSize.getHeightPerSize(5),
                  child: Center(child: Text(loadingMessage,style: const TextStyle(color: Colors.white),)),
            ))
          ]),
        ));
  }
}

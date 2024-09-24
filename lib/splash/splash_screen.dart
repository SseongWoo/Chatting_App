import 'dart:async';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/login/login_screen.dart';
import 'package:chattingapp/splash/splash_dialog.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../home/chat/chat_list_data.dart';
import '../home/friend/friend_data.dart';
import '../login/registration/authentication.dart';
import '../utils/public_variable_data.dart';

// 앱을 시작할때 처음 나타나는 로딩화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String loadingMessage = '';
  Future<void>? _delayedAction; // n초 뒤에 실행하는 기능을 만들기 위함
  bool _versionCheck = false;

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
    setState(() {
      loadingMessage = '앱의 최신 버전을 확인 중';
    });
    await versionCheck();
    if (_versionCheck) {
      // 5초 후에 실행할 함수
      _delayedAction = Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          signOut();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        }
      });
      setState(() {
        loadingMessage = '로그인 데이터를 불러오는중';
      });
      if (auth.currentUser != null) {
        bool checkLoadData = await loadData();
        if (checkLoadData) {
          setState(() {
            loadingMessage = '마무리중';
          });
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
          });
        } else {
          setState(() {
            loadingMessage = '로그인 데이터 오류';
          });
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
          });
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      }
    }
  }

  // 배포된 버전과 현재 앱의 버전을 확인하는 함수
  Future<void> versionCheck() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final info = await PackageInfo.fromPlatform();
      appVersion = info.version;

      //데이터 가져오기 시간 간격 : 12시간
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1), // 데이터를 가져오는데 허용하는 시간
        minimumFetchInterval: const Duration(hours: 12), // 데이터 가져오기 간격
      ));

      await remoteConfig.fetchAndActivate();

      firebaseVersion = remoteConfig.getString('latest_version');

      if (firebaseVersion != appVersion) {
        _versionCheck = false;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return versionCheckDialog(context);
            });
      } else {
        _versionCheck = true;
      }
    } catch (e) {
      _versionCheck = false;
      debugPrint('versionCheck오류 : $e');
    }
  }

  // 사용자 계정에 있는 데이터들을 DB에서 가져오는 함수
  Future<bool> loadData() async {
    //await getCategoryList();
    bool checkMyData = await getMyData();
    bool checkFriendDataList = await getFriendDataList();
    bool checkChatRoomData = await getChatRoomData();
    bool checkChatRoomDataList = await getChatRoomDataList();
    await getTapShared();
    await getRealTimeData();
    if (checkFriendDataList &&
        checkMyData &&
        checkChatRoomData &&
        checkChatRoomDataList &&
        myData.myUID.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
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
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

import 'package:chattingapp/splash_screen.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/state_observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'firebase_options.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 모드 고정
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //앱 종료시 호출되는 함수
  final observer = StateObserver();
  WidgetsBinding.instance.addObserver(observer);
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      builder: EasyLoading.init(),
      theme: ThemeData(fontFamily: 'Gyeonggi',primaryColor: mainColor),
      themeMode: ThemeMode.system,
    );
  }
}

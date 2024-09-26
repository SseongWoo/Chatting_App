import 'package:chattingapp/error/error_report_screen.dart';
import 'package:chattingapp/login/login_screen.dart';
import 'package:chattingapp/utils/color/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../utils/screen_size.dart';

// 오류가 발생했을때 나타나는 화면
class ErrorScreen extends StatefulWidget {
  final String errorMessage;
  const ErrorScreen({super.key, required this.errorMessage});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  // 홈화면으로 돌아가기
  void _goHome() {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    }
  }

  // 제보하러 가기
  void _goReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ErrorReportScreen(errorMessage: widget.errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenSize.getHeightPerSize(5),
            ),
            Image.asset(
              'assets/images/errorImg.png',
              scale: 2,
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(1),
            ),
            Text(
              '어플리케이션에 오류가 발생하였습니다.',
              style: TextStyle(fontSize: screenSize.getHeightPerSize(2.5)),
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(1),
            ),
            Text(
              '잠시 후 다시 시도해 주시기 바랍니다.\n오류가 지속될경우 고객센터에 문의해 주세요.',
              style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(5),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              onPressed: () {
                _goHome();
              },
              child: Text(
                '홈 화면으로 돌아가기',
                style: TextStyle(fontSize: screenSize.getHeightPerSize(2), color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, screenSize.getHeightPerSize(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '같은 오류가 계속 발생하시나요?',
              style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
            ),
            SizedBox(
              width: screenSize.getWidthPerSize(5),
            ),
            ElevatedButton(
              onPressed: () {
                _goReport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text(
                '문의하기',
                style: TextStyle(color: mainLightColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

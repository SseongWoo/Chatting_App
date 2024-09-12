import 'package:chattingapp/login/login_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/screen_size.dart';

// 계정 찾기 두번째 화면
class AccountFindSecondScreen extends StatefulWidget {
  final String email;
  const AccountFindSecondScreen({super.key, required this.email});

  @override
  State<AccountFindSecondScreen> createState() => _AccountFindSecondScreenState();
}

class _AccountFindSecondScreenState extends State<AccountFindSecondScreen> {
  late ScreenSize screenSize;
  late String email;

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: screenSize.getHeightSize(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      '메일 발송 완료\n',
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      '비밀번호 재설정 메일이 발송되었습니다.\n$email 계정의 이메일을 확인하여 계정의 비밀번호를 재설정해주세요.',
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
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
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: Text(
                  '로그인 화면으로',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

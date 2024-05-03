import 'package:chattingapp/login/registration/registration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../utils/screen_size.dart';
import '../login_screen.dart';
import 'authentication.dart';

class RegistrationSecondScreen extends StatefulWidget {
  final String email;
  final String password;
  const RegistrationSecondScreen({super.key, required this.email, required this.password});

  @override
  State<RegistrationSecondScreen> createState() =>
      _RegistrationSecondScreenState();
}

class _RegistrationSecondScreenState extends State<RegistrationSecondScreen> {
  late ScreenSize screenSize;
  late String email;
  late String password;
  bool loadingState = false;

  @override
  void initState(){
    super.initState();
    email = widget.email;
    password = widget.password;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new)),
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
                      "계정 인증\n",
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      "회원가입이 완료되었습니다!\n인증 메일이 성공적으로 전송되었습니다. 아래 이메일 주소로 전송된 링크를 클릭하여 인증을 완료해 주세요. ",
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    child: Text(
                      email,
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(50),
                    child: ElevatedButton(
                        onPressed: () {
                          signInWithVerifyEmailAndPassword(email,password);
                        },
                        child: Text(
                          "이메일 다시 보내기",
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(2),
                              color: Colors.black),
                        )),
                  )
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
                          topLeft: Radius.circular(20.0), // 왼쪽 위 모서리만 둥글게 설정
                          topRight: Radius.circular(20.0), // 오른쪽 위 모서리만 둥글게 설정
                        ), // 모서리를 둥글게 설정
                      ),
                    ),
                    onPressed: () async {
                      if(!loadingState){
                        setState(() {
                          loadingState = true;
                        });
                        if(await checkEmailVerificationStatus()){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()),);
                        }else{
                          emailAuthFail(context);
                          setState(() {
                            loadingState = false;
                          });
                        }
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
              ))
        ],
      ),
    );
  }
}

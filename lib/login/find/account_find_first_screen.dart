import 'package:chattingapp/login/find/account_find_second_screen.dart';
import 'package:chattingapp/login/registration/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../utils/screen_size.dart';

// 계정 찾기 첫번째 화면
class AccountFindFirstScreen extends StatefulWidget {
  const AccountFindFirstScreen({super.key});

  @override
  State<AccountFindFirstScreen> createState() => _AccountFindFirstScreenState();
}

class _AccountFindFirstScreenState extends State<AccountFindFirstScreen> {
  final _accountFindFirstFormKey = GlobalKey<FormState>();
  TextEditingController controllerID = TextEditingController();
  final FocusNode focusNodeID = FocusNode();
  bool loadingState = false;
  bool existentEmail = true;

  @override
  dispose() {
    controllerID.dispose();
    super.dispose();
  }

  // 계정의 비밀번호를 찾기 위해 입력받은 이메일을 체크 후 비밀번호 재설정 메일을 보낸뒤 다음화면으로 넘어가는 함수
  void findPassword() async {
    bool emailCheck = await isEmailRegistered(controllerID.text);
    if (emailCheck) {
      await resetPassword(controllerID.text, context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AccountFindSecondScreen(
                  email: controllerID.text,
                )),
      );
    } else {
      setState(() {
        loadingState = false;
        existentEmail = false;
        _accountFindFirstFormKey.currentState!.validate();
      });
    }
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
                      '계정 찾기\n',
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      '복구 할 이메일을 입력해 주세요',
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(12),
                    width: screenSize.getWidthPerSize(80),
                    child: Form(
                      key: _accountFindFirstFormKey,
                      child: TextFormField(
                        focusNode: focusNodeID,
                        controller: controllerID,
                        decoration:
                            const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) return '이메일을 입력해 주세요';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return '이메일 형식이 아닙니다.';
                          }
                          if (!existentEmail) return '등록되어 있지 않는 이메일입니다.';
                          return null;
                        },
                      ),
                    ),
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
                      topLeft: Radius.circular(20.0), // 왼쪽 위 모서리만 둥글게 설정
                      topRight: Radius.circular(20.0), // 오른쪽 위 모서리만 둥글게 설정
                    ), // 모서리를 둥글게 설정
                  ),
                ),
                onPressed: () {
                  if (_accountFindFirstFormKey.currentState!.validate() && !loadingState) {
                    setState(() {
                      loadingState = true;
                    });
                    findPassword();
                  }
                },
                child: loadingState
                    ? const SpinKitThreeInOut(
                        color: Colors.white,
                      )
                    : Text(
                        '다음',
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

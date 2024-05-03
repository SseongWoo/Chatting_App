import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import '../../utils/screen_size.dart';

class RegistrationThirdScreen extends StatefulWidget {
  const RegistrationThirdScreen({super.key});

  @override
  State<RegistrationThirdScreen> createState() =>
      _RegistrationThirdScreenState();
}

class _RegistrationThirdScreenState extends State<RegistrationThirdScreen> {
  TextEditingController controllerNickName = TextEditingController();
  final FocusNode focusNodeNickName = FocusNode();
  late ScreenSize screenSize;
  bool loadingState = false;
  late Size size;

  @override
  void dispose() {
    controllerNickName.dispose();
    super.dispose();
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
                      "계정 설정\n",
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      "마지막 단계입니다!\n사용할 사용자의 닉네임과 프로필 사진을 등록해주세요. 이 정보들은 나중에 변경할 수 있습니다.",
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    width: screenSize.getHeightPerSize(20),
                    height: screenSize.getHeightPerSize(20),
                    child: Container(color: Colors.blue,)
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(10),
                    width: screenSize.getWidthPerSize(60),
                    child: TextField(
                      focusNode: focusNodeNickName,
                      controller: controllerNickName,
                      textAlign: TextAlign.center,
                      maxLength: 8,
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
              duration: Duration(microseconds: Platform.isIOS ? 300000 : 130000),
              curve: Curves.easeInOut,
              bottom: focusNodeNickName.hasFocus ? -screenSize.getHeightPerSize(8): 0,
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
                    onPressed: () {},
                    child: loadingState
                        ? const SpinKitThreeInOut(
                            color: Colors.white,
                          )
                        : Text(
                            "완료",
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(3),
                                color: Colors.black),
                          )),
              ))
        ],
      ),
    );
  }
}

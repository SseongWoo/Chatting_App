import 'package:chattingapp/utils/color/color.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../utils/public_variable_data.dart';

// 앱 업데이트 확인 화면
class UpdateInformationScreen extends StatefulWidget {
  const UpdateInformationScreen({super.key});

  @override
  State<UpdateInformationScreen> createState() => _UpdateInformationScreenState();
}

class _UpdateInformationScreenState extends State<UpdateInformationScreen> {
  String _messageVerson = '버전 0.0.0';
  String _message = '앱이 최신버전 입니다.';
  bool _versonCheck = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (firebaseVersion == appVersion) {
      _messageVerson = '버전 $appVersion';
      _message = '앱이 최신버전 입니다.\n';
      _versonCheck = true;
    } else {
      _messageVerson = '현재 버전 $appVersion\n최신 버전 $firebaseVersion';
      _message = '새로운 버전이 출시되었습니다.\n원활한 사용을 위해 최신 버전으로 업데이트해 주세요.\n';
      _versonCheck = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              textAlign: TextAlign.center,
            ),
            Text(
              _messageVerson,
              style: const TextStyle(color: Colors.grey),
            ),
            Visibility(
              visible: !_versonCheck,
              child: TextButton(
                  onPressed: () {},
                  child: Text(
                    '업데이트',
                    style: TextStyle(color: mainBoldColor),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

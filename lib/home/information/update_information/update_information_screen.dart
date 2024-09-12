import 'package:flutter/material.dart';

// 앱 업데이트 확인 화면
class UpdateInformationScreen extends StatefulWidget {
  const UpdateInformationScreen({super.key});

  @override
  State<UpdateInformationScreen> createState() => _UpdateInformationScreenState();
}

class _UpdateInformationScreenState extends State<UpdateInformationScreen> {
  String _messageVerson = '버전 0.0.0';
  String _message = '앱이 최신버전 입니다.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_messageVerson),
            Text(_message),
          ],
        ),
      ),
    );
  }
}

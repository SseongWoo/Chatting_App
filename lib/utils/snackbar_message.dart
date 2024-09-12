import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';

// 넘겨받은 문장을 사용해서 스낵바 메세지를 나타내는 함수
void snackBarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: mainLightColor,
    ),
  );
}

void snackBarErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

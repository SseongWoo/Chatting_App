import 'package:flutter/material.dart';
import '../../home/home_screen.dart';


void firebaseAuthError(BuildContext getContext, String errorMessage) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("오류"),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: const Text("확인")),
        ],
      );
    },
  );
}
void emailAuthFail(BuildContext getContext) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("인증 실패"),
        content: const Text("인증에 실패하셨습니다.\n다시 시도해 주세요"),
        actions: <Widget>[
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: const Text("확인")),
        ],
      );
    },
  );
}

void finishRegistration(BuildContext getContext) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("계정 설정 완료"),
        content: const Text("계정 설정이 완료되었습니다.\n계정을 사용하실수 있습니다."),
        actions: <Widget>[
          TextButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
          }, child: const Text("확인")),
        ],
      );
    },
  );
}
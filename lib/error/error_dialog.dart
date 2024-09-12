import 'package:flutter/material.dart';

import 'error_report_screen.dart';

void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('오류!'),
        content: Text('어플리케이션에 오류가 발생하였습니다.\n$errorMessage'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ErrorReportScreen(
                          errorMessage: errorMessage,
                        )),
              );
            },
            child: const Text('버그 제보하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: const Text('넘어가기'),
          ),
        ],
      );
    },
  );
}

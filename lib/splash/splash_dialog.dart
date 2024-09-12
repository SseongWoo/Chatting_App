import 'dart:io';
import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';
import '../utils/launch_browser.dart';

// 새 버전이 나왔을때 나타나는 다이얼로그
AlertDialog versionCheckDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('업데이트 알림'),
    content: const Text('새로운 버전의 앱이 출시되었습니다.\n앱 업데이트를 진행해 주세요'),
    actions: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              onPressed: () {
                exit(0);
              },
              child: const Text(
                '앱 종료',
                style: TextStyle(color: Colors.black),
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainLightColor),
              onPressed: () async {
                Navigator.of(context).pop();
                await launchBrowser();
              },
              child: const Text(
                '업데이트 하기',
                style: TextStyle(color: Colors.black),
              )),
        ],
      )
    ],
  );
}

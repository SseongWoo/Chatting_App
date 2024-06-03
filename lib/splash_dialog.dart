import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';

void versionCheckDialog(BuildContext getContext) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("업데이트 알림"),
        content: const Text("새로운 버전의 앱이 출시되었습니다.\n앱 업데이트를 진행해 주세요"),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: mainLightColor),
                  onPressed: () {
                Navigator.of(context).pop();
              }, child: const Text("업데이트 하기",style: TextStyle(color: Colors.black),)),
              ElevatedButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: const Text("앱 종료",style: TextStyle(color: Colors.black),)),
            ],
          )
        ],
      );
    },
  );
}
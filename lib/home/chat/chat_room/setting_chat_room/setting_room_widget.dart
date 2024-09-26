import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room_data.dart';
import 'package:chattingapp/utils/data_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../home_screen.dart';

// 채팅방 삭제할때 생성되는 다이얼로그
void deleteChatRoomDialog(BuildContext getContext, String roomUid) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("채팅방 삭제"),
        content: const Text('정말로 채팅방을 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                EasyLoading.show();
                await deleteChatRoom(roomUid, context);
                await refreshData(context);
                EasyLoading.dismiss();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              )),
        ],
      );
    },
  );
}

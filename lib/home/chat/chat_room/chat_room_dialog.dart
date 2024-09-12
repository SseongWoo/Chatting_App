import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../utils/data_refresh.dart';
import '../../../utils/file_download.dart';
import '../../home_screen.dart';
import 'chat_room_data.dart';

// 채팅방을 나갈때 나타나는 다이얼로그
void leaveChatRoomDialog(BuildContext getContext, String roomUid) {
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text('채팅방 떠나기'),
        content: const Text('정말로 채팅방을 떠나시겠습니까?'),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                EasyLoading.show();
                await leaveChatRoom(roomUid);
                await refreshData();
                EasyLoading.dismiss();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
              },
              child: const Text(
                '떠나기',
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

// 매니저 위임을 할때 생성되는 다이얼로그
class ManagerDelegationDialog extends StatelessWidget {
  final String chatRoomUid;
  final String delegationUid;
  final Function(String) refresh;
  const ManagerDelegationDialog(
      {super.key, required this.chatRoomUid, required this.delegationUid, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('매니저 위임'),
      content: const Text('매니저를 위임하시겠습니까?'),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.black),
            )),
        TextButton(
          onPressed: () async {
            EasyLoading.show();
            await managerDelegation(chatRoomUid, delegationUid);
            refresh(delegationUid);
            EasyLoading.dismiss();
            Navigator.of(context).pop();
          },
          child: const Text(
            '확인',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

// 이미지 다운로드 다이얼로그
void imageDownloadDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () async {
              EasyLoading.show();
              await downloadFile(imageUrl, DateTime.now().toString());
              EasyLoading.dismiss();
              snackBarMessage(context, '이미지 다운로드 완료');
              Navigator.of(context).pop();
            },
            child: const Text('이미지 다운로드'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
        ],
      );
    },
  );
}

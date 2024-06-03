import 'package:flutter/material.dart';

import 'request_data.dart';

void addFriendDialogTest(BuildContext getContext) {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  showDialog(
    context: getContext,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("친구 추가"),
        content: TextField(
          focusNode: focusNode,
          controller: controller,
          decoration: const InputDecoration(
            hintText: "UID 또는 이메일을 입력해 주세요",
          ),
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
        actions: <Widget>[
          TextButton(
              onPressed: (){
                sendRequest(controller.text, getContext);
                focusNode.dispose();
                Navigator.of(context).pop();
              },
              child: const Text("요청 보내기")),
          TextButton(
              onPressed: () {
                focusNode.dispose();
                Navigator.of(context).pop();
              },
              child: const Text("취소")),
        ],
      );
    },
  );
}
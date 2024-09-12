import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 원하는 문장을 클립보드에 복사시키는 함수
void copyToClipboard(BuildContext context, String copyData, String codeType) {
  Clipboard.setData(ClipboardData(text: copyData));
  snackBarMessage(context, '$codeType 복사하였습니다.');
}

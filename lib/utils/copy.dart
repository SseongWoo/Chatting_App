import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(BuildContext context, String copyData, String codeType){
  Clipboard.setData(ClipboardData(text: copyData));
  snackBarMessage(context, "$codeType 복사하였습니다.");
}
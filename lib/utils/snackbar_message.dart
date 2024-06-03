import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';

void snackBarMessage(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message),backgroundColor: mainLightColor,),
  );
}
void snackBarErrorMessage(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message),backgroundColor: Colors.red,),
  );
}
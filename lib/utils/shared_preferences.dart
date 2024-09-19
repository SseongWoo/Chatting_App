import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color/color.dart';

// 데이터를 내부 기기에 저장하는 기능들

// home_screen의 탭뷰 위치 설정 변수
int homeTap = 1;
// request_screen의 탭뷰 위치 설정 변수
int requestTap = 0;

// 색 설정
Map<String, Color> chatRoomColorMap = {
  'AppbarColor': Colors.white,
  'BackgroundColor': mainBackgroundColor,
  'MyChatColor': mainLightColor,
  'MyChatStringColor': Colors.black,
  'FriendChatColor': Colors.white,
  'FriendChatStringColor': Colors.black,
};

double chatStringSize = 1.6;

void initializationTap() {
  homeTap = 1;
  requestTap = 0;
}

Future<void> setColorSharedPreferencese(String type, Color color) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  switch (type) {
    case 'AppbarColor':
      await prefs.setString('AppbarColor', color.value.toRadixString(16).padLeft(8, '0'));
      break;
    case 'BackgroundColor':
      await prefs.setString('BackgroundColor', color.value.toRadixString(16).padLeft(8, '0'));
      break;
    case 'MyChatColor':
      await prefs.setString('MyChatColor', color.value.toRadixString(16).padLeft(8, '0'));
      break;
    case 'MyChatStringColor':
      await prefs.setString('MyChatStringColor', color.value.toRadixString(16).padLeft(8, '0'));
      break;
    case 'FriendChatColor':
      await prefs.setString('FriendChatColor', color.value.toRadixString(16).padLeft(8, '0'));
      break;
    case 'FriendChatStringColor':
      await prefs.setString('FriendChatStringColor', color.value.toRadixString(16).padLeft(8, '0'));
      break;
    default:
      break;
  }
}

Future<void> setSizeSharedPreferencese() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('chatStringSize', chatStringSize);
}

Future<void> setSharedPreferencese() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('homeTap', homeTap);
    await prefs.setInt('requestTap', requestTap);
  } catch (e) {
    //
  }

  //await prefs.setDouble('chatStringSize', chatStringSize);
  // for (var entry in chatRoomColorMap.entries) {
  //   await prefs.setString(entry.key, entry.value.value.toRadixString(16).padLeft(8, '0'));
  // }
}

Future<void> getSharedPreferencese() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? getHomeTap = prefs.getInt('homeTap');
  final int? getRequestTap = prefs.getInt('requestTap');
  final double? getChatStringSize = prefs.getDouble('chatStringSize');

  for (var entry in chatRoomColorMap.entries) {
    final String? getData = prefs.getString(entry.key);
    if (getData != null) {
      chatRoomColorMap[entry.key] = Color(int.parse('0x$getData'));
    }
  }
  if (getHomeTap != null) {
    homeTap = getHomeTap;
  }
  if (getRequestTap != null) {
    requestTap = getRequestTap;
  }
  if (getChatStringSize != null) {
    chatStringSize = getChatStringSize;
  }
}

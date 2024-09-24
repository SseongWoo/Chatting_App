import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color/color.dart';
import 'logger.dart';

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

Future<void> setColorShared(String type, Color color) async {
  try {
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
        await prefs.setString(
            'FriendChatStringColor', color.value.toRadixString(16).padLeft(8, '0'));
        break;
      default:
        break;
    }
  } catch (e) {
    logger.e('setColorShared오류 : $e');
  }
}

Future<void> setSizeShared() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('chatStringSize', chatStringSize);
  } catch (e) {
    logger.e('setSizeShared오류 : $e');
  }
}

Future<void> setTapShared() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('homeTap', homeTap);
    await prefs.setInt('requestTap', requestTap);
  } catch (e) {
    logger.e('setTapShared오류 : $e');
  }

  //await prefs.setDouble('chatStringSize', chatStringSize);
  // for (var entry in chatRoomColorMap.entries) {
  //   await prefs.setString(entry.key, entry.value.value.toRadixString(16).padLeft(8, '0'));
  // }
}

Future<void> getTapShared() async {
  try {
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
  } catch (e) {
    logger.e('getTapShared오류 : $e');
  }
}

Future<void> setIDShared(String saveID) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saveID', saveID);
  } catch (e) {
    logger.e('setIDShared오류 : $e');
  }
}

Future<String?> getIDShared() async {
  String? saveID = '';
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    saveID = prefs.getString('saveID');
  } catch (e) {
    logger.e('getIDShared오류 : $e');
  }
  return saveID;
}

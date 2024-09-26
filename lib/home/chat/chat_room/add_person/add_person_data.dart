import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../error/error_screen.dart';
import '../../../../utils/logger.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

// 채팅방에 친구를 초대하능 기능을 가진 함수
Future<void> addNewPeople(String roomUid, List<String> peopleList, List<String> newPeopleList,
    BuildContext context) async {
  try {
    // 채팅방 데이터에 인원 리스트 업데이트
    await FirebaseFirestore.instance.collection('chat').doc(roomUid).update({
      'peoplelist': peopleList,
    });
    await FirebaseFirestore.instance.collection('chat_public').doc(roomUid).update({
      'people': peopleList.length,
    });

    // 초대한 인원들의 데이터에 채팅방데이터를 추가
    for (var item in newPeopleList) {
      await _firestore.collection('users').doc(item).collection('chat').doc(roomUid).set({
        'chatroomuid': roomUid,
        'chatroomcustomprofile': '',
        'chatroomcustomname': '',
        'readablemessage': 0,
      });
    }
  } catch (e) {
    logger.e('addNewPeople오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

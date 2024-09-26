import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/convert_array.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../error/error_screen.dart';
import '../../utils/data_refresh.dart';
import '../../utils/logger.dart';

// 채팅방 데이터 클래스
class ChatRoomData {
  String chatRoomUid;
  String chatRoomName;
  String chatRoomProfile;
  String chatRoomCreateDate;
  String chatRoomManager;
  String chatRoomPassword;
  String chatRoomExplain;
  bool chatRoomPublic;
  List<String> peopleList;

  ChatRoomData(
      this.chatRoomUid,
      this.chatRoomName,
      this.chatRoomProfile,
      this.chatRoomCreateDate,
      this.chatRoomManager,
      this.chatRoomPassword,
      this.chatRoomExplain,
      this.chatRoomPublic,
      this.peopleList);
}

// 채팅방 실시간 데이터 클래스, 채팅방 리스트 화면에서 사용되며 안읽은 메세지 수 마지막 메세지 시간을 화면에 출력 하기 위한 클래스
class ChatRoomRealTimeData {
  String chatRoomUid;
  String lastChatMessage;
  DateTime lastChatTime;
  int readableMessage;

  ChatRoomRealTimeData(
      this.chatRoomUid, this.lastChatMessage, this.lastChatTime, this.readableMessage);
}

// 채팅방 간이 데이터 클래스 사용자 커스텀 데이터를 저장하기 위해 사용되는 클래스
class ChatRoomSimpleData {
  String chatRoomUid;
  String chatRoomCustomProfile;
  String chatRoomCustomName;

  ChatRoomSimpleData(this.chatRoomUid, this.chatRoomCustomProfile, this.chatRoomCustomName);
}

// 전역 변수
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;
Map<String, ChatRoomSimpleData> chatRoomList = {};
Map<String, ChatRoomData> chatRoomDataList = {};
List<String> chatRoomSequence = [];
List<String> groupChatRoomSequence = [];
Map<String, ChatRoomRealTimeData> chatRoomRealTimeData = {};
bool buildState = false;

String sortUid = '';
String lastSortUid = '';

// 서버에서 가져온 사용자의 채팅방 데이터들을 MAP 형태로 저장하는 함수
// 1대1채팅방, 그룹채팅방 나누어서 저장
Future<bool> getChatRoomDataList(BuildContext context) async {
  try {
    DocumentSnapshot documentSnapshot;
    chatRoomDataList.clear();
    for (var uid in chatRoomSequence) {
      documentSnapshot = await _firestore.collection('chat').doc(uid).get();
      chatRoomDataList[documentSnapshot['chatroomuid']] = ChatRoomData(
        documentSnapshot['chatroomuid'],
        documentSnapshot['chatroomname'],
        documentSnapshot['chatroomprofile'],
        documentSnapshot['chatroomcreatedate'],
        documentSnapshot['chatroommanager'],
        documentSnapshot['chatroompassword'],
        documentSnapshot['chatroomexplain'],
        documentSnapshot['chatroompublic'],
        convertList(documentSnapshot['peoplelist']),
      );
    }
    for (var uid in groupChatRoomSequence) {
      documentSnapshot = await _firestore.collection('chat').doc(uid).get();
      chatRoomDataList[documentSnapshot['chatroomuid']] = ChatRoomData(
        documentSnapshot['chatroomuid'],
        documentSnapshot['chatroomname'],
        documentSnapshot['chatroomprofile'],
        documentSnapshot['chatroomcreatedate'],
        documentSnapshot['chatroommanager'],
        documentSnapshot['chatroompassword'],
        documentSnapshot['chatroomexplain'],
        documentSnapshot['chatroompublic'],
        convertList(documentSnapshot['peoplelist']),
      );
    }
    return true;
  } catch (e) {
    logger.e('getChatRoomDataList오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
    return false;
  }
}

// 파이어베이스에 있는 채팅방 데이터를 가져와서 1대1 채팅방과 그룹채팅방을 분류해서 저장하는 함수
Future<bool> getChatRoomData(BuildContext context) async {
  try {
    chatRoomList.clear();
    chatRoomSequence.clear();
    groupChatRoomSequence.clear();
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot =
        await _firestore.collection('users').doc(user?.uid).collection('chat').get();
    List<Map<String, dynamic>> chatRoomData = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
    for (var data in chatRoomData) {
      chatRoomList[data['chatroomuid']] = ChatRoomSimpleData(
          data['chatroomuid'], data['chatroomcustomprofile'] ?? "", data['chatroomcustomname']);

      if (chatRoomList[data['chatroomuid']]!.chatRoomUid.length <= 8) {
        groupChatRoomSequence.add(data['chatroomuid']);
      } else {
        chatRoomSequence.add(data['chatroomuid']);
      }
    }
    return true;
  } catch (e) {
    logger.e('getChatRoomData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
    return false;
  }
}

// 주어진 데이터로 채팅방을 생성하는 함수
Future<void> createChatRoom(ChatRoomData chatRoomData, BuildContext context) async {
  try {
    DateTime dateTime = DateTime.now(); // 채팅방 생성 시간
    // 채팅방 데이터 chat DB에 저장하는 작업
    await _firestore.collection('chat').doc(chatRoomData.chatRoomUid).set({
      'chatroomuid': chatRoomData.chatRoomUid,
      'chatroomname': chatRoomData.chatRoomName,
      'chatroomprofile': chatRoomData.chatRoomProfile,
      'chatroomcreatedate': chatRoomData.chatRoomCreateDate,
      'chatroommanager': chatRoomData.chatRoomManager,
      'chatroompassword': chatRoomData.chatRoomPassword,
      'chatroomexplain': chatRoomData.chatRoomExplain,
      'chatroompublic': chatRoomData.chatRoomPublic,
      'peoplelist': chatRoomData.peopleList,
    });

    await _firestore
        .collection('chat')
        .doc(chatRoomData.chatRoomUid)
        .collection('realtime')
        .doc('_lastmessage_')
        .set({
      'chatroomuid': chatRoomData.chatRoomUid,
      'lastchatmessage': '',
      'lastchattime': dateTime,
    });

    // // 사용자 DB에 채팅방 데이터를 넣는 작업
    // await _firestore
    //     .collection('users')
    //     .doc(myData.myUID)
    //     .collection('chat')
    //     .doc(chatRoomData.chatRoomUid)
    //     .set({
    //   'chatroomuid': chatRoomData.chatRoomUid,
    //   'chatroomcustomprofile': '',
    //   'chatroomcustomname': ''
    // });
    // 채팅방 인원 각각의 DB에 데이터를 저장하는 작업
    for (var item in chatRoomData.peopleList) {
      await _firestore
          .collection('users')
          .doc(item)
          .collection('chat')
          .doc(chatRoomData.chatRoomUid)
          .set({
        'chatroomuid': chatRoomData.chatRoomUid,
        'chatroomcustomprofile': '',
        'chatroomcustomname': '',
        'readablemessage': 0,
      });
      // await _firestore
      //     .collection('chat')
      //     .doc(chatRoomData.chatRoomUid)
      //     .collection('realtime')
      //     .doc(item)
      //     .set({
      //   'readablemessage': 0,
      // });
    }

    await refreshData(context);
  } catch (e) {
    logger.e('createChatRoom오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 채팅방 UID가 중복되는지 확인하는 함수
Future<bool> checkRoomUid(String uid, BuildContext context) async {
  try {
    DocumentSnapshot documentSnapshot = await _firestore.collection('chat').doc(uid).get();
    return documentSnapshot.exists;
  } catch (e) {
    logger.e('checkRoomUid오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
    return false;
  }
}

// 수정된 사용자의 채팅방 커스텀데이터를 서버에 업데이트 하는 함수
Future<void> updateChatData(ChatRoomSimpleData chatRoomSimpleData, BuildContext context) async {
  try {
    await _firestore
        .collection('users')
        .doc(myData.myUID)
        .collection('chat')
        .doc(chatRoomSimpleData.chatRoomUid)
        .update({
      'chatroomcustomprofile': chatRoomSimpleData.chatRoomCustomProfile,
      'chatroomcustomname': chatRoomSimpleData.chatRoomCustomName,
    });
  } catch (e) {
    logger.e('updateChatData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 수정된 채팅방 데이터를 서버에 업데이트 하는 함수
Future<void> updateChatMainData(ChatRoomData chatRoomData, BuildContext context) async {
  try {
    await _firestore.collection('chat').doc(chatRoomData.chatRoomUid).update({
      'chatroomname': chatRoomData.chatRoomName,
      'chatroomprofile': chatRoomData.chatRoomProfile,
      'chatroompassword': chatRoomData.chatRoomPassword,
      'chatroomexplain': chatRoomData.chatRoomExplain,
      'chatroompublic': chatRoomData.chatRoomPublic,
    });
  } catch (e) {
    logger.e('updateChatMainData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 채팅방 실시간 데이터(안읽은 메세지 수, 마지막 메세지 시간 등)를 가져오는 함수
Future<void> getRealTimeData(BuildContext context) async {
  try {
    for (var entry in chatRoomDataList.entries) {
      // 채팅방 마지막 메세지 데이터를 가져오는 기능
      DocumentSnapshot lastMessageData = await _firestore
          .collection('chat')
          .doc(entry.value.chatRoomUid)
          .collection('realtime')
          .doc('_lastmessage_')
          .get();
      // DocumentSnapshot readableMessageData = await _firestore
      //     .collection('chat')
      //     .doc(entry.value.chatRoomUid)
      //     .collection('realtime')
      //     .doc(myData.myUID)
      //     .get();

      // 채팅방 안읽을 메세지 수를 가져오는 기능
      DocumentSnapshot readableMessageData = await _firestore
          .collection('users')
          .doc(myData.myUID)
          .collection('chat')
          .doc(entry.value.chatRoomUid)
          .get();

      // 앞에서 가져온 데이터를 chatRoomRealTimeData 맵리스트에 저장하는 기능
      chatRoomRealTimeData[entry.value.chatRoomUid] = ChatRoomRealTimeData(
          entry.value.chatRoomUid,
          lastMessageData['lastchatmessage'],
          (lastMessageData['lastchattime'] as Timestamp).toDate(),
          readableMessageData['readablemessage']);
    }
  } catch (e) {
    logger.e('getRealTimeData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 채팅방에 입장할때 해당 채팅방에 누적되어있던 안읽은 메세지 수 데이터를 초기화 하는 함수
Future<void> updateRealTimeData(String chatRoomUID, BuildContext context) async {
  try {
    _firestore.collection('users').doc(myData.myUID).collection('chat').doc(chatRoomUID).update({
      'readablemessage': 0,
    });
  } catch (e) {
    logger.e('updateRealTimeData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

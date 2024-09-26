import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../error/error_screen.dart';
import '../../utils/logger.dart';
import '../chat/chat_list_data.dart';

// 친구 데이터 클래스
class FriendData {
  String friendUID;
  String friendEmail;
  String friendNickName;
  String friendProfile;
  String firendDate;
  String friendCustomName;
  String friendInherentChatRoom;
  List<String> category;
  bool bookmark;

  FriendData(
      this.friendUID,
      this.friendEmail,
      this.friendNickName,
      this.friendProfile,
      this.firendDate,
      this.friendCustomName,
      this.friendInherentChatRoom,
      this.category,
      this.bookmark);
}

// 사용자 데이터 클래스
class UserData {
  String uid;
  String email;
  String nickName;
  String profile;

  UserData(
    this.uid,
    this.email,
    this.nickName,
    this.profile,
  );
}

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;
Map<String, FriendData> friendList = {};
Map<String, String> friendListUidKey = {};
List<String> friendListSequence = [];

// 특정 친구 데이터가 DB에 존재하는지 확인하는 함수
Future<bool> checkFriend(String friendUID, BuildContext context) async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(myData.myUID)
        .collection('friend')
        .doc(friendUID)
        .get();
    return documentSnapshot.exists;
  } catch (e) {
    logger.e('checkFriend오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
    return false;
  }
}

// 특정 유저 데이터를 서버의 유저 공개 데이터에서 가져오는 함수
Future<UserData?> getUserData(String friendUID, BuildContext context) async {
  UserData userData;
  try {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users_public').doc(friendUID).get();
    userData = UserData(documentSnapshot['uid'], documentSnapshot['email'],
        documentSnapshot['nickname'], documentSnapshot['profile']);

    return userData;
  } catch (e) {
    logger.e('getUserData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
    return null;
  }
}

// 서버에서 내 모든 친구 데이터를 가져와 리스트에 저장하는 함수
Future<bool> getFriendDataList(BuildContext context) async {
  try {
    friendList.clear();
    friendListUidKey.clear();
    friendListSequence.clear();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(myData.myUID)
        .collection('friend')
        .get();

    for (var doc in querySnapshot.docs) {
      dynamic result = doc.data();
      //List<dynamic> 형식의 리스트를 List<String>형식으로 바꾼뒤 friendList에 넣는 작업
      List<dynamic> categoryDynamicList = result['category'];
      List<String> categoryList = categoryDynamicList.cast<String>();

      friendList[result['friendnickname']] = FriendData(
        result['frienduid'],
        result['friendemail'],
        result['friendnickname'],
        result['friendprofile'],
        result['firenddate'],
        result['friendcustomname'],
        result['friendinherentchatroom'],
        categoryList,
        result['bookmark'],
      );
      friendListUidKey[result['frienduid']] = result['friendnickname'];
      friendListSequence.add(result['friendnickname']);
    }
    friendListSequence.sort();
    return true;
  } catch (e) {
    logger.e('getFriendDataList오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
    return false;
  }
}

// 친구를 삭제하는 함수
Future<void> deleteFriend(BuildContext context, String friendUID) async {
  String roomUid = '';
  try {
    // 서버에 저장되어있는 내 친구 데이터중 상대방 데이터와, 상대방의 친구데이터중 사용자의 데이터를 각각 가져오는 작업
    DocumentSnapshot documentSnapshotMy = await FirebaseFirestore.instance
        .collection('users')
        .doc(myData.myUID)
        .collection('friend')
        .doc(friendUID)
        .get();
    DocumentSnapshot documentSnapshotFriend = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUID)
        .collection('friend')
        .doc(myData.myUID)
        .get();

    // 둘다 해당 데이터가 존재할경우 실행
    if (documentSnapshotMy.exists && documentSnapshotFriend.exists) {
      // 1대1 채팅방 삭제 작업
      roomUid = friendList[friendListUidKey[friendUID]]!.friendInherentChatRoom;

      await _firestore
          .collection('chat')
          .doc(roomUid)
          .collection('realtime')
          .doc('_lastmessage_')
          .delete();
      await _firestore
          .collection('chat')
          .doc(roomUid)
          .collection('realtime')
          .doc(myData.myUID)
          .delete();
      await _firestore
          .collection('chat')
          .doc(roomUid)
          .collection('realtime')
          .doc(friendUID)
          .delete();
      await _firestore.collection('chat').doc(roomUid).delete();

      // 각각의 DB에서 1대1 채팅방 데이터를 삭제하는 작업
      await _firestore
          .collection('users')
          .doc(myData.myUID)
          .collection('chat')
          .doc(roomUid)
          .delete();
      await _firestore.collection('users').doc(friendUID).collection('chat').doc(roomUid).delete();

      // 각각의 DB에서 친구 데이터를 삭제하는 작업
      await _firestore
          .collection('users')
          .doc(myData.myUID)
          .collection('friend')
          .doc(friendUID)
          .delete();
      await _firestore
          .collection('users')
          .doc(friendUID)
          .collection('friend')
          .doc(myData.myUID)
          .delete();

      // 수정된 데이터를 다시 가져와 저장하는 작업
      await getFriendDataList(context);
      await getFriendDataList(context);
      await getChatRoomData(context);
      await getChatRoomDataList(context);
      snackBarMessage(context, '친구가 성공적으로 삭제되었습니다.');
    } else {
      snackBarMessage(context, '친구를 삭제하는 중 오류가 발생했습니다.');
    }
  } catch (e) {
    logger.e('deleteFriend오류 : $e');
    snackBarMessage(context, '친구를 삭제하는 중 오류가 발생했습니다.');
  }
}

// 친구 커스텀 이름을 서버에 업데이트 하는 함수
Future<void> updateFriendName(FriendData friendData, String name, BuildContext context) async {
  try {
    bool check = await checkFriend(friendData.friendUID, context);

    if (check) {
      await _firestore
          .collection('users')
          .doc(myData.myUID)
          .collection('friend')
          .doc(friendData.friendUID)
          .update({
        'friendcustomname': name,
      });
      await getFriendDataList(context);
    }
  } catch (e) {
    logger.e('updateFriendName오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

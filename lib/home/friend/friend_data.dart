import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendData {
  String friendUID;
  String friendEmail;
  String friendNickName;
  String friendProfile;
  String firendDate;
  String friendCustomName;
  List<String> category;
  bool bookmark;

  FriendData(
      this.friendUID,
      this.friendEmail,
      this.friendNickName,
      this.friendProfile,
      this.firendDate,
      this.friendCustomName,
      this.category,
      this.bookmark);
}

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
Map<String, FriendData> friendList = {};
Map<String, String> friendListUidKey = {};
List<String> friendListSequence = [];

Future<bool> checkFriend(String friendUID) async {
  User? user = _auth.currentUser;
  DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(user?.uid)
      .collection("friend")
      .doc(friendUID)
      .get();
  return documentSnapshot.exists;
}

Future<void> getFriendDataList() async {
  try {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("friend")
        .get();
    for (var doc in querySnapshot.docs) {
      dynamic result = doc.data();
      //List<dynamic> 형식의 리스트를 List<String>형식으로 바꾼뒤 friendList에 넣는 작업
      List<dynamic> categoryDynamicList = result['category'];
      List<String> categoryList = categoryDynamicList.cast<String>();

      friendList[result["friendnickname"]] = FriendData(
        result["frienduid"],
        result["friendemail"],
        result["friendnickname"],
        result["friendprofile"],
        result["firenddate"],
        result["friendcustomname"],
        categoryList,
        result["bookmark"],
      );
      friendListUidKey[result["frienduid"]] = result["friendnickname"];
      friendListSequence.add(result["friendnickname"]);
    }
    friendListSequence.sort();
  } catch (e) {
    print('Error fetching users: $e');
  }
}

Future<void> deleteFriend(BuildContext context, String friendUID) async {
  try {
    User? user = _auth.currentUser;
    DocumentSnapshot documentSnapshotMy = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("friend")
        .doc(friendUID)
        .get();
    DocumentSnapshot documentSnapshotFriend = await FirebaseFirestore.instance
        .collection("users")
        .doc(friendUID)
        .collection("friend")
        .doc(user?.uid)
        .get();

    if (user != null &&
        documentSnapshotMy.exists &&
        documentSnapshotFriend.exists) {
      await firestore
          .collection("users")
          .doc(user.uid)
          .collection("friend")
          .doc(friendUID)
          .delete();
      await firestore
          .collection("users")
          .doc(friendUID)
          .collection("friend")
          .doc(user.uid)
          .delete();
      await getFriendDataList();
      snackBarMessage(context, "친구가 성공적으로 삭제되었습니다.");
    } else {
      snackBarMessage(context, "친구를 삭제하는 중 오류가 발생했습니다.");
    }
  } catch (e) {
    print('Error fetching users: $e');
    snackBarMessage(context, "친구를 삭제하는 중 오류가 발생했습니다.");
  }
}

Future<void> updateFriendName(FriendData friendData, String name) async {
  try {
    User? user = _auth.currentUser;
    bool check = await checkFriend(friendData.friendUID);

    if (user != null &&
        check) {
      await firestore
          .collection("users")
          .doc(user.uid)
          .collection("friend")
          .doc(friendData.friendUID)
          .update({
        "friendcustomname": name,
      });
      await getFriendDataList();
    }
  } catch (e) {
    print('updateFriendName에러 $e');
  }
}





import 'dart:io';
import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../error/error_screen.dart';
import '../../../../utils/get_people_data.dart';
import '../../../../utils/logger.dart';
import '../../create_chat/creat_chat_data.dart';
import '../chat_room_data.dart';

// 채팅방 프로필을 사용자 커스텀 프로필 사진을 등록할때 서버에 저장하고 URL을 리턴해주는 함수
Future<String> uploadChatRoomCustomProfile(
    CroppedFile? croppedFile, String chatRoomUid, BuildContext context) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String downloadURL = '';

  Reference ref = storage.ref('/chat/$chatRoomUid/profile').child(myData.myUID);
  try {
    UploadTask uploadTask = ref.putFile(File(croppedFile!.path));
    await uploadTask.then((snapshot) {
      return snapshot.ref.getDownloadURL();
    }).then((url) {
      downloadURL = url;
    });
  } catch (e) {
    logger.e('uploadChatRoomCustomProfile오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
  return downloadURL;
}

// 채팅방을 삭제하는 함수
Future<void> deleteChatRoom(String chatRoomUid, BuildContext context) async {
  try {
    await getChatData(chatRoomUid, context);
    List<ChatPeopleClass> chatPeople = await getPeopleData(chatRoomUid);

    // 채팅방에 있는 인원들 각각의 DB에 있는 채팅방 데이터를 삭제하는 작업
    for (var item in chatPeople) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(item.uid)
          .collection('chat')
          .doc(chatRoomUid)
          .delete();
      // await FirebaseFirestore.instance
      //     .collection('chat')
      //     .doc(chatRoomUid)
      //     .collection('realtime')
      //     .doc(item.uid)
      //     .delete();
    }
    // 채팅방 DB의 하위 문서를 삭제하는 작업
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatRoomUid)
        .collection('realtime')
        .doc('_lastmessage_')
        .delete();

    await FirebaseFirestore.instance.collection('chat_public').doc(chatRoomUid).delete();

    // 모든 채팅내역을 삭제하는 작업
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatRoomUid)
        .collection('chat')
        .get();
    for (DocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    // 채팅방 DB의 필드값과 문서를 삭제
    await FirebaseFirestore.instance.collection('chat').doc(chatRoomUid).delete();

    // 채팅방의 저장된 파일들 삭제
    await FirebaseStorage.instance.ref('/chat/$chatRoomUid/').delete();
  } catch (e) {
    logger.e('deleteChatRoom오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// chat_public위치에 있는 채팅방 데이터 삭제하는 함수
Future<void> deleteChatPublicData(String chatUid, BuildContext context) async {
  try {
    await firestore.collection('chat_public').doc(chatUid).delete();
  } catch (e) {
    logger.e('deleteChatPublicData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 암호를 변경시 암호가 없다가 생겼을 경우, 있다가 없어질 경우 chat_public의 password의 bool값을 업데이트 하는 함수
Future<void> updateChatPublicPassWordData(
    String chatUid, bool password, BuildContext context) async {
  try {
    await firestore.collection('chat_public').doc(chatUid).update({
      'password': password,
    });
  } catch (e) {
    logger.e('updateChatPublicPassWordData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

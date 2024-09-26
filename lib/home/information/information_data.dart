import 'dart:io';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/login/login_screen.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../error/error_screen.dart';
import '../../login/registration/authentication.dart';
import '../../utils/convert_array.dart';
import '../../utils/logger.dart';
import 'information_dialog.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

// 수정된 이름을 기존에 DB에 업데이트 하는 작업
Future<void> updateMyName(String name, BuildContext context) async {
  try {
    await _firestore.collection('users').doc(myData.myUID).update({
      'nickname': name,
    });
    await _firestore.collection('users_public').doc(myData.myUID).update({
      'nickname': name,
    });
    myData.myNickName = name;
  } catch (e) {
    logger.e('updateMyName오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 수정된 프로필 사진을 기존에 있던 프로필사진의 파일에 덮어씌우는 작업과 DB에 등록하는 작업
Future<void> uploadMyProfile(CroppedFile? croppedFile, BuildContext context) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String downloadURL = '';

  Reference ref = storage.ref('/userImage/${myData.myUID}/').child('profileImage');
  try {
    // 프로필 사진의 파일을 파이어베이스 스토리지에 넣는 작업
    UploadTask uploadTask = ref.putFile(File(croppedFile!.path));
    await uploadTask.then((snapshot) {
      return snapshot.ref.getDownloadURL();
    }).then((url) {
      downloadURL = url;
    });

    // 유저 정보 DB에 프로필 업데이트
    await _firestore.collection('users').doc(myData.myUID).update({
      'profile': downloadURL,
    });
    await _firestore.collection('users_public').doc(myData.myUID).update({
      'profile': downloadURL,
    });
    myData.myProfile = downloadURL;
  } catch (e) {
    logger.e('uploadMyProfile오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 이메일 인증을 받은 계정일경우 따로 이메일을 보내지 않고 작업종료
Future<void> checkEmail(
  BuildContext context,
) async {
  User? user = FirebaseAuth.instance.currentUser;
  bool check = await checkEmailVerificationStatus(context);

  if (user != null) {
    if (check) {
      snackBarErrorMessage(context, '이미 이메일 인증을 받은 사용자입니다.');
    } else {
      await user.sendEmailVerification();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EmailCheckDialog();
        },
      );
    }
  } else {
    snackBarErrorMessage(context, '로그인 정보에 오류가 발생하였습니다. 다시 로그인하여 시도해 주세요.');
  }
}

// 계정 삭제 함수
Future<void> deleteUser(BuildContext context) async {
  try {
    //채팅룸에 자동으로 퇴장하기 위해 개인채팅방과 그룹채팅방 uid를 합침
    List<String> sequence = chatRoomSequence + groupChatRoomSequence;
    bool managerCheck = false; // 사용자가 매니저 방이 있는지 확인하는 변수

    // 그룹채팅방에 사용자가 매니저인 방이 있을시에 managerCheck를 true로 하고 계정 삭제 작업을 중지
    for (var item in groupChatRoomSequence) {
      if (chatRoomDataList[item]?.chatRoomManager == myData.myUID) {
        managerCheck = true;
        break;
      }
    }

    // 사용자가 매니저인 방이 없을때 계정 삭제 작업 정상 수행
    if (!managerCheck) {
      // 사용자가 소속되어있는 모든 채팅방에서 사용자를 퇴장 시키는 작업, 개인채팅방일경우 매니저를 상대방에게 넘김
      for (var item in sequence) {
        String manager;
        await _firestore
            .collection('users')
            .doc(myData.myUID)
            .collection('chat')
            .doc(item)
            .delete();
        await _firestore
            .collection('chat')
            .doc(item)
            .collection('realtime')
            .doc(myData.myUID)
            .delete();
        DocumentSnapshot documentSnapshot = await _firestore.collection('chat').doc(item).get();

        List<String> peopleList = convertList(documentSnapshot['peoplelist']);
        peopleList.remove(myData.myUID);

        // 채팅방인원이 사용자 혼자뿐일경우 채팅방 삭제까지 하는 작업 혼자가 아닐경우 채팅방 퇴장만 함,
        // 개인채팅방의 매니저가 사용자일경우 매니저를 상대방에게 넘김
        if (item.length > 8 && peopleList.isNotEmpty) {
          manager = peopleList[0];
          await _firestore
              .collection('chat')
              .doc(item)
              .update({'peoplelist': peopleList, 'chatroommanager': manager});
        } else if (peopleList.isEmpty) {
          QuerySnapshot querySnapshot =
              await _firestore.collection('chat').doc(item).collection('chat').get();
          for (DocumentSnapshot doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
          QuerySnapshot snapshot =
              await _firestore.collection('chat').doc(item).collection('realtime').get();
          for (DocumentSnapshot doc in snapshot.docs) {
            await doc.reference.delete();
          }
        } else {
          await _firestore.collection('chat').doc(item).update({'peoplelist': peopleList});
        }
      }

      // 친구를 삭제하는 작업, 사용자와 상대방의 친구 데이터에서 각각의 데이터를 삭제하는 작업
      for (var entry in friendList.entries) {
        await _firestore
            .collection('users')
            .doc(myData.myUID)
            .collection('friend')
            .doc(entry.value.friendUID)
            .delete();
        await _firestore
            .collection('users')
            .doc(entry.value.friendUID)
            .collection('friend')
            .doc(myData.myUID)
            .delete();
      }
      // 친구 요청 데이터들을 삭제하는 작업
      QuerySnapshot querySnapshotRequest = await FirebaseFirestore.instance
          .collection('users')
          .doc(myData.myUID)
          .collection('request')
          .get();
      for (var doc in querySnapshotRequest.docs) {
        doc.reference.delete();
        // 상대방의 데이터에도 요청데이터 삭제
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('request')
            .doc(myData.myUID)
            .delete();
      }

      await _firestore.collection('users').doc(myData.myUID).delete();
      await _firestore.collection('users_public').doc(myData.myUID).delete();
      await FirebaseStorage.instance.ref('/userImage/${myData.myUID}/profileImage').delete();

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      snackBarMessage(context, '회원탈퇴가 정상적으로 처리되었습니다.');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    } else {
      snackBarErrorMessage(context, '그룹채팅방중 사용자가 방장인 그룹채팅방이 있습니다.\n방장을 위임해주고 다시 시도해주세요');
    }
  } catch (e) {
    logger.e('deleteUser오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

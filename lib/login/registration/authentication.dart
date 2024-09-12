import 'dart:io';
import 'package:chattingapp/login/registration/registration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../home/chat/chat_list_data.dart';
import '../../home/friend/friend_data.dart';
import '../../utils/logger.dart';
import '../../utils/my_data.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

//파이어베이스에 사용자 등록후 이메일 전송
Future<String> createUserWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user!.sendEmailVerification();

    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
      'uid': user?.uid,
      'email': email,
      'creation_time': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'category': {},
      'category_sequence': [],
    });
    await FirebaseFirestore.instance.collection('users_public').doc(user?.uid).set({
      'uid': user?.uid,
      'email': email,
    });

    return '';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      return '이미 사용 중인 이메일입니다.';
    } else if (e.code == 'invalid-email') {
      return '유효하지 않은 이메일 형식입니다.';
    } else {
      logger.e('createUserWithEmailAndPassword오류 : $e');
      return '오류가 발생했습니다: ${e.message}';
    }
  }
}

//파이어베이스에 있는 사용자에게 인증 이메일 발송
Future<void> signInWithVerifyEmailAndPassword(String email, String password) async {
  try {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.sendEmailVerification();
    } else {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();
    }
  } on FirebaseAuthException catch (e) {
    logger.e('signInWithVerifyEmailAndPassword오류 : $e');
  }
}

//로그인
Future<bool> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;
    return true;
  } catch (e) {
    logger.e('signIn오류 : $e');
    return false;
  }
}

// 로그아웃
void signOut() async {
  try {
    await _auth.signOut();
    friendList.clear();
    friendListUidKey.clear();
    friendListSequence.clear();
    chatRoomDataList.clear();
    chatRoomList.clear();
    chatRoomSequence.clear();
    groupChatRoomSequence.clear();
    myData = MyData('', '', '', '', '', {}, []);
  } catch (e) {
    logger.e('signOut오류 : $e');
  }
}

// 이메일 인증 여부 확인
Future<bool> checkEmailVerificationStatus() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // 사용자 데이터 새로 고침
      if (user.emailVerified) {
        return true;
      } else {
        await user.reload();
        if (user.emailVerified) {
          return true;
        }
      }
    }
  } catch (e) {
    logger.e('checkEmailVerificationStatus오류 : $e');
  }
  return false;
}

// 유저 프로필사진 저장하는 함수
Future<void> saveUserImage(CroppedFile? croppedFile, String nickName, BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 파이어베이스 스토리지에 이미지 파일 저장 후 URL획득
      FirebaseStorage storage = FirebaseStorage.instance;
      String downloadURL = '';
      Reference ref = storage.ref('/userImage/${user.uid}').child('profileImage');

      if (croppedFile != null) {
        UploadTask uploadTask = ref.putFile(File(croppedFile!.path));
        await uploadTask.then((snapshot) {
          return snapshot.ref.getDownloadURL();
        }).then((url) {
          downloadURL = url;
        });
      }

      // 데이터 베이스에 저장
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profile': downloadURL,
        'nickname': nickName,
      });
      await FirebaseFirestore.instance.collection('users_public').doc(user.uid).update({
        'profile': downloadURL,
        'nickname': nickName,
      });
      finishRegistration(context);
    }
  } catch (e) {
    logger.e('saveUserImage오류 : $e');
  }
}

// 이메일이 파이어베이스에 등록되어 있는지 확인하는 함수
Future<bool> isEmailRegistered(String email) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: 'temporary_password',
    );
    User? user = FirebaseAuth.instance.currentUser;
    user?.delete(); // 등록되어 있던 이메일이 없을경우에 생긴 계정을 다시 삭제
    return false;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      //이메일이 등록되어 있을경우
      return true;
    } else {
      // 그 외 오류들
      logger.e('isEmailRegistered오류 : $e');
      return false;
    }
  }
}

// 이메일에 비밀번호 재 설정 이메일을 보내는 함수
@override
Future<void> resetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
  } catch (e) {
    logger.e('resetPassword오류 : $e');
  }
}

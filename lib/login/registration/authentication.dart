import 'dart:io';
import 'package:chattingapp/login/registration/registration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

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
      "uid":user?.uid,
      "email": email,
      "creation_time":DateFormat("yyyy-MM-dd").format(DateTime.now()),
      "category":{},
      "category_sequence" : [],
    });
    await FirebaseFirestore.instance.collection('users_public').doc(user?.uid).set({
      "uid":user?.uid,
      "email": email,
    });

    return "";
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      return "이미 사용 중인 이메일입니다.";
    } else if (e.code == 'invalid-email') {
      return "유효하지 않은 이메일 형식입니다.";
    } else {
      return "오류가 발생했습니다: ${e.message}";
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
  } on FirebaseAuthException catch (error) {
    // 실패
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
    // 로그인 실패
    return false;
  }
}

void signOut() async {
  await _auth.signOut();
}


Future<bool> checkEmailVerificationStatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.reload(); // 사용자 데이터 새로 고침
    return user.emailVerified;
  }
  return false;
}

Future<void> saveUserImage(XFile? pickedFile, CroppedFile? croppedFile, String nickName, BuildContext context) async{
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      String downloadURL = "";
      Reference ref = storage.ref("/userImage/${user.uid}").child("profileImage");

      if (pickedFile != null) {
        UploadTask uploadTask = ref.putFile(
            croppedFile == null ? File(pickedFile.path) : File(croppedFile.path)
        );
        await uploadTask.then((snapshot) {
          return snapshot.ref.getDownloadURL();
        }).then((url) {
          downloadURL = url;
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "profile": downloadURL,
        "nickname": nickName,
      });
      await FirebaseFirestore.instance.collection('users_public').doc(user.uid).update({
        "profile": downloadURL,
        "nickname": nickName,
      });
      finishRegistration(context);
    }
  }
  catch(e){
    //오류
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
    user?.delete();                                     // 등록되어 있던 이메일이 없을경우에 생긴 계정을 다시 삭제
    print("삭제 완료");
    return false;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') { //이메일이 등록되어 있을경우
      return true;
    } else {
      return false;
    }
  }
}

// 이메일에 비밀번호 재 설정 이메일을 보내는 함수
@override
Future<void> resetPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}


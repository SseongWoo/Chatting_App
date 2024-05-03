import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';
import 'package:intl/intl.dart';

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
      "profile": "",
      "nickname":"",
      "creation_time":DateFormat("yyyy-MM-dd").format(DateTime.now()),
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
Future<void> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;
  } catch (e) {
    // 로그인 실패
  }
}


Future<bool> checkEmailVerificationStatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.reload(); // 데이터 가져올 때까지 기다림
    if(user.emailVerified){
      return true;
    }
  }
  return false;
}
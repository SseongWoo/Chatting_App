//import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/friend/category/category_data.dart';
import 'convert_array.dart';
import 'logger.dart';

// 사용자의 데이터 클래스
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class MyData {
  String myUID;
  String myEmail;
  String myNickName;
  String myProfile;
  String myDate;
  Map<String, List<String>> myCategory;
  List<String> myCategorySequence;

  MyData(this.myUID, this.myEmail, this.myNickName, this.myProfile, this.myDate, this.myCategory,
      this.myCategorySequence);
}

late MyData myData;

// 사용자의 데이터를 DB에서 가져오는 함수
Future<bool> getMyData() async {
  try {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      categoryList = convertMap(documentSnapshot.get('category'));
      categorySequence = convertList(documentSnapshot.get('category_sequence'));

      myData = MyData(
        documentSnapshot['uid'],
        documentSnapshot['email'],
        documentSnapshot['nickname'],
        documentSnapshot['profile'],
        documentSnapshot['creation_time'],
        categoryList,
        categorySequence,
      );
      return true;
    }
  } catch (e) {
    logger.e('getMyData오류 : $e');
  }
  return false;
}

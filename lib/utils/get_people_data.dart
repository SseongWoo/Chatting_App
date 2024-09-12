import 'package:chattingapp/utils/convert_array.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/chat/create_chat/creat_chat_data.dart';

// 입력받은 uid의 채팅방의 인원의 데이터를 리스트형태로 반환해주는 함수
Future<List<ChatPeopleClass>> getPeopleData(String roomUid) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<ChatPeopleClass> chatPeopleClassList = [];

  DocumentSnapshot roomData = await firestore.collection('chat').doc(roomUid).get();
  List<String> peopleList = convertList(roomData['peoplelist']);

  for (var uid in peopleList) {
    DocumentSnapshot documentSnapshot = await firestore.collection('users_public').doc(uid).get();
    chatPeopleClassList.add(ChatPeopleClass(documentSnapshot['email'], documentSnapshot['nickname'],
        documentSnapshot['profile'], documentSnapshot['uid']));
  }
  return chatPeopleClassList;
}

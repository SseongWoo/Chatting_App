import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/convert_array.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

class ChatRoomSimpleData {
  String chatRoomUid;
  String chatRoomCustomProfile;
  String chatRoomCustomName;
  String lastChatMessage;
  int readableMessage;
  DateTime lastChatTime;

  ChatRoomSimpleData(this.chatRoomUid, this.chatRoomCustomProfile, this.chatRoomCustomName,
      this.lastChatMessage, this.readableMessage, this.lastChatTime);
}

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;
Map<String, ChatRoomSimpleData> chatRoomList = {};
List<String> chatRoomSequence = [];
Map<String, ChatRoomData> chatRoomDataList = {};
List<String> chatRoomDataSequence = [];

Future<void> getChatRoomDataList() async {
  DocumentSnapshot documentSnapshot;
  chatRoomDataList.clear();
  chatRoomDataSequence.clear();
  for (var uid in chatRoomSequence) {
    documentSnapshot = await _firestore.collection('chat').doc(uid).get();
    chatRoomDataList[documentSnapshot['chatroomuid']] = ChatRoomData(
      documentSnapshot['chatroomuid'],
      documentSnapshot['chatroomprofile'],
      documentSnapshot['chatroomname'],
      documentSnapshot['chatroomcreatedate'],
      documentSnapshot['chatroommanager'],
      documentSnapshot['chatroompassword'],
      documentSnapshot['chatroomexplain'],
      documentSnapshot['chatroompublic'],
      convertList(documentSnapshot['peoplelist']),
    );
    chatRoomDataSequence.add(documentSnapshot['chatroomuid']);
  }
}

// 파이어베이스에 있는 채팅방 데이터를 가져오는 함수
Future<void> getChatRoomData() async {
  chatRoomList.clear();
  chatRoomSequence.clear();
  User? user = _auth.currentUser;
  QuerySnapshot querySnapshot =
      await _firestore.collection('users').doc(user?.uid).collection('chat').get();
  List<Map<String, dynamic>> chatRoomData = querySnapshot.docs.map((doc) {
    return doc.data() as Map<String, dynamic>;
  }).toList();
  for (var data in chatRoomData) {
    chatRoomList[data['chatroomuid']] = ChatRoomSimpleData(
        data['chatroomuid'],
        data['chatroomprofile'] ?? "",
        data['chatroomcustomname'],
        data['lastchatmessage'] ?? "",
        data['readablemessage'],
        (data['lastchattime'] as Timestamp).toDate());
    chatRoomSequence.add(data['chatroomuid']);
  }
}

Future<void> createChatRoom(ChatRoomData chatRoomData) async {
  try {
    DateTime dateTime = DateTime.now();

    // 채팅방 생성 작업
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

    // 내 DB에 채팅방 데이터를 넣는 작업
    await _firestore
        .collection('users')
        .doc(myData.myUID)
        .collection('chat')
        .doc(chatRoomData.chatRoomUid)
        .set({
      'chatroomuid': chatRoomData.chatRoomUid,
      'chatroomcustomprofile': chatRoomData.chatRoomProfile,
      'chatroomcustomname': chatRoomData.chatRoomName,
      'lastchatmessage': '',
      'readablemessage': 0,
      'lastchattime': dateTime,
    });

    // 채팅방 인원 각각의 DB에 데이터를 저장하는 작업
    for (var item in chatRoomData.peopleList) {
      await _firestore
          .collection('users')
          .doc(item)
          .collection('chat')
          .doc(chatRoomData.chatRoomUid)
          .set({
        'chatroomuid': chatRoomData.chatRoomUid,
        'chatroomcustomprofile': chatRoomData.chatRoomProfile,
        'chatroomcustomname': chatRoomData.chatRoomName,
        'lastchatmessage': '',
        'readablemessage': 0,
        'lastchattime': dateTime,
      });
    }

    await getChatRoomData();
    await getChatRoomDataList();
  } catch (e) {
    print('createInherentChatRoom오류: $e');
  }
}

// 채팅방 UID가 중복되는지 확인하는 함수
Future<bool> checkRoomUid(String uid) async {
  try {
    DocumentSnapshot documentSnapshot = await _firestore.collection('chat').doc(uid).get();

    return documentSnapshot.exists;
  } catch (e) {
    print('Error checking document existence: $e');
    return false;
  }
}

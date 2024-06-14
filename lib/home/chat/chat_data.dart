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
  Map<String, String> peopleList;

  ChatRoomData(this.chatRoomUid, this.chatRoomName, this.chatRoomProfile, this.chatRoomCreateDate,
      this.chatRoomManager, this.chatRoomPassword, this.peopleList);
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
        convertMap2(documentSnapshot['peoplelist']));
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

// // 1대1 채팅 생성
// Future<void> createInherentChatRoom(FriendData friendData) async {
//   try {
//     User? user = _auth.currentUser;
//     // 채팅방 고유 id 생성작업
//     CollectionReference collection = _firestore.collection('chat');
//     String documentID = collection.doc().id;
//     ChatRoomSimpleData chatRoomSimpleData = ChatRoomSimpleData(
//         documentID, "", "${myData.myNickName},${friendData.friendNickName}", "", 0, DateTime.now());
//
//     chatRoomList[documentID] = chatRoomSimpleData;
//     Map<String, String> peopleList = {
//       myData.myUID: myData.myNickName,
//       friendData.friendUID: friendData.friendNickName
//     };
//     // Map<String, String> peopleList = {};
//     // peopleList[myData.myUID] = myData.myNickName;
//     // peopleList[friendData.friendUID] = friendData.friendNickName;
//
//     // 채팅방 생성 작업
//     await _firestore.collection('chat').doc(documentID).set({
//       'chatroomuid': documentID,
//       'chatroomname': "${myData.myNickName},${friendData.friendNickName}",
//       'chatroomprofile': "",
//       'chatroomcreatedate': DateFormat("yyyy-MM-dd").format(DateTime.now()),
//       'chatroommanager': myData.myNickName,
//       'chatroompassword': "",
//       'peoplelist': peopleList,
//     });
//
//     print("2-3");
//     // 채팅방 개인데이터를 개인DB에 저장하기 위한 작업 1
//     await _firestore.collection('users').doc(user?.uid).collection('chat').doc(documentID).set({
//       'chatroomuid': chatRoomSimpleData.chatRoomUid,
//       'chatroomcustomprofile': chatRoomSimpleData.chatRoomCustomProfile,
//       'chatroomcustomname': chatRoomSimpleData.chatRoomCustomName,
//       'lastchatmessage': chatRoomSimpleData.lastChatMessage,
//       'readablemessage': chatRoomSimpleData.readableMessage,
//       'lastchattime': chatRoomSimpleData.lastChatTime,
//     });
//
//     // 채팅방 개인데이터를 상대방 DB에 저장하기 위한 작업 1
//     await _firestore
//         .collection('users')
//         .doc(friendData.friendUID)
//         .collection('chat')
//         .doc(documentID)
//         .set({
//       'chatroomuid': chatRoomSimpleData.chatRoomUid,
//       'chatroomcustomprofile': chatRoomSimpleData.chatRoomCustomProfile,
//       'chatroomcustomname': chatRoomSimpleData.chatRoomCustomName,
//       'lastchatmessage': chatRoomSimpleData.lastChatMessage,
//       'readablemessage': chatRoomSimpleData.readableMessage,
//       'lastchattime': chatRoomSimpleData.lastChatTime,
//     });
//
//     // 채팅방 개인데이터를 개인DB에 저장하기 위한 작업 2
//     await _firestore
//         .collection('users')
//         .doc(user?.uid)
//         .collection('friend')
//         .doc(friendData.friendUID)
//         .update({
//       'friendinherentchatroom': documentID,
//     });
//
//     // 채팅방 개인데이터를 상대방 DB에 저장하기 위한 작업 2
//     await _firestore
//         .collection('users')
//         .doc(friendData.friendUID)
//         .collection('friend')
//         .doc(user?.uid)
//         .update({
//       'friendinherentchatroom': documentID,
//     });
//   } catch (e) {
//     print('createInherentChatRoom오류: $e');
//   }
// }

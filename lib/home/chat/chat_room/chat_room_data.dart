import 'dart:io';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../error/error_screen.dart';
import '../../../utils/logger.dart';
import '../../friend/friend_data.dart';

// 채팅방 메세지 데이터 클래스
class MessageDataClass {
  String messageUid; // 메세지 uid
  String message; // 메세지 내용
  String userUid; // 해당 메세지를 보낸 유저의 uid
  String userName; // 해당 메세지를 보낸 유저의 이름
  String userProfile; // 해당 메세지를 보낸 유저의 프로필
  String messageType; // 메세지 타입
  DateTime timestamp; // 메세지를 보낸 시간

  MessageDataClass(this.messageUid, this.message, this.userUid, this.userName, this.userProfile,
      this.messageType, this.timestamp);
}

FirebaseFirestore _firestore = FirebaseFirestore.instance;
List<MessageDataClass> messageList = []; // 채팅방 메세지 리스트
late DocumentSnapshot lastMessageData;
Map<String, int> messageMapData =
    {}; // 채팅방 메세지 맵 데이터 채팅방 화면에서 실시간으로 정보를 가져올때 중복되지 않게 가져오기 위해 사용하는 변수
var uuid = const Uuid(); // uuid를 생성하기 위한 uuid객체를 할당한 변수

//DB에 저장된 채팅방 메세지중 최근 메세지 50건만 가져와서 리스트에 저장하는 함수
Future<void> getChatData(String chatRoomUID, BuildContext context) async {
  int count = 0;
  try {
    await _firestore
        .collection('chat')
        .doc(chatRoomUID)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get()
        .then((QuerySnapshot querySnapshot) {
      messageList.clear();
      messageMapData.clear();
      for (var doc in querySnapshot.docs) {
        messageList.add(MessageDataClass(
            doc['messageid'],
            doc['message'],
            doc['useruid'],
            doc['username'],
            doc['userprofile'],
            doc['messagetype'],
            (doc['timestamp'] as Timestamp).toDate()));
        messageMapData[doc['messageid']] = count;

        if (count == 49) {
          lastMessageData = doc;
        }
        count++;
      }
    });
  } catch (e) {
    logger.e('getChatData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

//사용자가 채팅방을 끝까지 올렸을때 새롭개 50개의 메세지를 더 추가로 불러오는 함수
Future<void> getChatDataAfter(String chatRoomUID, BuildContext context) async {
  int count = 0;
  try {
    await _firestore
        .collection('chat')
        .doc(chatRoomUID)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastMessageData)
        .limit(50)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        messageList.add(MessageDataClass(
            doc['messageid'],
            doc['message'],
            doc['useruid'],
            doc['username'],
            doc['userprofile'],
            doc['messagetype'],
            (doc['timestamp'] as Timestamp).toDate()));
        messageMapData[doc['messageid']] = count;

        if (count == 49) {
          lastMessageData = doc;
        }
        count++;
      }
    });
  } catch (e) {
    logger.e('getChatDataAfter오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 메세지 데이터를 DB에 저장하기 위한 함수
Future<void> setChatData(String chatRoomUID, String message, String messagetype, DateTime dateTime,
    BuildContext context) async {
  try {
    CollectionReference collection =
        _firestore.collection('chat').doc(chatRoomUID).collection('chat');
    String documentID = collection.doc().id;

    await collection.doc(documentID).set({
      'messageid': documentID,
      'message': message,
      'useruid': myData.myUID,
      'username': myData.myNickName,
      'userprofile': myData.myProfile,
      'messagetype': messagetype,
      'timestamp': dateTime,
    });
  } catch (e) {
    logger.e('setChatData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 메세지를 보낸 사람이 유저의 친구중 있을경우 해당 유저의 커스텀 이름이 존재할때 이름을 커스텀이름으로 변경
String getName(MessageDataClass messageDataClass) {
  if (friendList.containsKey(messageDataClass.userName) &&
      friendList[messageDataClass.userName]!.friendCustomName.isNotEmpty) {
    return friendList[messageDataClass.userName]!.friendCustomName;
  } else {
    return messageDataClass.userName;
  }
}

// 채팅방에 이미지를 보낼때 서버에 이미지를 저장하고 받는 url을 리턴하는 함수
Future<String> uploadChatImage(
    CroppedFile? croppedFile, String chatRoomUid, BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = '';

  Reference ref = storage.ref('/chat/$chatRoomUid/image').child(randomId);
  try {
    if (user != null) {
      if (croppedFile != null) {
        UploadTask uploadTask = ref.putFile(File(croppedFile.path));
        await uploadTask.then((snapshot) {
          return snapshot.ref.getDownloadURL();
        }).then((url) {
          downloadURL = url;
        });
      }
    }
  } catch (e) {
    logger.e('uploadChatImage오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
  return downloadURL;
}

// 채팅방에 비디오를 보낼때 서버에 비디오를 저장하고 받는 url을 리턴하는 함수
Future<String> uploadChatVideo(XFile xfile, String chatRoomUid, BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = '';

  Reference ref = storage.ref('/chat/$chatRoomUid/video').child(randomId);
  try {
    if (user != null) {
      UploadTask uploadTask = ref.putFile(File(xfile.path));
      await uploadTask.then((snapshot) {
        return snapshot.ref.getDownloadURL();
      }).then((url) {
        downloadURL = url;
      });
    }
  } catch (e) {
    logger.e('uploadChatVideo오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
  return downloadURL;
}

// 채팅방에 여러 이미지를 보낼때 서버에 이미지를 저장하고 받는 url을 리턴하는 함수
Future<String> uploadChatMultiImage(XFile xfile, String chatRoomUid, BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = '';

  Reference ref = storage.ref('/chat/$chatRoomUid/image').child(randomId);
  try {
    if (user != null) {
      UploadTask uploadTask = ref.putFile(File(xfile.path));
      await uploadTask.then((snapshot) {
        return snapshot.ref.getDownloadURL();
      }).then((url) {
        downloadURL = url;
      });
    }
  } catch (e) {
    logger.e('uploadChatMultiImage오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
  return downloadURL;
}

// 채팅방에 여러 이미지를 보낼때 서버에 이미지를 저장하고 받는 url을 리턴하는 함수
Future<String> uploadChatMultiImageV2(
    XFile xfile, String chatRoomUid, String type, BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = '';

  Reference ref = storage.ref('/chat/$chatRoomUid/$type').child(randomId);
  try {
    if (user != null) {
      UploadTask uploadTask = ref.putFile(File(xfile.path));
      await uploadTask.then((snapshot) {
        return snapshot.ref.getDownloadURL();
      }).then((url) {
        downloadURL = url;
      });
    }
  } catch (e) {
    logger.e('uploadChatMultiImageV2오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
  return downloadURL;
}

// 채팅방을 나갈때 채팅방 DB안에 있는 사용자의 데이터와 사용자 DB안에 있는 채팅방 데이터를 삭제하는 함수
Future<void> leaveChatRoom(String chatRoomUid, BuildContext context) async {
  try {
    DateTime dateTime = DateTime.now();
    ChatRoomData? chatRoomData = chatRoomDataList[chatRoomUid];
    List<String>? peopleList = chatRoomData!.peopleList;
    peopleList.remove(myData.myUID);

    // 채팅방 인원 변경
    await FirebaseFirestore.instance.collection('chat').doc(chatRoomUid).update({
      'peoplelist': peopleList,
    });

    // 유저 DB의 채팅방 데이터 삭제
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myData.myUID)
        .collection('chat')
        .doc(chatRoomUid)
        .delete();

    // await FirebaseFirestore.instance
    //     .collection('chat')
    //     .doc(chatRoomUid)
    //     .collection('realtime')
    //     .doc(myData.myUID)
    //     .delete();

    // 사용자의 채팅방 커스텀 프로필 삭제
    await FirebaseStorage.instance.ref('/chat/$chatRoomUid/').delete();
    // 채팅방에 퇴장 시스템 메세지 생성
    await setChatData(chatRoomUid, '${myData.myNickName}님이 퇴장하였습니다.', 'system', dateTime, context);
    await setChatRealTimeData(
        peopleList, chatRoomUid, '${myData.myNickName}님이 퇴장하였습니다.', dateTime, context);
  } catch (e) {
    logger.e('leaveChatRoom오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 채팅방의 매니저를 변경하는 함수
Future<void> managerDelegation(String roomUid, String delegationUid, BuildContext context) async {
  try {
    await _firestore.collection('chat').doc(roomUid).update({'chatroommanager': delegationUid});
  } catch (e) {
    logger.e('managerDelegation오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// 채팅방 리스트 화면에서 메세지 미리보기와 안읽은 메세지 숫자를 나타내기 위해 DB에 업데이트 하는 함수
Future<void> setChatRealTimeData(List<String> chatPeopleList, String chatRoomUID, String message,
    DateTime dateTime, BuildContext context) async {
  try {
    // 채팅방의 마지막 메세지와 시간을 업데이트
    await _firestore
        .collection('chat')
        .doc(chatRoomUID)
        .collection('realtime')
        .doc('_lastmessage_')
        .update({
      'lastchatmessage': message,
      'lastchattime': dateTime,
    });

    // 채팅방에 있는 유저들의 안읽은 메세지 숫자를 업데이트
    for (var member in chatPeopleList) {
      if (member != myData.myUID) {
        _firestore.collection('users').doc(member).collection('chat').doc(chatRoomUID).update({
          'readablemessage': FieldValue.increment(1),
        });
      }
    }
  } catch (e) {
    logger.e('setChatRealTimeData오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

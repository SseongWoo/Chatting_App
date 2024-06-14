import 'dart:io';

import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../friend/friend_data.dart';

class MessageDataClass {
  String messageUid;
  String message;
  String userUid;
  String userName;
  String userProfile;
  String messageType;
  DateTime timestamp;

  MessageDataClass(this.messageUid, this.message, this.userUid, this.userName, this.userProfile,
      this.messageType, this.timestamp);
}

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;
List<MessageDataClass> messageList = [];
Map<String, int> messageMapData = {};
var uuid = const Uuid();

Future<void> getChatData(String chatRoomUID) async {
  int count = 0;
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
      count++;
    }
  });
}

Future<void> setChatData(String chatRoomUID, String message, String messagetype) async {
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
      'timestamp': DateTime.now()
    });
  } catch (e) {
    print('setChatData오류');
  }
}

String getName(MessageDataClass messageDataClass) {
  if (friendList.containsKey(messageDataClass.userName) &&
      friendList[messageDataClass.userName]!.friendCustomName.isNotEmpty) {
    return friendList[messageDataClass.userName]!.friendCustomName;
  } else {
    return messageDataClass.userName;
  }
}

Future<String> uploadChatImage(CroppedFile? croppedFile, String chatRoomUid) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = "";

  Reference ref = storage.ref("/chat/$chatRoomUid/image").child(randomId);
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
    //오류
    print("saveUserImage오류 : $e");
  }
  return downloadURL;
}

Future<String> uploadChatVideo(XFile xfile, String chatRoomUid) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = "";

  Reference ref = storage.ref("/chat/$chatRoomUid/video").child(randomId);
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
    //오류
    print("uploadChatVideo오류 : $e");
  }
  return downloadURL;
}

Future<String> uploadChatMultiImage(XFile xfile, String chatRoomUid) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = "";

  Reference ref = storage.ref("/chat/$chatRoomUid/image").child(randomId);
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
    //오류
    print("uploadChatMultipleMedia오류 : $e");
  }
  return downloadURL;
}

Future<String> uploadChatMultiImageV2(XFile xfile, String chatRoomUid, String type) async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String randomId = uuid.v4();
  String downloadURL = "";

  Reference ref = storage.ref("/chat/$chatRoomUid/$type").child(randomId);
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
    //오류
    print("uploadChatMultipleMedia오류 : $e");
  }
  return downloadURL;
}

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/logger.dart';
import '../chat_list_data.dart';

class ChatPeopleClass {
  String email;
  String name;
  String profile;
  String uid;

  ChatPeopleClass(this.email, this.name, this.profile, this.uid);
}

// 채팅룸 uid를 랜덤값으로 생성하고 8글자로 리턴시키는 함수
String createRandomCode() {
  Random random = Random();
  var uuid = const Uuid();
  String fullUuid = uuid.v4();
  int rand = random.nextInt(fullUuid.length - 9);
  String shortUuid = fullUuid.substring(rand, rand + 8); // 첫 8문자 사용

  return shortUuid;
}

// 채팅방을 생성할때 프로필 사진을 서버에 저장하고 프로필 사진의 url을 리턴하는 함수
Future<String> uploadChatRoomProfile(CroppedFile? croppedFile, String chatRoomUid) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String downloadURL = '';

  Reference ref = storage.ref('/chat/$chatRoomUid/profile').child('profile');
  try {
    UploadTask uploadTask = ref.putFile(File(croppedFile!.path));
    await uploadTask.then((snapshot) {
      return snapshot.ref.getDownloadURL();
    }).then((url) {
      downloadURL = url;
    });
  } catch (e) {
    logger.e('uploadChatRoomProfile오류 : $e');
  }
  return downloadURL;
}

// 채팅방을 생성할 때 공개설정을 공개로 했을 경우 채팅방 공개데이터에 채팅방데이터를 등록하는 함수
Future<void> setChatPublicData(ChatRoomData chatRoomData) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isPassword = false;
  try {
    if (chatRoomData.chatRoomPassword.isNotEmpty) {
      isPassword = true;
    } else {
      isPassword = false;
    }

    await firestore.collection('chat_public').doc(chatRoomData.chatRoomUid).set({
      'chatroomuid': chatRoomData.chatRoomUid,
      'chatroomname': chatRoomData.chatRoomName,
      'chatroomprofile': chatRoomData.chatRoomProfile,
      'chatroomexplain': chatRoomData.chatRoomExplain,
      'people': chatRoomData.peopleList.length,
      'password': isPassword,
    });
  } catch (e) {
    logger.e('setChatPublicData오류 : $e');
  }
}

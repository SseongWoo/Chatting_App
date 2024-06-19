import 'dart:io';

import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../utils/get_people_data.dart';
import '../../create_chat/creat_chat_data.dart';
import '../chat_room_data.dart';

Future<String> uploadChatRoomCustomProfile(CroppedFile? croppedFile, String chatRoomUid) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String downloadURL = "";

  Reference ref = storage.ref("/chat/$chatRoomUid/profile").child(myData.myUID);
  try {
    UploadTask uploadTask = ref.putFile(File(croppedFile!.path));
    await uploadTask.then((snapshot) {
      return snapshot.ref.getDownloadURL();
    }).then((url) {
      downloadURL = url;
    });
  } catch (e) {
    //오류
    print("uploadChatMultipleMedia오류 : $e");
  }
  return downloadURL;
}

Future<void> deleteChatRoom(String chatRoomUid) async {
  await getChatData(chatRoomUid);
  List<ChatPeopleClass> chatPeople = await getPeopleData(chatRoomUid);

  for (var item in chatPeople) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(item.uid)
        .collection('chat')
        .doc(chatRoomUid)
        .delete();
  }
  await FirebaseFirestore.instance.collection('chat').doc(chatRoomUid).delete();
  try {
    await FirebaseStorage.instance.ref('/chat/$chatRoomUid/').delete();
  } catch (e) {
    //
  }
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';

class ChatPeopleClass {
  String email;
  String name;
  String profile;
  String uid;

  ChatPeopleClass(this.email, this.name, this.profile, this.uid);
}

Future<String> uploadChatRoomProfile(CroppedFile? croppedFile, String chatRoomUid) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  String downloadURL = "";

  Reference ref = storage.ref('/chat/$chatRoomUid/profile').child('profile');
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

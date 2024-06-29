import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> addNewPeople(
    String roomUid, List<String> peopleList, List<String> newPeopleList) async {
  await FirebaseFirestore.instance.collection('chat').doc(roomUid).update({
    'peoplelist': peopleList,
  });

  for (var item in newPeopleList) {
    await _firestore.collection('chat').doc(roomUid).collection('realtime').doc(item).set({
      'readablemessage': 0,
    });
    await _firestore.collection('users').doc(item).collection('chat').doc(roomUid).set({
      'chatroomuid': roomUid,
      'chatroomcustomprofile': '',
      'chatroomcustomname': '',
    });
  }
}

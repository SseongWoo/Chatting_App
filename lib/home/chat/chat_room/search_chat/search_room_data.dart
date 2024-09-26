import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../error/error_screen.dart';
import '../../../../utils/convert_array.dart';
import '../../../../utils/data_refresh.dart';
import '../../../../utils/get_people_data.dart';
import '../../../../utils/logger.dart';
import '../../chat_list_data.dart';
import '../../create_chat/creat_chat_data.dart';
import '../chat_room_data.dart';
import '../chat_room_screen.dart';

// 채팅방 공개 데이터 클래스
class ChatRoomPublicData {
  String chatRoomUid; // 채팅방 uid
  String chatRoomProfile; // 채팅방 프로필이미지 링크
  String chatRoomName; // 채팅방 이름
  String chatRoomExplain; // 채팅방 설명
  int people; // 채팅방 인원수
  bool password; // 채팅방 비밀번호 유무

  ChatRoomPublicData(this.chatRoomUid, this.chatRoomProfile, this.chatRoomName,
      this.chatRoomExplain, this.people, this.password);
}

FirebaseFirestore _firestore = FirebaseFirestore.instance;

// 채팅방의 비밀번호를 가져오는 함수
Future<String> getPassword(ChatRoomPublicData chatRoomPublicData, BuildContext context) async {
  String password = '';
  try {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('chat').doc(chatRoomPublicData.chatRoomUid).get();
    password = documentSnapshot['chatroompassword'];
  } catch (e) {
    logger.e('getPassword오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
  return password;
}

// 채팅방에 새로 입장할떄 DB에 데이터를 새로 저장하거나 변경하는 함수
Future<void> enterChatRoom(ChatRoomPublicData chatRoomPublicData, BuildContext context) async {
  try {
    DateTime dateTime = DateTime.now();
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('chat').doc(chatRoomPublicData.chatRoomUid).get();
    List<String> peopleList = convertList(documentSnapshot['peoplelist']);
    peopleList.add(myData.myUID);

    // 채팅방 인원 리스트, 인원수 변경
    await FirebaseFirestore.instance.collection('chat').doc(chatRoomPublicData.chatRoomUid).update({
      'peoplelist': peopleList,
    });
    await FirebaseFirestore.instance
        .collection('chat_public')
        .doc(chatRoomPublicData.chatRoomUid)
        .update({
      'people': peopleList.length,
    });

    // 내 DB에 채팅방 데이터 저장
    await _firestore
        .collection('users')
        .doc(myData.myUID)
        .collection('chat')
        .doc(chatRoomPublicData.chatRoomUid)
        .set({
      'chatroomuid': chatRoomPublicData.chatRoomUid,
      'chatroomcustomprofile': '',
      'chatroomcustomname': '',
      'readablemessage': 0,
    });

    // 채팅방에 입장 시스템 메세지 입력
    await setChatData(chatRoomPublicData.chatRoomUid, '${myData.myNickName}님이 입장하였습니다.', 'system',
        dateTime, context);
    await setChatRealTimeData(peopleList, chatRoomPublicData.chatRoomUid,
        '${myData.myNickName}님이 입장하였습니다.', dateTime, context);

    // 로컬데이터 새로 갱신
    await refreshData(context);
  } catch (e) {
    logger.e('enterChatRoom오류 : $e');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: e.toString())),
        (route) => false);
  }
}

// enterChatRoom 함수를 실행 뒤 해당 채팅방으로 화면이 이동하게 하는 함수
Future<void> moveChatRoom(BuildContext context, ChatRoomPublicData chatRoomPublicData) async {
  await enterChatRoom(chatRoomPublicData, context);
  // 채팅방 인원 데이터 가져오기
  List<ChatPeopleClass> chatPeople = await getPeopleData(chatRoomPublicData.chatRoomUid);
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          chatRoomSimpleData: chatRoomList[chatRoomPublicData.chatRoomUid]!,
          chatPeopleList: chatPeople,
        ),
      ),
      (route) => false);
}

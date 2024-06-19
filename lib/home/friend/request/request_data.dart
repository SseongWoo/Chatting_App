import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/my_data.dart';
import '../../chat/chat_data.dart';
import '../friend_data.dart';

class RequestData {
  String requestUID;
  String requestEmail;
  String requestNickName;
  String requestProfile;
  String requestTime;
  String requestKey; //보낸요청인지 받은요청인지 구분하는 변수
  bool requestCheck; //상대방이 수락했는지 거절했는지 확인하는 변수 false일시 기본상태
  bool deleteCheck; //본인이 요청을 삭제했는지 확인하는 변수 true일시 삭제

  RequestData(this.requestUID, this.requestEmail, this.requestNickName, this.requestProfile,
      this.requestTime, this.requestKey, this.requestCheck, this.deleteCheck);
}

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;
List<RequestData> requestSendList = []; //보낸 요청 리스트
List<RequestData> requestReceivedList = []; //받은 요청 리스트

// 나와 상대방의 친구리스트에 각각의 정보를 입력하는 기능
Future<void> addFriendRequest(String friendUID, BuildContext context) async {
  try {
    FriendData? friendData;
    friendData = await getRequestFriendData(friendUID);
    String dateTime = DateFormat("yyyy-MM-dd").format(DateTime.now());
    bool friendCheck = await checkFriend(friendData!.friendUID); // 파이어베이스의 본인의 친구목록에 있는지 확인하는 변수
    List<String> category = [];

    CollectionReference creatCollectionUid = _firestore.collection('chat');
    String documentID = creatCollectionUid.doc().id;
    ChatRoomSimpleData chatRoomSimpleData = ChatRoomSimpleData(
        documentID, "", "${myData.myNickName},${friendData.friendNickName}", "", 0, DateTime.now());
    chatRoomList[documentID] = chatRoomSimpleData;
    Map<String, String> peopleList = {
      myData.myUID: myData.myNickName,
      friendData.friendUID: friendData.friendNickName
    };

    if (!friendCheck) {
      await _firestore
          .collection("users")
          .doc(myData.myUID)
          .collection("friend")
          .doc(friendData.friendUID)
          .set({
        "frienduid": friendData.friendUID,
        "friendemail": friendData.friendEmail,
        "friendprofile": friendData.friendProfile,
        "friendnickname": friendData.friendNickName,
        "firenddate": dateTime,
        "friendcustomname": "",
        "friendinherentchatroom": documentID,
        "category": category,
        "bookmark": false,
      });
      await _firestore
          .collection("users")
          .doc(friendData.friendUID)
          .collection("friend")
          .doc(myData.myUID)
          .set({
        "frienduid": myData.myUID,
        "friendemail": myData.myEmail,
        "friendprofile": myData.myProfile,
        "friendnickname": myData.myNickName,
        "firenddate": dateTime,
        "friendcustomname": "",
        "friendinherentchatroom": documentID,
        "category": category,
        "bookmark": false,
      });

      // 채팅방 생성 작업
      await _firestore.collection('chat').doc(documentID).set({
        'chatroomuid': documentID,
        'chatroomname': '${myData.myNickName},${friendData.friendNickName}',
        'chatroomprofile': '',
        'chatroomcreatedate': DateFormat("yyyy-MM-dd").format(DateTime.now()),
        'chatroommanager': myData.myNickName,
        'chatroompassword': '',
        'chatroomexplain': '',
        'chatroompublic': false,
        'peoplelist': peopleList,
      });

      await _firestore
          .collection('users')
          .doc(myData.myUID)
          .collection('chat')
          .doc(documentID)
          .set({
        'chatroomuid': chatRoomSimpleData.chatRoomUid,
        'chatroomcustomprofile': friendData.friendProfile,
        'chatroomcustomname': friendData.friendNickName,
        'lastchatmessage': chatRoomSimpleData.lastChatMessage,
        'readablemessage': chatRoomSimpleData.readableMessage,
        'lastchattime': chatRoomSimpleData.lastChatTime,
      });

      // 채팅방 개인데이터를 상대방 DB에 저장하기 위한 작업 1
      await _firestore
          .collection('users')
          .doc(friendData.friendUID)
          .collection('chat')
          .doc(documentID)
          .set({
        'chatroomuid': chatRoomSimpleData.chatRoomUid,
        'chatroomcustomprofile': myData.myProfile,
        'chatroomcustomname': myData.myNickName,
        'lastchatmessage': chatRoomSimpleData.lastChatMessage,
        'readablemessage': chatRoomSimpleData.readableMessage,
        'lastchattime': chatRoomSimpleData.lastChatTime,
      });

      await deleteRequest(friendUID, true, true);
      await getFriendDataList();
      await getChatRoomData();
      await getChatRoomDataList();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("친구 추가에 성공하였습니다.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("친구 추가에 실패히였습니다.")));
    }
  } on FirebaseAuthException catch (e) {
    print("addFriend 에러");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("친구 추가에 실패히였습니다.")));
  }
}

// Request데이터들을 파이어베이스에 저장하는 작업
Future<void> sendRequest(String friendUID, BuildContext context) async {
  FriendData? friendData;
  FriendData? myData;
  try {
    User? user = _auth.currentUser;
    friendData = await getRequestFriendData(friendUID);
    myData = await getRequestFriendData(user!.uid);
    String dateTime;
    bool requestSendCheck = requestSendList.any((request) =>
        request.requestUID == friendData?.friendUID); // 리스트에 friendUID를 가지고있는 데이터가 존재하는지 체크하는 작업
    bool requestReceivedCheck =
        requestReceivedList.any((request) => request.requestUID == friendData?.friendUID);
    bool friendCheck = await checkFriend(friendData!.friendUID); // 파이어베이스의 본인의 친구목록에 있는지 확인하는 변수

    if (!friendCheck &&
        !requestSendCheck &&
        !requestReceivedCheck &&
        friendData.friendUID != user.uid) {
      dateTime = DateFormat("yyyy-MM-dd").format(DateTime.now());
      // 자신 DB의 request 에 저장할 데이터를 저장하는 작업
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("request")
          .doc(friendData.friendUID)
          .set({
        "requestuid": friendData.friendUID,
        "requestemail": friendData.friendEmail,
        "requestnickname": friendData.friendNickName,
        "requestprofile": friendData.friendProfile,
        "requesttime": dateTime,
        "requestkey": "oneself",
        "requestcheck": false,
        "deletecheck": false,
      });

      // 상대방 DB의 request 에 저장할 데이터를 저장하는 작업
      await _firestore
          .collection("users")
          .doc(friendData.friendUID)
          .collection("request")
          .doc(user.uid)
          .set({
        "requestuid": myData?.friendUID,
        "requestemail": myData?.friendEmail,
        "requestnickname": myData?.friendNickName,
        "requestprofile": myData?.friendProfile,
        "requesttime": dateTime,
        "requestkey": "another",
        "requestcheck": false,
        "deletecheck": false,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("친구 요청에 성공하였습니다.")));
    } else {
      if (friendCheck) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("이미 등록되어있는 사용자 입니다.")));
      } else if (requestSendCheck) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("이미 요청중인 사용자 입니다.")));
      } else if (requestReceivedCheck) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("이미 요청받은 사용자 입니다.")));
      } else if (friendData.friendUID == user.uid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("자신의 코드를 입력할 수 없습니다.")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("친구 요청에 문제가 발생했습니다. 나중에 다시 시도해 주세요")));
      }
    }
  } on FirebaseAuthException catch (e) {
    print("sendRequest 에러");
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("친구 요청에 문제가 발생했습니다. 나중에 다시 시도해 주세요")));
  }
}

// 파이어베이스에서 Request데이터를 불러오는 작업
Future<void> acceptRequest() async {
  requestSendList = []; //리스트 초기화
  requestReceivedList = [];
  try {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("request")
        .get();
    for (var doc in querySnapshot.docs) {
      dynamic result = doc.data();
      addRequestList(result);
    }
  } catch (e) {
    print('acceptRequest오류 $e');
  }
}

void addRequestList(dynamic result) {
  if (result["requestkey"] == "oneself") {
    requestSendList.add(RequestData(
      result["requestuid"],
      result["requestemail"],
      result["requestnickname"],
      result["requestprofile"],
      result["requesttime"],
      result["requestkey"],
      result["requestcheck"],
      result["deletecheck"],
    ));
  } else {
    requestReceivedList.add(RequestData(
      result["requestuid"],
      result["requestemail"],
      result["requestnickname"],
      result["requestprofile"],
      result["requesttime"],
      result["requestkey"],
      result["requestcheck"],
      result["deletecheck"],
    ));
  }
}

// 가져온 문자데이터를 이메일형식 또는 UID형식인지 구분뒤 친구 데이터를 확인후 가져오는 작업
Future<FriendData?> getRequestFriendData(String friendUID) async {
  bool emailChcek = friendUID.contains("@");

  if (emailChcek) {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users_public") // 원하는 컬렉션
          .where("email", isEqualTo: friendUID) // 필터링할 필드와 값
          .get();
      var result = querySnapshot.docs.first;
      return FriendData(result["uid"], result["email"], result["nickname"], result["profile"], "",
          "", "", [], false);
    } catch (e) {
      return null;
    }
  } else {
    try {
      var result = await _firestore.collection("users_public").doc(friendUID).get();
      return FriendData(result["uid"], result["email"], result["nickname"], result["profile"], "",
          "", "", [], false);
    } catch (e) {
      return null;
    }
  }
}

Future<bool> checkRequest(String aUID, String bUID) async {
  DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(aUID)
      .collection("request")
      .doc(bUID)
      .get();
  return documentSnapshot.exists;
}

Future<void> updateRequest(
  String friendUID,
) async {
  try {
    User? user = _auth.currentUser;
    bool checkMyData = await checkRequest(user!.uid, friendUID);
    bool checkFriendData = await checkRequest(friendUID, user.uid);

    if (checkMyData && checkFriendData) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("request")
          .doc(friendUID)
          .update({
        "requestcheck": true,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(friendUID)
          .collection("request")
          .doc(user.uid)
          .update({
        "requestcheck": true,
      });
    }
  } catch (e) {
    print("deleteRequest오류");
  }
}

Future<void> updateDeleteRequest(
  String friendUID,
) async {
  try {
    User? user = _auth.currentUser;
    bool checkMyData = await checkRequest(user!.uid, friendUID);
    bool checkFriendData = await checkRequest(friendUID, user.uid);

    if (checkMyData && checkFriendData) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("request")
          .doc(friendUID)
          .update({
        "deletecheck": true,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(friendUID)
          .collection("request")
          .doc(user.uid)
          .update({
        "deletecheck": true,
      });
    }
  } catch (e) {
    print("updateDeleteRequest오류");
  }
}

// 상대방 혹은 나의 요청데이터를 삭제하기 위한 함수
Future<void> deleteRequest(String friendUID, bool deleteA, bool deleteB) async {
  try {
    User? user = _auth.currentUser;
    if (deleteA) {
      bool checkMyData = await checkRequest(user!.uid, friendUID);
      if (checkMyData) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("request")
            .doc(friendUID)
            .delete();
      }
    }
    if (deleteB) {
      bool checkFriendData = await checkRequest(friendUID, user!.uid);
      if (checkFriendData) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(friendUID)
            .collection("request")
            .doc(user.uid)
            .delete();
      }
    }
  } catch (e) {
    print("deleteRequest오류");
  }
}

// 친구 요청을 수락하거나 거절할때 상대방이 이미 행동했을때를 방지하기 위한 확인작업
Future<bool> requestCheck(String friendUID) async {
  User? user = _auth.currentUser;
  bool myRequestCheck = await checkRequest(user!.uid, friendUID);
  bool friendRequestCheck = await checkRequest(friendUID, user.uid);

  if (myRequestCheck && friendRequestCheck) {
    return true;
  } else if (!myRequestCheck && friendRequestCheck) {
    await deleteRequest(friendUID, false, true);
    return false;
  } else if (myRequestCheck && !friendRequestCheck) {
    await deleteRequest(friendUID, true, false);
    return false;
  } else {
    return false;
  }
}

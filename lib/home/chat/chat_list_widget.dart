import 'package:auto_size_text/auto_size_text.dart';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import '../../utils/date_check.dart';
import '../../utils/get_people_data.dart';
import 'chat_room/chat_room_data.dart';
import 'chat_room/chat_room_screen.dart';
import 'create_chat/creat_chat_data.dart';

// 채팅방 리스트뷰에 사용되는 위젯
class ChatListWidget extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;

  const ChatListWidget({
    super.key,
    required this.chatRoomSimpleData,
  });

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  final String imagePath = 'assets/images/blank_profile.png';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ScreenSize _screenSize;
  late ChatRoomSimpleData _chatRoomSimpleData;
  late ChatRoomData _chatRoomData;
  late Stream<DocumentSnapshot> _stream1; // 스트림에 등록된 서버의 DB 경로에서 값이 변경되는 것을 감지하고 해당 값을 가져오기 위한 변수1
  late Stream<DocumentSnapshot> _stream2; // 스트림에 등록된 서버의 DB 경로에서 값이 변경되는 것을 감지하고 해당 값을 가져오기 위한 변수2
  late final _combinedStream;
  late String _message;
  late DateTime _time;
  bool firstBuild = true;
  String _profileUrl = '';
  String _name = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomSimpleData = widget.chatRoomSimpleData;
    _chatRoomData = chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!;

    if (_chatRoomSimpleData.chatRoomUid.length > 8 && _chatRoomData.peopleList.length <= 2) {
      _checkInherent();
    } else {
      _setProfile();
      _setName();
    }
    _setTimeAndMessage();

    // 1번 스트림 설정
    _stream1 = _firestore
        .collection('chat')
        .doc(_chatRoomSimpleData.chatRoomUid)
        .collection('realtime')
        .doc('_lastmessage_')
        .snapshots();
    // 2번 스트림 설정
    _stream2 = _firestore
        .collection('users')
        .doc(myData.myUID)
        .collection('chat')
        .doc(_chatRoomSimpleData.chatRoomUid)
        .snapshots();

    // 스트림을 하나로 묶어서 사용하기 위한 과정
    _combinedStream = Rx.combineLatest2(
      _stream1,
      _stream2,
      (DocumentSnapshot doc1, DocumentSnapshot doc2) => [doc1, doc2],
    );
  }

  // 개인 채팅방인지 확인하여 개인채팅방일 경우 채팅방 데이터를 개인데이터로 덮어씌우는 작업
  void _checkInherent() {
    FriendData? friendData;
    for (var item in _chatRoomData.peopleList) {
      if (item != myData.myUID) {
        friendData = friendList[friendListUidKey[item]];
      }
    }
    if (friendData != null) {
      _profileUrl = friendData.friendProfile;
      _name = friendData.friendNickName;
    } else {
      _profileUrl = '';
      _name = '';
    }
  }

  // 사용자가 저장한 커스텀 닉네임이 있을 경우 해당 커스텀 닉네임을 저장, 없을 경우 일반 닉네임으로 저장 하는 함수
  void _setName() {
    if (_chatRoomSimpleData.chatRoomCustomName.isNotEmpty) {
      _name = _chatRoomSimpleData.chatRoomCustomName;
    } else if (_chatRoomData.chatRoomName.isNotEmpty) {
      _name = _chatRoomData.chatRoomName;
    } else {
      _name = '';
    }
  }

  // 사용자가 저장한 커스텀 프로필이 있을 경우 해당 커스텀 프로필을 저장, 없을 경우 일반 프로필으로 저장 하는 함수
  void _setProfile() {
    if (_chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty) {
      _profileUrl = _chatRoomSimpleData.chatRoomCustomProfile;
    } else if (_chatRoomData.chatRoomProfile.isNotEmpty) {
      _profileUrl = _chatRoomData.chatRoomProfile;
    } else {
      _profileUrl = '';
    }
  }

  // chatRoomRealTimeData 맵리스트에서 해당 채팅방의 마지막 메세지의 시간과 내용을 가져오는 함수
  void _setTimeAndMessage() {
    ChatRoomRealTimeData realTimeData = chatRoomRealTimeData[_chatRoomSimpleData.chatRoomUid]!;
    _time = realTimeData.lastChatTime;
    _message = realTimeData.lastChatMessage;
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return StreamBuilder<List<DocumentSnapshot>>(
        stream: _combinedStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.length != 2) {
            return const Center(child: Text('Document does not exist'));
          }

          // 설정한 경로의 DB에 값이 변경되었을 경우 값을 가져와 업데이트 하는 작업
          var data1 = snapshot.data![0].data() as Map<String, dynamic>;
          var data2 = snapshot.data![1].data() as Map<String, dynamic>;
          _message = data1['lastchatmessage'];
          _time = (data1['lastchattime'] as Timestamp).toDate();
          chatRoomRealTimeData[_chatRoomSimpleData.chatRoomUid]!.readableMessage =
              data2['readablemessage'];
          sortUid = _chatRoomSimpleData.chatRoomUid;

          return GestureDetector(
            onTap: () async {
              EasyLoading.show();
              await getChatData(_chatRoomSimpleData.chatRoomUid);
              List<ChatPeopleClass> chatPeople =
                  await getPeopleData(_chatRoomSimpleData.chatRoomUid);
              await updateRealTimeData(_chatRoomSimpleData.chatRoomUid);
              EasyLoading.dismiss();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    chatRoomSimpleData: _chatRoomSimpleData,
                    chatPeopleList: chatPeople,
                  ),
                ),
              );
            },
            child: Container(
              height: _screenSize.getHeightPerSize(7),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  SizedBox(
                    width: _screenSize.getWidthPerSize(4),
                  ),
                  SizedBox(
                    height: _screenSize.getHeightPerSize(6),
                    width: _screenSize.getHeightPerSize(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _profileUrl.isNotEmpty
                          ? Image.network(
                              _profileUrl,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // 이미지 로드 완료
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder:
                                  (BuildContext context, Object error, StackTrace? stackTrace) {
                                return const Center(
                                  child: Text('이미지 로딩 실패'),
                                );
                              },
                            )
                          : Image.asset(
                              imagePath,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: _screenSize.getWidthPerSize(2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: _screenSize.getHeightPerSize(3.5),
                          child: Align(
                              alignment: Alignment.bottomLeft,
                              child: AutoSizeText(
                                _name,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: _screenSize.getHeightPerSize(1.7)),
                              )),
                        ),
                        SizedBox(
                          height: _screenSize.getHeightPerSize(0.5),
                        ),
                        SizedBox(
                          height: _screenSize.getHeightPerSize(2.8),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _message,
                              style: TextStyle(
                                  color: Colors.grey, fontSize: _screenSize.getHeightPerSize(1.5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: _screenSize.getWidthPerSize(2),
                  ),
                  SizedBox(
                    height: _screenSize.getHeightPerSize(5),
                    width: _screenSize.getWidthPerSize(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        dateTimeConvertTextWidget(_time, _screenSize),
                        Visibility(
                          visible: chatRoomRealTimeData[_chatRoomSimpleData.chatRoomUid]!
                                      .readableMessage >
                                  0
                              ? true
                              : false,
                          child: Container(
                            height: _screenSize.getHeightPerSize(2.5),
                            width: _screenSize.getHeightPerSize(2.5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                chatRoomRealTimeData[_chatRoomSimpleData.chatRoomUid]!
                                            .readableMessage <
                                        100
                                    ? chatRoomRealTimeData[_chatRoomSimpleData.chatRoomUid]!
                                        .readableMessage
                                        .toString()
                                    : '+99',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _screenSize.getHeightPerSize(1.3)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: _screenSize.getWidthPerSize(2),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

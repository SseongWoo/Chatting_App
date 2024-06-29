import 'package:auto_size_text/auto_size_text.dart';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../utils/get_people_data.dart';
import 'chat_room/chat_room_data.dart';
import 'chat_room/chat_room_screen.dart';
import 'create_chat/creat_chat_data.dart';

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
  late ScreenSize _screenSize;
  late ChatRoomSimpleData _chatRoomSimpleData;
  late ChatRoomData _chatRoomData;
  final String imagePath = 'assets/images/blank_profile.png';
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

  void _setName() {
    if (_chatRoomSimpleData.chatRoomCustomName.isNotEmpty) {
      _name = _chatRoomSimpleData.chatRoomCustomName;
    } else if (_chatRoomData.chatRoomName.isNotEmpty) {
      _name = _chatRoomData.chatRoomName;
    } else {
      _name = '';
    }
  }

  void _setProfile() {
    if (_chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty) {
      _profileUrl = _chatRoomSimpleData.chatRoomCustomProfile;
    } else if (_chatRoomData.chatRoomProfile.isNotEmpty) {
      _profileUrl = _chatRoomData.chatRoomProfile;
    } else {
      _profileUrl = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        await getChatData(_chatRoomSimpleData.chatRoomUid);
        List<ChatPeopleClass> chatPeople = await getPeopleData(_chatRoomSimpleData.chatRoomUid);
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
                        loadingBuilder:
                            (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Center(
                            child: Text('Failed to load image'),
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
                              color: Colors.black, fontSize: _screenSize.getHeightPerSize(1.7)),
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
                        "채팅방",
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
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "8월 2일\n오전 11:08",
                  style: TextStyle(color: Colors.grey, fontSize: _screenSize.getHeightPerSize(1.5)),
                ),
              ),
            ),
            SizedBox(
              width: _screenSize.getWidthPerSize(2),
            ),
          ],
        ),
      ),
    );
  }
}

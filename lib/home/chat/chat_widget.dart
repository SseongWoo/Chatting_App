import 'package:auto_size_text/auto_size_text.dart';
import 'package:chattingapp/home/chat/chat_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../utils/get_people_data.dart';
import 'chat_room/chat_room_data.dart';
import 'chat_room/chat_room_screen.dart';
import 'create_chat/creat_chat_data.dart';

class ChatListWidget extends StatefulWidget {
  final int index;

  const ChatListWidget({
    super.key,
    required this.index,
  });

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  late ScreenSize _screenSize;
  late int _index;
  late ChatRoomSimpleData _chatRoomSimpleData;
  final String imagePath = 'assets/images/blank_profile.png';
  String _profileUrl = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _index = widget.index;
    _chatRoomSimpleData = chatRoomList[chatRoomSequence[_index]]!;
    _setProfile();
  }

  void _setProfile() {
    if (_chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty) {
      _profileUrl = _chatRoomSimpleData.chatRoomCustomProfile;
    } else if (chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!.chatRoomProfile.isNotEmpty) {
      _profileUrl = chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!.chatRoomProfile;
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
                          _chatRoomSimpleData.chatRoomCustomName.isNotEmpty
                              ? _chatRoomSimpleData.chatRoomCustomName
                              : chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!.chatRoomName,
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

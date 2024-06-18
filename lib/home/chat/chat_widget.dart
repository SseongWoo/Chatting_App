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
  late ScreenSize screenSize;
  late int index;
  late ChatRoomSimpleData chatRoomSimpleData;
  final String imagePath = 'assets/images/blank_profile.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    index = widget.index;
    chatRoomSimpleData = chatRoomList[chatRoomSequence[index]]!;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        await getChatData(chatRoomSimpleData.chatRoomUid);
        List<ChatPeopleClass> chatPeople = await getPeopleData(chatRoomSimpleData.chatRoomUid);
        EasyLoading.dismiss();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                      chatRoomSimpleData: chatRoomSimpleData,
                      chatPeopleList: chatPeople,
                    )));
      },
      child: Container(
        height: screenSize.getHeightPerSize(7),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            SizedBox(
              width: screenSize.getWidthPerSize(4),
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(6),
              width: screenSize.getHeightPerSize(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty
                    ? Image.network(
                        chatRoomSimpleData.chatRoomCustomProfile,
                      )
                    : Image.asset(
                        imagePath,
                      ),
              ),
            ),
            SizedBox(
              width: screenSize.getWidthPerSize(2),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: screenSize.getHeightPerSize(3.5),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: AutoSizeText(
                          chatRoomSimpleData.chatRoomCustomName,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.black, fontSize: screenSize.getHeightPerSize(1.7)),
                        )),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(0.5),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2.8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "채팅방",
                        style: TextStyle(
                            color: Colors.grey, fontSize: screenSize.getHeightPerSize(1.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenSize.getWidthPerSize(2),
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(5),
              width: screenSize.getWidthPerSize(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "8월 2일\n오전 11:08",
                  style: TextStyle(color: Colors.grey, fontSize: screenSize.getHeightPerSize(1.5)),
                ),
              ),
            ),
            SizedBox(
              width: screenSize.getWidthPerSize(2),
            ),
          ],
        ),
      ),
    );
  }
}

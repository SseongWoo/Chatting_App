import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/screen_size.dart';
import 'chat_list_data.dart';
import 'chat_list_widget.dart';

// 채팅방 리스트 화면
class ChatScreen extends StatefulWidget {
  final bool groupChaeck;
  const ChatScreen({super.key, required this.groupChaeck});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScreenSize _screenSize;
  late bool _groupCheck; // true일경우 그룹 채팅 리스트 화면, false일경우 개인 채팅 리스트 화면
  late List<String> _chatRoomSequence = [];
  String _text = '';
  Timer? _timer; // Timer 변수

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 개인채팅인지 그룹채팅인지 확인하고 리스트뷰에 적용하는 작업
    _groupCheck = widget.groupChaeck;
    _chatRoomSequence.clear();
    if (_groupCheck) {
      _chatRoomSequence = groupChatRoomSequence;
      _text = '그룹';
    } else {
      _chatRoomSequence = chatRoomSequence;
      _text = '';
    }
    buildState = false;

    // _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
    //   // print(_chatRoomSequence[0]);
    //   // if (sortUid != '' && _chatRoomSequence[0] != sortUid) {
    //   //   print('타이버실행');
    //   //   sortList(sortUid);
    //   //}
    //   setState(() {
    //     sortList(sortUid);
    //   });
    // });
  }

  // void sortList(String uid) {
  //   // setState(() {
  //   //   if (_groupCheck) {
  //   //     // 새로운 리스트를 만들어서 리스트 참조를 바꾸어 줌
  //   //     groupChatRoomSequence = List.from(groupChatRoomSequence);
  //   //     groupChatRoomSequence.remove(uid);
  //   //     groupChatRoomSequence.insert(0, uid);
  //   //     _chatRoomSequence = groupChatRoomSequence; // UI 업데이트를 위해 참조 변경
  //   //   } else {
  //   //     // 새로운 리스트를 만들어서 리스트 참조를 바꾸어 줌
  //   //     chatRoomSequence = List.from(chatRoomSequence);
  //   //     chatRoomSequence.remove(uid);
  //   //     chatRoomSequence.insert(0, uid);
  //   //     _chatRoomSequence = chatRoomSequence; // UI 업데이트를 위해 참조 변경
  //   //   }
  //   // });
  //   print('22');
  //   groupChatRoomSequence.sort((a, b) {
  //     // testMap에서 a와 b의 time 값을 비교하여 정렬
  //     return chatRoomRealTimeData[a]!.lastChatTime.compareTo(chatRoomRealTimeData[b]!.lastChatTime);
  //   });
  //   _chatRoomSequence = groupChatRoomSequence;
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   sortUid = '';
  //   _timer?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);

    return Scaffold(
        body: _chatRoomSequence.isNotEmpty
            ? ListView.separated(
                itemCount: _chatRoomSequence.length,
                itemBuilder: (context, index) {
                  return ChatListWidget(
                    chatRoomSimpleData: chatRoomList[_chatRoomSequence[index]]!,
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: _screenSize.getHeightPerSize(1)); // 아이템 간의 간격 조절
                },
              )
            : Center(child: Text("현재 참여 중인 $_text채팅방이 없습니다.")));
  }
}

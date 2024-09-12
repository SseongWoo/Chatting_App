import 'package:chattingapp/home/chat/chat_room/search_chat/search_room_screen.dart';
import 'package:chattingapp/home/chat/create_chat/creat_chat_screen.dart';
import 'package:chattingapp/home/friend/request/friend_request_screen.dart';
import 'package:chattingapp/home/friend/request/request_data.dart';
import 'package:chattingapp/home/information/information_screen.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../error/error_dialog.dart';
import '../utils/screen_size.dart';
import 'chat/chat_list_screen.dart';
import 'friend/friend_screen.dart';

// 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late ScreenSize _screenSize;
  late TabController _tabController;
  final titles = {
    0: '친구',
    1: '개인 채팅',
    2: '단체 채팅',
    3: '설정',
  };
  int barIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: titles.length, initialIndex: homeTap, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(titles[_tabController.index]!),
          backgroundColor: mainLightColor,
          actions: [
            IconButton(
              onPressed: () {
                showErrorDialog(context, 'ㄷㄷㄷㄷㄷㄷ');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(buifor (var item in groupChatRoomSequence) {
                //                 //   print(chatRoomList[item]?.chatRoomCustomName);
                //                 // }lder: (context) => const TestScreen()),
                // );
                //
              },
              icon: const Icon(Icons.texture_sharp),
            ),
            if (_tabController.index == 0)
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const FriendManagementScreen()),
                          (route) => false);
                    },
                    icon: const Icon(Icons.person_add_alt),
                    tooltip: '친구 추가',
                  ),
                  Visibility(
                    visible: requestReceivedList.isNotEmpty,
                    child: Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        height: _screenSize.getHeightPerSize(1),
                        width: _screenSize.getHeightPerSize(1),
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
            if (_tabController.index == 1 || _tabController.index == 2)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateChat()),
                  );
                },
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: '채팅방 개설',
              ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchRoomScreen()),
                );
              },
              icon: const Icon(Icons.search),
              tooltip: '검색',
            ),
            if (_tabController.index == 3)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                tooltip: '앱 설정',
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FriendScreen(),
            ChatScreen(
              groupChaeck: false,
            ),
            ChatScreen(
              groupChaeck: true,
            ),
            InformationScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          color: mainLightColor,
          child: TabBar(
              onTap: (value) {
                setState(() {
                  homeTap = _tabController.index;
                });
              },
              labelColor: Colors.white,
              unselectedLabelColor: mainBoldColor,
              indicatorColor: Colors.white,
              dividerColor: mainLightColor,
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.people),
                  text: '친구',
                ),
                Tab(
                  icon: Icon(Icons.chat),
                  text: '개인 채팅',
                ),
                Tab(
                  icon: Icon(Icons.forum),
                  text: '단체 채팅',
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: '내 정보',
                )
              ]),
        ),
      ),
    );
  }
}

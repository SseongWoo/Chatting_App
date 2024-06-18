import 'package:chattingapp/home/chat/create_chat/creat_chat_screen.dart';
import 'package:chattingapp/home/friend/request/friend_request_screen.dart';
import 'package:chattingapp/home/information_screen.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/public_variable.dart';
import 'package:chattingapp/utils/test_screen.dart';
import 'package:flutter/material.dart';
import 'chat/chat_screen.dart';
import 'friend/friend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int barIndex = 0;
  late TabController _tabController;
  final titles = {
    0: "친구",
    1: "채팅",
    2: "설정",
  };

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestScreen()),
                );
              },
              icon: const Icon(Icons.texture_sharp),
            ),
            if (_tabController.index == 0)
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const FriendManagementScreen()),
                      (route) => false);
                },
                icon: const Icon(Icons.add),
                tooltip: "친구 추가",
              ),
            if (_tabController.index == 1)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateChat()),
                  );
                },
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: "채팅방 개설",
              ),
            IconButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const SplashScreen()),
                // );
              },
              icon: const Icon(Icons.search),
              tooltip: "검색",
            ),
            if (_tabController.index == 2)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                tooltip: "앱 설정",
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FriendScreen(),
            ChatScreen(),
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
                  text: "친구",
                ),
                Tab(
                  icon: Icon(Icons.chat),
                  text: "채팅",
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: "내 정보",
                )
              ]),
        ),
      ),
    );
  }
}

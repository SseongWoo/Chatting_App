import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:chattingapp/home/friend/friend_widget.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'category/category_data.dart';
import 'category/category_setting_screen.dart';
import 'friend_data.dart';

// 친구 리스트 화면
class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> with TickerProviderStateMixin {
  late ScreenSize screenSize;
  late TabController _tabController;
  List<String> newCategorySequence = [];
  Map<String, FriendData> newFriendList = {};
  int categoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categorySequence.length + 1, vsync: this);
    newFriendList = friendList;
    newCategorySequence = ['전체']; // 카테고리에는 기본적으로 전체 탭이 필수로 저장되어야 함
    newCategorySequence.addAll(categorySequence);
    checkTwoLetterItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 카테고리 이름을 두글자로 하게 되면 좌우 가장자리에 색이 안채워지는 오류로 인해 문장 앞뒤에 여백을 넣는 함수
  void checkTwoLetterItems() {
    for (int i = 0; i < newCategorySequence.length; i++) {
      newCategorySequence[i] = '  ${newCategorySequence[i]}  ';
    }
  }

  Widget buildWidget() {
    return Column(
      children: [
        Container(
          height: screenSize.getHeightPerSize(5),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                  child: ButtonsTabBar(
                controller: _tabController,
                backgroundColor: mainColor,
                unselectedBackgroundColor: Colors.grey[300],
                borderWidth: 1,
                borderColor: Colors.black,
                unselectedBorderColor: Colors.grey,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                tabs: newCategorySequence.map((String name) => Tab(text: name)).toList(),
              )),
              Container(
                width: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CategorySettingScreen(
                                checkData: false,
                              )),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: newCategorySequence.map((String name) {
              // 전체 탭바일경우 모든 친구 데이터 나타내기
              if (name == '  전체  ' && newFriendList.isNotEmpty) {
                return ListView.builder(
                  itemCount: newFriendList.length,
                  itemBuilder: (context, index) {
                    return FriendWidget(
                      friendData: newFriendList[friendListSequence[index]]!,
                    );
                  },
                );
              } else if (categoryList.containsKey(name.trim())) {
                final trimmedName = name.trim();
                final items = categoryList[trimmedName];

                if (items != null && items.isNotEmpty) {
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return FriendWidget(
                        friendData: newFriendList[friendListUidKey[items[index]]]!,
                      );
                    },
                  );
                } else {
                  // items가 null이거나 비어 있을 때 빈 위젯 반환
                  return const Center(child: Text('현재 이 카테고리에 친구가 없습니다.\n친구를 추가해보세요!'));
                }
              } else {
                // name이 카테고리에 없을 때 빈 위젯 반환
                return const Center(child: Text('현재 이 카테고리에 친구가 없습니다.\n친구를 추가해보세요!'));
              }
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return buildWidget();
  }
}

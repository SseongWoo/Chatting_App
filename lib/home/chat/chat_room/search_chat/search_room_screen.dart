import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/chat/chat_room/search_chat/search_room_data.dart';
import 'package:chattingapp/home/chat/chat_room/search_chat/search_room_widget.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/color/color.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../utils/screen_size.dart';
import '../../../friend/friend_widget.dart';
import '../../chat_list_widget.dart';

// 검색 창 스크린
class SearchRoomScreen extends StatefulWidget {
  const SearchRoomScreen({super.key});

  @override
  State<SearchRoomScreen> createState() => _SearchRoomScreenState();
}

class _SearchRoomScreenState extends State<SearchRoomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: mainColor,
          indicatorColor: mainColor,
          tabs: const [
            Tab(text: '내부 검색'),
            Tab(text: '외부 검색'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LocalSearchScreen(),
          GlobalSearchScreen(),
        ],
      ),
    );
  }
}

// SearchRoomScreen 화면에 있는 탭바의 아이템에 들어갈 화면, 내부검색 화면
class LocalSearchScreen extends StatefulWidget {
  const LocalSearchScreen({super.key});

  @override
  State<LocalSearchScreen> createState() => _LocalSearchScreenState();
}

class _LocalSearchScreenState extends State<LocalSearchScreen> {
  final TextEditingController _controllerSearchBox = TextEditingController();
  late List<String> _chatRoomSequence = [];
  late List<FriendData> _frendDataSequence = [];
  bool _isSearched = false;

  // 검색 버튼을 눌렀을때 실행되는 함수, 로컬데이터를 사용하기 때문에 비동기 처리 사용안함
  void _scarchStart() {
    EasyLoading.show();
    _searchChatRoom();
    _searchFriend();
    EasyLoading.dismiss();
  }

  // 로컬데이터에 있는 채팅방 중 사용자가 검색할 데이터중 채팅방 데이터에서 값을 찾아서 _chatRoomSequence 리스트에 저장하는 작업,
  // 일치하거나 포함되어있을 경우 저장하며 uid, 이름, 설명, 사용자 설정 이름에서 찾음
  void _searchChatRoom() {
    List<String> startChatRoomSequence = [];
    String searchData = _controllerSearchBox.text;

    // 채팅방 uid, 이름, 설명에서 일치하거나 포함되어있는 값을 찾는 작업
    for (var entry in chatRoomDataList.entries) {
      if (entry.value.chatRoomUid.contains(searchData) ||
          entry.value.chatRoomName.contains(searchData) ||
          entry.value.chatRoomExplain.contains(searchData)) {
        startChatRoomSequence.add(entry.value.chatRoomUid);
      }
    }
    // 채팅방 사용자 설정 이름이 일치하거나 포함되어있는 값을 찾는 작업
    for (var entry in chatRoomList.entries) {
      if (entry.value.chatRoomCustomName.contains(searchData) &&
          startChatRoomSequence.any((item) => item.contains(searchData))) {
        startChatRoomSequence.add(entry.value.chatRoomUid);
      }
    }

    setState(() {
      _chatRoomSequence = startChatRoomSequence;
    });
  }

  // 로컬데이터에 있는 채팅방 중 사용자가 검색할 데이터중 친구 데이터에서 값을 찾아서 _frendDataSequence 또는 _chatRoomSequence 리스트에 저장하는 작업,
  // 일치하거나 포함되어있을 경우 저장하며 uid, 이름, 사용자 설정 이름, 이메일에서 찾음
  // 해당되는 친구 데이터의 1대1 채팅방도 _chatRoomSequence에 저장하여 화면에 표시
  void _searchFriend() {
    List<FriendData> startFrendDataSequence = [];
    List<String> plusChatRoomSequence = [];
    String searchData = _controllerSearchBox.text;
    for (var entry in friendList.entries) {
      if (entry.value.friendUID.contains(searchData) ||
          entry.value.friendNickName.contains(searchData) ||
          entry.value.friendCustomName.contains(searchData) ||
          entry.value.friendEmail.contains(searchData)) {
        startFrendDataSequence.add(entry.value);
        plusChatRoomSequence.add(entry.value.friendInherentChatRoom);
      }
      setState(() {
        _frendDataSequence = startFrendDataSequence;
        _chatRoomSequence.addAll(plusChatRoomSequence);
      });
    }
  }

  // _frendDataSequence의 리스트 뷰의 사이즈를 조절하는 함수
  double _userListViewSize() {
    if (_frendDataSequence.length < 4) {
      return screenSize.getHeightPerSize(9) * _frendDataSequence.length;
    } else {
      return screenSize.getHeightPerSize(27);
    }
  }

  // _chatRoomSequence 리스트 뷰의 사이즈를 조절하는 함수
  double _chatListViewSize() {
    if (_chatRoomSequence.length < 4) {
      return screenSize.getHeightPerSize(8) * _chatRoomSequence.length;
    } else {
      return screenSize.getHeightPerSize(24);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenSize.getHeightPerSize(6),
              child: SizedBox(
                width: screenSize.getWidthPerSize(90),
                child: TextField(
                  controller: _controllerSearchBox,
                  style: TextStyle(
                    fontSize: screenSize.getHeightPerSize(2),
                  ),
                  textInputAction: TextInputAction.search,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: '검색',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // 텍스트 필드에 값이 비어있어나 한글자가 아닐경우 실행
                        if (_controllerSearchBox.text.isNotEmpty &&
                            _controllerSearchBox.text.length > 1) {
                          _scarchStart();
                          setState(() {
                            _isSearched = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(screenSize.getWidthPerSize(5), 0, 0, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '친구',
                ),
              ),
            ),
            Container(
              width: screenSize.getWidthPerSize(90),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _frendDataSequence.isEmpty
                  ? SizedBox(
                      height: screenSize.getHeightPerSize(2),
                      // 검색 결과가 없을경우 나타나는 위젯
                      child: Visibility(
                        visible: _isSearched,
                        child: const Center(
                          child: Text('검색 결과가 없습니다.'),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: screenSize.getHeightPerSize(1),
                        ),
                        SizedBox(
                          height: _userListViewSize(),
                          child: ListView.separated(
                            // _frendDataSequence의 크기가 4보다 작을경우 스크롤 금지
                            physics: _frendDataSequence.length < 4
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            itemCount: _frendDataSequence.length,
                            itemBuilder: (context, index) {
                              return FriendWidget(
                                friendData: _frendDataSequence[index],
                              );
                            },
                            // 리스트 뷰의 아이템 간의 간격 조절
                            separatorBuilder: (context, index) {
                              return SizedBox(height: screenSize.getHeightPerSize(1));
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenSize.getWidthPerSize(5), screenSize.getHeightPerSize(2), 0, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '채팅방',
                ),
              ),
            ),
            Container(
              width: screenSize.getWidthPerSize(90),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _chatRoomSequence.isEmpty
                  ? SizedBox(
                      height: screenSize.getHeightPerSize(2),
                      // 검색결과가 없을 경우 나타나는 위젯
                      child: Visibility(
                        visible: _isSearched,
                        child: const Center(
                          child: Text('검색 결과가 없습니다.'),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: screenSize.getHeightPerSize(1),
                        ),
                        SizedBox(
                          height: _chatListViewSize(),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _chatRoomSequence.length,
                            itemBuilder: (context, index) {
                              return ChatListWidget(
                                chatRoomSimpleData: chatRoomList[_chatRoomSequence[index]]!,
                              );
                            },
                            // 리스트 뷰 아이템 간의 간격 조절
                            separatorBuilder: (context, index) {
                              return SizedBox(height: screenSize.getHeightPerSize(1));
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// SearchRoomScreen 화면에 있는 탭바의 아이템에 들어갈 화면, 외부검색 화면
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controllerSearchBox = TextEditingController();
  late List<ChatRoomPublicData> _chatRoomSequence = [];
  late List<UserData> _userDataSequence = [];
  final String _message = '빈공간';
  bool _isSearched = false;

  // 검색 버튼을 눌렀을때 실행되는 함수, 외부데이터를 사용하기 때문에 비동기 처리
  void _scarchStart() async {
    EasyLoading.show();
    await _searchFriendGlobal();
    await _searchChatRoomGlobal();
    EasyLoading.dismiss();
  }

  // 외부데이터에 있는 공개된 채팅방 중 사용자가 검색할 데이터중 친구 데이터에서 값을 찾아서 _frendDataSequence리스트에 저장하는 작업,
  // 일치하거나 포함되어있을 경우 저장하며 uid, 이름, 이메일에서 찾음
  Future<void> _searchFriendGlobal() async {
    try {
      String searchData = _controllerSearchBox.text;
      List<UserData> startUserDataSequence = [];
      QuerySnapshot querySnapshot = await _firestore.collection('users_public').get();
      // 가져온 데이터 중 조건에 만족하는 데이터만 리스트에 저장
      List<QueryDocumentSnapshot> filteredDocs = querySnapshot.docs.where((doc) {
        String email = doc['email'] ?? '';
        String uid = doc['uid'] ?? '';
        String emailPrefix = email.split('@').first;
        String name = doc['nickname'] ?? '';
        return uid != myData.myUID &&
            (emailPrefix.contains(searchData) ||
                uid.contains(searchData) ||
                name.contains(searchData));
      }).toList();

      // 저장된 filteredDocs 리스트에 있는 데이터들을 UserData클래스로 재구성해서 _userDataSequence에 저장
      for (var doc in filteredDocs) {
        UserData userData = UserData(doc['uid'], doc['email'], doc['nickname'], doc['profile']);
        startUserDataSequence.add(userData);
      }

      setState(() {
        _userDataSequence = startUserDataSequence;
      });
    } catch (e) {
      //
    }
  }

  // 외부데이터에 있는 채팅방 중 사용자가 검색할 데이터중 공개된 채팅방 데이터에서 값을 찾아서 _chatRoomSequence 리스트에 저장하는 작업,
  // 일치하거나 포함되어있을 경우 저장하며 uid, 이름, 설명에서 찾음
  Future<void> _searchChatRoomGlobal() async {
    try {
      String searchData = _controllerSearchBox.text;
      List<ChatRoomPublicData> startChatRoomSequence = [];
      QuerySnapshot querySnapshot = await _firestore.collection('chat_public').get();
      List<QueryDocumentSnapshot> filteredDocs = querySnapshot.docs.where((doc) {
        String chatroomname = doc['chatroomname'] ?? '';
        String chatroomuid = doc['chatroomuid'] ?? '';
        String chatroomexplain = doc['chatroomexplain'] ?? '';
        return chatroomname.contains(searchData) ||
            chatroomuid.contains(searchData) ||
            chatroomexplain.contains(searchData);
      }).toList();

      for (var doc in filteredDocs) {
        startChatRoomSequence.add(ChatRoomPublicData(doc['chatroomuid'], doc['chatroomprofile'],
            doc['chatroomname'], doc['chatroomexplain'], doc['people'], doc['password']));
      }
      setState(() {
        _chatRoomSequence = startChatRoomSequence;
      });
    } catch (e) {
      //
    }
  }

  // _userDataSequence 리스트 뷰의 사이즈를 조절하는 함수
  double _userListViewSize() {
    if (_userDataSequence.length < 4) {
      return screenSize.getHeightPerSize(9) * _userDataSequence.length;
    } else {
      return screenSize.getHeightPerSize(27);
    }
  }

  // _chatRoomSequence 리스트 뷰의 사이즈를 조절하는 함수
  double _chatListViewSize() {
    if (_chatRoomSequence.length < 4) {
      return screenSize.getHeightPerSize(8) * _chatRoomSequence.length;
    } else {
      return screenSize.getHeightPerSize(24);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenSize.getHeightPerSize(6),
              child: SizedBox(
                width: screenSize.getWidthPerSize(90),
                child: TextField(
                  controller: _controllerSearchBox,
                  style: TextStyle(
                    fontSize: screenSize.getHeightPerSize(2),
                  ),
                  textInputAction: TextInputAction.search,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: '검색',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // 텍스트 필드에 값이 비어있어나 한글자가 아닐경우 실행
                        if (_controllerSearchBox.text.isNotEmpty &&
                            _controllerSearchBox.text.length > 1) {
                          _scarchStart();
                          setState(() {
                            _isSearched = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(screenSize.getWidthPerSize(5), 0, 0, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '친구',
                ),
              ),
            ),
            Container(
              width: screenSize.getWidthPerSize(90),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _userDataSequence.isEmpty
                  ? SizedBox(
                      height: screenSize.getHeightPerSize(2),
                      // 검색 결과가 없을경우 나타나는 위젯
                      child: Visibility(
                          visible: _isSearched,
                          child: const Center(
                            child: Text('검색 결과가 없습니다.'),
                          )),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: screenSize.getHeightPerSize(1),
                        ),
                        SizedBox(
                          height: _userListViewSize(),
                          child: ListView.separated(
                            // _userDataSequence 크기가 4보다 작을경우 스크롤 금지
                            physics: _userDataSequence.length < 4
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            itemCount: _userDataSequence.length,
                            itemBuilder: (context, index) {
                              return UserWidget(
                                userData: _userDataSequence[index],
                              );
                            },
                            // 리스트 뷰 아이템 간의 간격 조절
                            separatorBuilder: (context, index) {
                              return SizedBox(height: screenSize.getHeightPerSize(1));
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenSize.getWidthPerSize(5), screenSize.getHeightPerSize(2), 0, 0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '채팅방',
                ),
              ),
            ),
            Container(
              width: screenSize.getWidthPerSize(90),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _chatRoomSequence.isEmpty
                  ? SizedBox(
                      height: screenSize.getHeightPerSize(2),
                      // 검색 결과가 없을경우 나타나는 위젯
                      child: Visibility(
                        visible: _isSearched,
                        child: const Center(
                          child: Text('검색 결과가 없습니다.'),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: screenSize.getHeightPerSize(1),
                        ),
                        SizedBox(
                          height: _chatListViewSize(),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _chatRoomSequence.length,
                            itemBuilder: (context, index) {
                              return GlobalChatListWidget(
                                chatRoomPublicData: _chatRoomSequence[index],
                              );
                            },
                            // 리스트 뷰 아이템 간의 간격 조절
                            separatorBuilder: (context, index) {
                              return SizedBox(height: screenSize.getHeightPerSize(1));
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

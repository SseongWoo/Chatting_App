import 'package:chattingapp/home/friend/request/request_widget.dart';
import 'package:chattingapp/utils/color/color.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../utils/date_check.dart';
import '../../../utils/screen_movement.dart';
import '../../home_screen.dart';
import 'request_data.dart';

late DateTime now;
late String toDay;

// 친구 추가 화면
class FriendManagementScreen extends StatefulWidget {
  const FriendManagementScreen({super.key});

  @override
  State<FriendManagementScreen> createState() => _FriendManagementScreenState();
}

class _FriendManagementScreenState extends State<FriendManagementScreen>
    with SingleTickerProviderStateMixin {
  bool newAddFriend = false;
  bool newRequestFriend = false;
  int barIndex = 0;
  late TabController _tabController;

  final titles = {
    0: "받은 요청",
    1: "보낸 요청",
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRequestList();
    //_listenToFriendRequests();
    _tabController = TabController(length: titles.length, initialIndex: requestTap, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getRequestList() async {
    EasyLoading.show();
    await acceptRequest();
    EasyLoading.dismiss();
  }

  // //요청이 들어왔을때 실시간으로 받는 함수
  // void _listenToFriendRequests() {
  //   setState(() {
  //     loadingState = true;
  //     requestReceivedList = [];
  //     requestSendList = [];
  //   });
  //   _firestore.collection("users").doc(_auth.currentUser!.uid).collection("request").snapshots().listen((snapshot) {
  //     for (var doc in snapshot.docs) {
  //       dynamic result = doc.data();
  //       addRequestList(result);
  //     }
  //     setState(() {
  //       loadingState = false;
  //     });
  //   });
  // }
  Future<bool> _onPopInvoked() async {
    movePage();
    return false;
  }

  void movePage() {
    Navigator.of(context).pushAndRemoveUntil(
      screenMovementLeftToRight(const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return DefaultTabController(
      length: 2,
      child: PopScope(
        onPopInvoked: (didPop) => _onPopInvoked,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  movePage();
                },
                icon: const Icon(Icons.arrow_back_ios_new)),
            backgroundColor: mainLightColor,
            centerTitle: false,
            title: Text(titles[_tabController.index]!),
            actions: [
              IconButton(
                  onPressed: () {
                    getRequestList();
                  },
                  icon: const Icon(Icons.refresh)),
            ],
          ),
          body: Stack(children: [
            TabBarView(
              controller: _tabController,
              children: const [
                RequestReceivedScreen(),
                RequestSentScreen(),
              ],
            ),
            Positioned(
              bottom: screenSize.getWidthPerSize(5),
              right: screenSize.getWidthPerSize(5),
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
                constraints: BoxConstraints(
                  minWidth: screenSize.getHeightPerSize(7),
                  minHeight: screenSize.getHeightPerSize(7),
                ),
                child: IconButton(
                  onPressed: () {
                    addFriendDialog(context);
                  },
                  icon: Icon(
                    Icons.add,
                    size: screenSize.getHeightPerSize(4),
                    color: Colors.black,
                  ),
                  tooltip: "친구 추가",
                ),
              ),
            ),
          ]),
          bottomNavigationBar: Container(
            color: mainLightColor,
            child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: mainBoldColor,
                indicatorColor: Colors.white,
                dividerColor: mainLightColor,
                onTap: (value) {
                  requestTap = value;
                },
                tabs: [
                  Tab(
                    height: screenSize.getHeightPerSize(8),
                    child: Stack(
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.move_to_inbox), Text('받은 요청')],
                        ),
                        Visibility(
                          visible: newRequestFriend,
                          child: Positioned(
                              right: screenSize.getHeightPerSize(0.5),
                              top: screenSize.getHeightPerSize(1),
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration:
                                    const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                constraints: BoxConstraints(
                                  minWidth: screenSize.getHeightPerSize(1),
                                  minHeight: screenSize.getHeightPerSize(1),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: screenSize.getHeightPerSize(8),
                    child: Stack(
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.send), Text('보낸 요청')],
                        ),
                        Visibility(
                          visible: newAddFriend,
                          child: Positioned(
                              right: screenSize.getHeightPerSize(0.5),
                              top: screenSize.getHeightPerSize(1),
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration:
                                    const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                constraints: BoxConstraints(
                                  minWidth: screenSize.getHeightPerSize(1),
                                  minHeight: screenSize.getHeightPerSize(1),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

// 친구 화면 속 보낸 요청 탭 화면
class RequestSentScreen extends StatefulWidget {
  const RequestSentScreen({super.key});

  @override
  State<RequestSentScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestSentScreen> {
  Future<void> refreshSend() async {
    await acceptRequest();
    setState(() {
      requestSendList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshSend();
        },
        child: Stack(
          children: [
            ListView.builder(
              itemCount: requestSendList.length,
              itemBuilder: (context, index) {
                return RequestSentWidget(index: index);
              },
            ),
            Visibility(
              visible: requestSendList.isEmpty,
              child: Center(
                child: Text(
                  '보낸 요청이 없습니다.',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 친구 화면 속 받은 요청 탭 화면
class RequestReceivedScreen extends StatefulWidget {
  const RequestReceivedScreen({super.key});

  @override
  State<RequestReceivedScreen> createState() => _RequestReceivedScreenState();
}

class _RequestReceivedScreenState extends State<RequestReceivedScreen> {
  Future<void> refreshAccept() async {
    await acceptRequest();
    setState(() {
      requestReceivedList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateCheck();
  }

  // 받은 요청중 응답을 한 요청사항들 중 3일이 지난 요청들을 삭제하는 과정
  void dateCheck() {
    for (int index = 0; index < requestReceivedList.length; index++) {
      if (dateDifference(requestReceivedList[index].requestTime) > 3 &&
          requestReceivedList[index].requestCheck != false) {
        deleteRequest(requestReceivedList[index].requestUID, true, false);
        requestReceivedList.removeAt(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshAccept();
        },
        child: Stack(
          children: [
            ListView.builder(
              itemCount: requestReceivedList.length,
              itemBuilder: (context, index) {
                return RequestReceivedWidget(screenSize: screenSize, index: index);
              },
            ),
            Visibility(
              visible: requestReceivedList.isEmpty,
              child: Center(
                child: Text(
                  '받은 요청이 없습니다.',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../utils/screen_movement.dart';
import '../../../utils/screen_size.dart';
import '../../../utils/snackbar_message.dart';
import 'category_data.dart';
import 'category_widget.dart';

// 카테고리 설정 화면
class CategorySettingScreen extends StatefulWidget {
  final bool checkData;

  const CategorySettingScreen({super.key, required this.checkData});

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen>
    with TickerProviderStateMixin {
  late ScreenSize screenSize;
  late TabController _tabController;
  final TextEditingController controllerName = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late bool nameChcek;
  late List<String> deleteUserList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categorySequence.length, vsync: this);
    categoryControlCheck = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    controllerName.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 스크린이 종료되거나 추가 버튼을 눌렀을때 실행되는 함수,
  // 서버에 데이터 업데이트 후 홈 화면으로 이동
  void _popScope() async {
    EasyLoading.show(status: '로딩 중입니다...');
    if (categoryControlCheck || widget.checkData) {
      await setCategory();
    }
    EasyLoading.dismiss();
    Navigator.of(context).pushAndRemoveUntil(
      screenMovementLeftToRight(const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => _popScope(), // 뒤로가기 버튼을 눌렀을때 실행
      child: Scaffold(
        appBar: AppBar(
          title: const Text("카테고리 설정"),
          backgroundColor: mainLightColor,
          leading: IconButton(
              onPressed: () {
                _popScope();
              },
              icon: const Icon(Icons.arrow_back_ios_new)),
        ),
        body: Column(
          children: [
            Container(
              width: screenSize.getWidthSize(),
              height: screenSize.getHeightPerSize(6),
              margin: EdgeInsets.fromLTRB(
                  screenSize.getWidthPerSize(5), 0, screenSize.getWidthPerSize(5), 0),
              child: Row(
                children: [
                  SizedBox(
                    width: screenSize.getWidthPerSize(70),
                    child: TextField(
                        controller: controllerName,
                        decoration: const InputDecoration(labelText: "카테고리 추가하기"),
                        keyboardType: TextInputType.text,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        nameChcek = categoryList.containsKey(controllerName.text);
                        if (!nameChcek &&
                            controllerName.text.isNotEmpty &&
                            categorySequence.length < 11 &&
                            controllerName.text.length > 1 &&
                            controllerName.text.length <= 10) {
                          addCategory(controllerName.text);
                          snackBarMessage(context, "카테고리를 추가하였습니다.");
                          Navigator.of(context).pushAndRemoveUntil(
                            screenMovementZero(const CategorySettingScreen(
                              checkData: true,
                            )),
                            (Route<dynamic> route) => false,
                          );
                        } else if (categorySequence.length >= 11) {
                          snackBarErrorMessage(context, "최대 10개의 카테고리만 추가할 수 있습니다.");
                        } else if (nameChcek) {
                          snackBarErrorMessage(context, "이미 존재하는 이름입니다.");
                        } else if (controllerName.text.isEmpty) {
                          snackBarErrorMessage(context, "입력값이 없습니다.");
                        } else {
                          snackBarErrorMessage(context, "2글자 이상 10글자 이하의 이름을 입력해주세요");
                        }
                      },
                      child: Text(
                        "추가",
                        style: TextStyle(
                            color: Colors.black, fontSize: screenSize.getHeightPerSize(1.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: screenSize.getHeightPerSize(1),
              width: screenSize.getWidthSize(),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black, width: 0.5))),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: screenSize.getWidthPerSize(10),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                      itemCount: categorySequence.length,
                      itemBuilder: (context, index) {
                        return Container(
                          //decoration: BoxDecoration(shape: BoxShape.circle,color: mainColor),
                          margin: EdgeInsets.fromLTRB(0, screenSize.getHeightPerSize(0.5), 0,
                              screenSize.getHeightPerSize(0.5)),
                          height: screenSize.getHeightPerSize(6),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    // animated_reorderable_list 패키지, 애니메이션 리스트, 드래그로 아이템의 순서를 변경 가능
                    child: AnimatedReorderableListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
                      items: categorySequence,
                      itemBuilder: (BuildContext context, int index) {
                        return CategoryWidget(
                          key: Key(categorySequence[index]),
                          screenSize: screenSize,
                          categoryName: categorySequence[index],
                        );
                      },
                      enterTransition: [FadeIn(), ScaleIn()],
                      exitTransition: [SlideInDown()],
                      insertDuration: const Duration(milliseconds: 300),
                      removeDuration: const Duration(milliseconds: 300),
                      // 순서를 변경했을 때 실행
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex && newIndex > categorySequence.length) {
                            newIndex -= 1;
                          }
                          final String item = categorySequence.removeAt(oldIndex);
                          categorySequence.insert(newIndex, item);
                          categoryControlCheck = true;
                        });
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../../utils/color.dart';
import '../../../utils/screen_movement.dart';
import '../../../utils/screen_size.dart';
import '../../home_screen.dart';
import '../category/category_data.dart';
import '../friend_data.dart';

class DetailChangeScreen extends StatefulWidget {
  final FriendData friendData;

  const DetailChangeScreen({super.key, required this.friendData});

  @override
  State<DetailChangeScreen> createState() => _DetailChangeScreenState();
}

class _DetailChangeScreenState extends State<DetailChangeScreen> {
  late ScreenSize screenSize;
  late FriendData friendData;
  final TextEditingController _textEditingController = TextEditingController();
  final MultiSelectController<String> _multiSelectController =
  MultiSelectController<String>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<DropdownItem<String>> items = [];
  List<String> selectedNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friendData = widget.friendData;
    if (friendData.friendCustomName != "") {
      _textEditingController.text = friendData.friendCustomName;
    }
    items = categorySequence
        .map((label) => DropdownItem(label: label, value: label))
        .toList();

    //위젯이 다 빌드되면 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (friendData.category.isNotEmpty) {
        for (String item in friendData.category) {
          int opIndex = items.indexOf(DropdownItem(label: item, value: item));
          _multiSelectController.selectAtIndex(opIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    _multiSelectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text("정보 수정"),
        backgroundColor: mainLightColor,
        actions: [
          TextButton(
            onPressed: () async {
              EasyLoading.show(status: '로딩 중입니다...');
              // if (_formKey.currentState!.validate()) {}
              if ((_textEditingController.text == "" &&
                      friendData.friendCustomName != "") ||
                  _textEditingController.text == friendData.friendNickName) {
                await updateFriendName(friendData, "");
              } else if (_textEditingController.text !=
                  friendData.friendCustomName) {
                await updateFriendName(friendData, _textEditingController.text);
              }
              if (selectedNames.isNotEmpty && (_multiSelectController.selectedItems.isNotEmpty) || (_multiSelectController.selectedItems.isEmpty && friendData.category.isNotEmpty)) {
                await addCategoryUserData(selectedNames, friendData);
              }
              EasyLoading.dismiss();
              Navigator.of(context).pushAndRemoveUntil(
                screenMovementZero(const HomeScreen()),
                    (Route<dynamic> route) => false,
              );
            },
            child: Text(
              "확인",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: screenSize.getHeightPerSize(1.8)),
            ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenSize.getWidthPerSize(80),
          child: Column(
            children: [
              SizedBox(
                height: screenSize.getHeightPerSize(4),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(9),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text(
                        "이름 설정",
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(2),
                            color: Colors.black),
                      ),
                      border: const OutlineInputBorder(),
                      // 기본 외곽선
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey, width: 1.0), // 활성화된 상태의 외곽선
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mainColor, width: 2.0), // 포커스된 상태의 외곽선
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.0), // 에러 상태의 외곽선
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red, width: 2.0), // 포커스된 에러 상태의 외곽선
                      ),
                    ),
                    style:
                        TextStyle(fontSize: screenSize.getHeightPerSize(2.5)),
                    controller: _textEditingController,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-zA-Zㄱ-ㅎ가-힣]')),
                    ],
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "이름을 입력해 주세요";
                    //   }
                    //   return null;
                    // },
                  ),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(3),
                width: screenSize.getWidthPerSize(80),
                child: Text(
                  "친구가 설정한 이름 : ${friendData.friendNickName}",
                  style: TextStyle(
                      fontSize: screenSize.getHeightPerSize(1.5),
                      color: Colors.grey),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(6),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              MultiDropdown<String>(
                items: items,
                controller: _multiSelectController,
                enabled: true,
                searchEnabled: false,
                chipDecoration: ChipDecoration(
                    backgroundColor: mainColor,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    borderSide: BorderSide(color: mainColor),
                    deleteIcon: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                    )),
                fieldDecoration: FieldDecoration(
                  labelText: "카테고리 설정",
                  labelStyle: TextStyle(
                      fontSize: screenSize.getHeightPerSize(2),
                      color: Colors.black),
                  hintText: "카테고리를 선택해 주세요",
                  prefixIcon: const Icon(Icons.category),
                  suffixIcon: const Icon(Icons.read_more),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: mainColor, width: 2.0), // 포커스된 상태의 외곽선
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red, width: 1.0), // 에러 상태의 외곽선
                  ),
                ),
                dropdownDecoration: DropdownDecoration(
                  marginTop: 2,
                  height: items.length >= 5 ? 250 : items.length*50,
                ),
                onSelectionChange: (selectedItems) {
                  //print(selectedItems);
                  selectedNames = selectedItems;
                },
                dropdownItemDecoration: DropdownItemDecoration(
                  selectedTextColor: mainLightColor,
                  selectedIcon: Icon(
                    Icons.check_box,
                    color: mainLightColor,
                  ),
                  textColor: Colors.black,
                  //selectedBackgroundColor: Colors.grey
                ),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return "카테고리를 선택해 주세요";
                //   }
                //   return null;
                // },
                // onSelectionChange: (selectedItems) {
                //   debugPrint("OnSelectionChange: $selectedItems");
                // },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

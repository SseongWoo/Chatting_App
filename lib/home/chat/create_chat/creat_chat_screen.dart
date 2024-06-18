import 'dart:io';
import 'dart:math';
import 'package:chattingapp/home/chat/chat_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/home/home_screen.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/color.dart';
import '../../../utils/image_picker.dart';
import '../../../utils/screen_movement.dart';

class CreateChat extends StatefulWidget {
  const CreateChat({super.key});

  @override
  State<CreateChat> createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerCode = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerExplain = TextEditingController();
  final GlobalKey<FormState> _creatChatKey = GlobalKey<FormState>();
  late ScreenSize screenSize;
  bool _isChecked = false;
  bool _error = false;
  List<int> selectValueList = [];
  late CroppedFile? _croppedProFile;
  bool _getImageState = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _controllerName.dispose();
    _controllerCode.dispose();
    _controllerPassword.dispose();
    _controllerExplain.dispose();
    super.dispose();
  }

  void _imagePicker(ImageSource imageSource) async {
    XFile? imageFile = await getImage(imageSource);
    if (imageFile != null) {
      _croppedProFile = await cropImage(imageFile);
      if (_croppedProFile != null) {
        setState(() {
          _getImageState = true;
        });
      }
    }
  }

  String createRandomCode() {
    Random random = Random();
    var uuid = const Uuid();
    String fullUuid = uuid.v4();
    int rand = random.nextInt(fullUuid.length - 9);
    String shortUuid = fullUuid.substring(rand, rand + 8); // 첫 8문자 사용

    return shortUuid;
  }

  void startCreatChatRoom() async {
    List<String> invitationList = [];

    invitationList.clear();
    invitationList.add(myData.myUID);
    for (var index in selectValueList) {
      invitationList.add(friendList[friendListSequence[index]]!.friendUID);
    }

    ChatRoomData chatRoomData = ChatRoomData(
        _controllerCode.text,
        _controllerName.text,
        "",
        DateFormat("yyyy-MM-dd").format(DateTime.now()),
        myData.myUID,
        _controllerPassword.text,
        _controllerExplain.text,
        _isChecked,
        invitationList);

    await createChatRoom(chatRoomData);
    EasyLoading.dismiss();
    Navigator.of(context).pushAndRemoveUntil(
      screenMovementLeftToRight(const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 생성'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screenSize.getWidthPerSize(90),
            child: Form(
              key: _creatChatKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* 프로필 */
                  Text(
                    '채팅방 프로필',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(1),
                  ),
                  GestureDetector(
                    onTap: () {
                      _imagePicker(ImageSource.gallery);
                    },
                    child: Center(
                      child: SizedBox(
                        height: screenSize.getHeightPerSize(15),
                        width: screenSize.getHeightPerSize(15),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _getImageState
                                  ? Image.file(
                                      File(_croppedProFile!.path),
                                    )
                                  : Image.asset(
                                      'assets/images/blank_profile.png',
                                    ),
                            ),
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Container(
                                  height: screenSize.getHeightPerSize(4),
                                  width: screenSize.getHeightPerSize(4),
                                  decoration:
                                      BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.photo_camera,
                                  )),
                            ),
                            Visibility(
                              visible: _getImageState,
                              child: Positioned(
                                right: -10,
                                top: -10,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _croppedProFile = null;
                                      _getImageState = false;
                                    });
                                  },
                                  child: Container(
                                      height: screenSize.getHeightPerSize(4),
                                      width: screenSize.getHeightPerSize(4),
                                      decoration: const BoxDecoration(
                                          color: Colors.red, shape: BoxShape.circle),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  /* 프로필 */

                  /* 이름 */
                  Text(
                    '채팅방 이름(필수)',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(1),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '채팅방 이름을 입력해주세요',
                      border: const OutlineInputBorder(),
                      // 기본 외곽선
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0), // 활성화된 상태의 외곽선
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 2.0), // 포커스된 상태의 외곽선
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0), // 에러 상태의 외곽선
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0), // 포커스된 에러 상태의 외곽선
                      ),
                    ),
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    controller: _controllerName,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    validator: (String? value) {
                      if (value?.isEmpty ?? true) return '채팅방 이름을 입력해 주세요';
                      return null;
                    },
                    maxLength: 20,
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '채팅방 코드(필수)',
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(1.7),
                            fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _controllerCode.text = createRandomCode();
                          });
                        },
                        child: Text(
                          '자동 생성',
                          style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(1),
                  ),
                  /* 이름 */

                  /* 코드 */
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '채팅방 코드를 설정해주세요',
                      border: const OutlineInputBorder(),
                      // 기본 외곽선
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0), // 활성화된 상태의 외곽선
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 2.0), // 포커스된 상태의 외곽선
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0), // 에러 상태의 외곽선
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0), // 포커스된 에러 상태의 외곽선
                      ),
                    ),
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    controller: _controllerCode,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    validator: (String? value) {
                      if (value?.isEmpty ?? true) return '채팅방 코드를 입력해 주세요';
                      return null;
                    },
                    maxLength: 8,
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  /* 코드 */

                  /* 공개 설정 */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '채팅방 공개 설정',
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(1.7),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '채팅방을 검색할때 검색에 보이지 않게 합니다.',
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(1.5),
                                color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isChecked,
                        activeColor: mainBoldColor,
                        activeTrackColor: mainLightColor,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  /* 공개 설정 */

                  /* 암호 */
                  Text(
                    '채팅방 암호',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(1),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '채팅방 암호를 설정해 주세요',
                      border: const OutlineInputBorder(),
                      // 기본 외곽선
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0), // 활성화된 상태의 외곽선
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 2.0), // 포커스된 상태의 외곽선
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0), // 에러 상태의 외곽선
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0), // 포커스된 에러 상태의 외곽선
                      ),
                    ),
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    keyboardType: TextInputType.visiblePassword,
                    controller: _controllerPassword,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    maxLength: 12,
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  /* 암호 */

                  /* 설명 */
                  Text(
                    '채팅방 설명',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(1),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '채팅방 설명을 입력해 주세요',
                      border: const OutlineInputBorder(),
                      // 기본 외곽선
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0), // 활성화된 상태의 외곽선
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 2.0), // 포커스된 상태의 외곽선
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0), // 에러 상태의 외곽선
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0), // 포커스된 에러 상태의 외곽선
                      ),
                    ),
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.3)),
                    controller: _controllerExplain,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    maxLines: 10,
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  /* 설명 */

                  /* 유저 목록 */
                  Text(
                    '채팅방 유저 목록',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(
                  //   height: screenSize.getHeightPerSize(2),
                  // ),
                  SearchChoices.multiple(
                    items: friendListSequence.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    selectedItems: selectValueList,
                    hint: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('초대할 친구들을 선택해주세요'),
                    ),
                    searchHint: '초대할 친구들을 선택해주세요',
                    onChanged: (value) {
                      setState(() {
                        selectValueList = value;
                      });
                    },
                    closeButton: (selectedItems) {
                      return (selectedItems.isNotEmpty
                          ? "${selectedItems.length == 1 ? '"${friendListSequence[selectedItems.first]}"' : '${selectedItems.length}명'} 저장"
                          : "선택하지 않고 저장");
                    },
                    isExpanded: true,
                  ),
                  Visibility(
                    visible: _error,
                    child: Text(
                      '초대할 친구들을 한명이상 선택해주세요',
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1.4), color: errorColor),
                    ),
                  ),

                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
                  /* 유저 목록 */

                  /* 완료 버튼 */
                  SizedBox(
                    width: screenSize.getWidthPerSize(90),
                    height: screenSize.getHeightPerSize(6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                      onPressed: () async {
                        EasyLoading.show();
                        if (_creatChatKey.currentState!.validate() && selectValueList.isNotEmpty) {
                          bool checkRoomCode = await checkRoomUid(_controllerName.text);
                          if (!checkRoomCode) {
                            startCreatChatRoom();
                          } else {
                            snackBarErrorMessage(context, '이미 사용 중인 코드입니다. 다른 코드를 입력해 주세요');
                          }
                        } else if (selectValueList.isEmpty) {
                          setState(() {
                            _error = true;
                          });
                        }
                        EasyLoading.dismiss();
                      },
                      child: Text(
                        "완료",
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(3),
                  ),
                  /* 완료 버튼 */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

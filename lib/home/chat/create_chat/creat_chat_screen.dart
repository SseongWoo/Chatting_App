import 'dart:io';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/chat/chat_room/chat_room_screen.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import '../../../utils/color/color.dart';
import '../../../utils/get_people_data.dart';
import '../../../utils/image/image_picker.dart';
import '../chat_room/chat_room_data.dart';
import 'creat_chat_data.dart';

class CreateChat extends StatefulWidget {
  const CreateChat({super.key});

  @override
  State<CreateChat> createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  final TextEditingController _controllerName = TextEditingController(); //이름 텍스트필드 컨트롤러
  final TextEditingController _controllerCode = TextEditingController(); //uid 텍스트필드 컨트롤러
  final TextEditingController _controllerPassword = TextEditingController(); //암호 텍스트필드 컨트롤러
  final TextEditingController _controllerExplain = TextEditingController(); //설명 텍스트필드 컨트롤러
  final GlobalKey<FormState> _creatChatKey = GlobalKey<FormState>();
  late CroppedFile? _croppedProFile;
  bool _isChecked = false;
  bool _error = false;
  List<int> selectValueList = []; //드롭다운 메뉴중 선택한 아이템 리스트
  bool _getImageState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _croppedProFile = null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controllerName.dispose();
    _controllerCode.dispose();
    _controllerPassword.dispose();
    _controllerExplain.dispose();
    super.dispose();
  }

  // 채팅방 프로필 사진을 등록하기 위해 이미지를 가져와서 수정하는 함수
  void _imagePicker(ImageSource imageSource) async {
    XFile? imageFile = await getImage(imageSource); // 이미지를 카메라나 갤러리에서 가져오는 기능
    if (imageFile != null) {
      _croppedProFile = await cropImage(imageFile);

      // 이미지를 가져와서 _croppedProFile변수가 비어있지 않을 경우 화면을 새로고침해서 이미지를 화면에 띄움
      if (_croppedProFile != null) {
        setState(() {
          _getImageState = true;
        });
      }
    }
  }

  // 채팅방을 만들기 위한 정보들을 다 입력하고 완료 버튼을 눌렀을경우 실행되는 함수
  // 채팅방 데이터를 서버에 등록후 해당 채팅방으로 이동
  void _startCreatChatRoom() async {
    String profileUrl = '';
    EasyLoading.show();
    List<String> invitationList = [];

    invitationList.clear();
    invitationList.add(myData.myUID);
    for (var index in selectValueList) {
      invitationList.add(friendList[friendListSequence[index]]!.friendUID);
    }

    if (_croppedProFile != null) {
      profileUrl = await uploadChatRoomProfile(_croppedProFile, _controllerCode.text);
    }

    ChatRoomData chatRoomData = ChatRoomData(
        _controllerCode.text,
        _controllerName.text,
        profileUrl,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
        myData.myUID,
        _controllerPassword.text,
        _controllerExplain.text,
        _isChecked,
        invitationList);

    await createChatRoom(chatRoomData);
    if (_isChecked) {
      await setChatPublicData(chatRoomData);
    }
    await getChatData(chatRoomData.chatRoomUid);
    List<ChatPeopleClass> chatPeople = await getPeopleData(chatRoomData.chatRoomUid);
    EasyLoading.dismiss();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          chatRoomSimpleData: ChatRoomSimpleData(chatRoomData.chatRoomUid, '', ''),
          chatPeopleList: chatPeople,
        ),
      ),
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
                  Text(
                    '채팅방 유저 목록',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                  ),
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
                          ? '${selectedItems.length == 1 ? '"${friendListSequence[selectedItems.first]}"' : '${selectedItems.length}명'} 저장'
                          : '선택하지 않고 저장');
                    },
                    isExpanded: true,
                  ),
                  Visibility(
                    visible: _error,
                    child: Text(
                      '현재 채팅방에 추가할 수 있는 인원 수를 초과했습니다. 최대 100명까지 초대할 수 있습니다.',
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(1.4), color: errorColor),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(2),
                  ),
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
                        if (_creatChatKey.currentState!.validate() &&
                            selectValueList.length <= 100) {
                          bool checkRoomCode = await checkRoomUid(_controllerName.text);
                          if (!checkRoomCode) {
                            _startCreatChatRoom();
                          } else {
                            snackBarErrorMessage(context, '이미 사용 중인 코드입니다. 다른 코드를 입력해 주세요');
                          }
                        } else if (selectValueList.length > 100) {
                          setState(() {
                            _error = true;
                          });
                        }
                        EasyLoading.dismiss();
                      },
                      child: Text(
                        '완료',
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

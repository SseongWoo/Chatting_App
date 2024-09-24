import 'dart:io';
import 'package:chattingapp/home/chat/chat_room/chat_room_screen.dart';
import 'package:chattingapp/home/chat/chat_room/setting_chat_room/setting_room_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/color/color.dart';
import '../../../../utils/data_refresh.dart';
import '../../../../utils/get_people_data.dart';
import '../../../../utils/image/image_picker.dart';
import '../../../../utils/screen_movement.dart';
import '../../../../utils/screen_size.dart';
import '../../chat_list_data.dart';
import '../../create_chat/creat_chat_data.dart';
import '../chat_room_data.dart';

// 채팅방 개인 설정 화면
class SettingRoom extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;
  const SettingRoom({super.key, required this.chatRoomSimpleData});

  @override
  State<SettingRoom> createState() => _SettingRoomState();
}

class _SettingRoomState extends State<SettingRoom> {
  final TextEditingController _controllerName = TextEditingController();
  late CroppedFile? _croppedProFile;
  late ChatRoomSimpleData _chatRoomSimpleData;
  late ChatRoomData _chatRoomData;
  String _imageUrl = '';
  bool _getImageState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomSimpleData = widget.chatRoomSimpleData;
    _chatRoomData = chatRoomDataList[_chatRoomSimpleData.chatRoomUid]!;
    _controllerName.text = _chatRoomSimpleData.chatRoomCustomName;
    _getImageUrl();
  }

  // 이미지 위젯을 사용자가 설정한 이미지가 있을경우 그 이미지로 생성, 아닐경우 채팅방 기본 이미지로 생성
  void _getImageUrl() {
    if (_chatRoomSimpleData.chatRoomCustomProfile.isNotEmpty) {
      _imageUrl = _chatRoomSimpleData.chatRoomCustomProfile;
    } else if (_chatRoomData.chatRoomProfile.isNotEmpty) {
      _imageUrl = _chatRoomData.chatRoomProfile;
    }
  }

  // 이미지를 사용자 갤러기에서 가져와서 설정 후 등록하는 작업
  void _imagePicker(ImageSource imageSource) async {
    XFile? imageFile = await getImage(imageSource);
    if (imageFile != null) {
      _croppedProFile = await cropImage(imageFile);
      if (_croppedProFile != null) {
        setState(() {
          _imageUrl = _croppedProFile!.path;
          _getImageState = true;
        });
      }
    }
  }

  // 이름과 프로필 사진중 변경된 값이 있을경우 정보 업데이트 후 채팅방으로 되돌아가는 함수
  void _updateChatRoomCustomSetting() async {
    if (_controllerName.text == _chatRoomSimpleData.chatRoomCustomName &&
        _chatRoomSimpleData.chatRoomCustomProfile == _imageUrl) {
      Navigator.pop(context);
    } else {
      EasyLoading.show();
      if (_controllerName.text.isEmpty) {
        _controllerName.text = _chatRoomSimpleData.chatRoomCustomName;
      }
      if (_croppedProFile != null) {
        _imageUrl = await uploadChatRoomCustomProfile(_croppedProFile, _chatRoomData.chatRoomUid);
      }
      _chatRoomSimpleData.chatRoomCustomName = _controllerName.text;
      _chatRoomSimpleData.chatRoomCustomProfile = _imageUrl;
      await updateChatData(_chatRoomSimpleData);
      await refreshData();

      await getChatData(_chatRoomSimpleData.chatRoomUid);
      List<ChatPeopleClass> chatPeople = await getPeopleData(_chatRoomSimpleData.chatRoomUid);
      EasyLoading.dismiss();
      Navigator.of(context).pushAndRemoveUntil(
        screenMovementLeftToRight(
            ChatRoomScreen(chatRoomSimpleData: _chatRoomSimpleData, chatPeopleList: chatPeople)),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 커스텀 설정'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screenSize.getWidthPerSize(90),
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
                                : _imageUrl.isNotEmpty
                                    ? Image.network(
                                        _imageUrl,
                                        // 이미지 로딩
                                        loadingBuilder: (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // 이미지 로드 완료
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          }
                                        },
                                        errorBuilder: (BuildContext context, Object error,
                                            StackTrace? stackTrace) {
                                          return const Center(
                                            child: Text('이미지 로딩 실패'),
                                          );
                                        },
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
                                decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle),
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
                                    // 클릭시 화면에 보여지고 있는 이미지 제거
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
                  '채팅방 이름',
                  style: TextStyle(
                      fontSize: screenSize.getHeightPerSize(1.7), fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(1),
                ),
                TextField(
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
                  maxLength: 20,
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(2),
                ),
                const Text(
                  '해당 설정은 자신에게만 보이는 설정입니다.\n채팅방 전체 설정은 관리자만 할 수 있습니다.',
                  style: TextStyle(color: Colors.grey),
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
                      _updateChatRoomCustomSetting();
                    },
                    child: Text(
                      "완료",
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
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
    );
  }
}

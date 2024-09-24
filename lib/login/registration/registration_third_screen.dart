import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/image/image_picker.dart';
import '../../utils/my_data.dart';
import '../../utils/screen_size.dart';
import 'authentication.dart';

class RegistrationThirdScreen extends StatefulWidget {
  const RegistrationThirdScreen({super.key});

  @override
  State<RegistrationThirdScreen> createState() => _RegistrationThirdScreenState();
}

class _RegistrationThirdScreenState extends State<RegistrationThirdScreen> {
  final TextEditingController _controllerNickName = TextEditingController();
  final FocusNode _focusNodeNickName = FocusNode();
  final _registrationThirdFormKey = GlobalKey<FormState>();
  CroppedFile? _croppedFile; // 카메라 또는 갤러리의 이미지를 저장할 변수

  @override
  void dispose() {
    _controllerNickName.dispose();
    super.dispose();
  }

  // 사용자의 프로필사진을 등록하기 위해 이미지를 가져와서 수정해 저장하는 함수
  void _imagePicker(ImageSource imageSource) async {
    XFile? imageFile = await getImage(imageSource);
    if (imageFile != null) {
      CroppedFile? croppedFile = await cropImage(imageFile);
      setState(() {
        if (croppedFile != null) {
          _croppedFile = croppedFile;
        }
      });
    }
  }

  // 저장된 이미지를 외부 DB와 저장소에 저장하는 함수
  void _saveData(BuildContext context) async {
    EasyLoading.show();
    await saveUserImage(_croppedFile, _controllerNickName.text, context);
    await getMyData();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: screenSize.getHeightSize(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      '계정 설정\n',
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      '마지막 단계입니다!\n사용할 사용자의 닉네임과 프로필 사진을 등록해주세요. 이 정보들은 나중에 변경할 수 있습니다.',
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  GestureDetector(
                    onTap: () {
                      _imagePicker(ImageSource.gallery);
                    },
                    child: Center(
                      child: SizedBox(
                        height: screenSize.getHeightPerSize(20),
                        width: screenSize.getHeightPerSize(20),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _croppedFile != null
                                  ? Image.file(
                                      File(_croppedFile!.path),
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
                              visible: _croppedFile != null,
                              child: Positioned(
                                right: -10,
                                top: -10,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _croppedFile = null;
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
                  SizedBox(
                    height: screenSize.getHeightPerSize(10),
                    width: screenSize.getWidthPerSize(60),
                    child: Form(
                      key: _registrationThirdFormKey,
                      child: TextFormField(
                        focusNode: _focusNodeNickName,
                        controller: _controllerNickName,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Zㄱ-ㅎ가-힣]')),
                        ],
                        maxLength: 8,
                        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) return '닉네임을 입력해 주세요';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(microseconds: Platform.isIOS ? 300000 : 130000),
            curve: Curves.easeInOut,
            bottom: _focusNodeNickName.hasFocus ? -screenSize.getHeightPerSize(8) : 0,
            child: SizedBox(
              height: screenSize.getHeightPerSize(8),
              width: screenSize.getWidthPerSize(100),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0), // 왼쪽 위 모서리만 둥글게 설정
                      topRight: Radius.circular(20.0), // 오른쪽 위 모서리만 둥글게 설정
                    ), // 모서리를 둥글게 설정
                  ),
                ),
                onPressed: () {
                  if (_registrationThirdFormKey.currentState!.validate()) {
                    _saveData(context);
                  }
                },
                child: Text(
                  '완료',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

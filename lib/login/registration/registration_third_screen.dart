import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/image_picker.dart';
import '../../utils/screen_size.dart';
import 'authentication.dart';

class RegistrationThirdScreen extends StatefulWidget {
  const RegistrationThirdScreen({super.key});

  @override
  State<RegistrationThirdScreen> createState() => _RegistrationThirdScreenState();
}

class _RegistrationThirdScreenState extends State<RegistrationThirdScreen> {
  TextEditingController controllerNickName = TextEditingController();
  final FocusNode focusNodeNickName = FocusNode();
  late ScreenSize screenSize;
  bool loadingState = false;
  bool pikerState = false;
  bool cropState = false;
  late Size size;
  final _registrationThirdFormKey = GlobalKey<FormState>();
  bool isVisibility = false;
  double visibilityAnimated = 0.0;

  // 카메라 또는 갤러리의 이미지를 저장할 변수
  XFile? _imageFile;
  CroppedFile? _croppedFile;

  @override
  void dispose() {
    controllerNickName.dispose();
    super.dispose();
  }

  void imagePicker(ImageSource imageSource) async {
    setState(() {
      pikerState = true;
    });
    XFile? imageFile = await getImage(imageSource); // getImage 함수 비동기 호출
    setState(() {
      _imageFile = imageFile; // 비동기 호출이 완료되면 상태 변경
      pikerState = false;
      isVisibility = true;
    });
  }

  void imageCropped() async {
    setState(() {
      cropState = true;
    });
    if (_imageFile != null) {
      CroppedFile? croppedFile = await cropImage(_imageFile);
      setState(() {
        _croppedFile = croppedFile;
        cropState = false;
        isVisibility = true;
      });
    }
  }

  void saveData(BuildContext context) async {
    setState(() {
      loadingState = true;
    });
    await saveUserImage(_imageFile, _croppedFile, controllerNickName.text, context);
    setState(() {
      loadingState = false;
    });
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
                      "계정 설정\n",
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(4)),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.getWidthPerSize(80),
                    child: Text(
                      "마지막 단계입니다!\n사용할 사용자의 닉네임과 프로필 사진을 등록해주세요. 이 정보들은 나중에 변경할 수 있습니다.",
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(5),
                  ),
                  SizedBox(
                      width: screenSize.getHeightPerSize(60),
                      height: screenSize.getHeightPerSize(15),
                      child: _imageFile != null
                          // 불러온 이미지가 있으면 출력
                          ? Center(
                              child: Image.file(
                                _croppedFile != null
                                    ? File(_croppedFile!.path)
                                    : File(_imageFile!.path),
                              ),
                            )
                          // 불러온 이미지가 없으면 텍스트 출력
                          : const Center(
                              child: Text("불러온 이미지가 없습니다."),
                            )
                      //Container(color: Colors.blue,)
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
                        focusNode: focusNodeNickName,
                        controller: controllerNickName,
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
                  AnimatedOpacity(
                    opacity:
                        _imageFile != null ? visibilityAnimated = 1.0 : visibilityAnimated = 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    onEnd: () {
                      setState(() {
                        if (visibilityAnimated == 0.0) {
                          isVisibility = false;
                        } else {
                          isVisibility = true;
                        }
                      });
                    },
                    child: Visibility(
                      visible: isVisibility,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenSize.getHeightPerSize(4),
                            width: screenSize.getWidthPerSize(30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                                shape: const BeveledRectangleBorder(),
                              ),
                              onPressed: () {
                                imageCropped();
                              },
                              child: cropState
                                  ? const SpinKitThreeInOut(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "프로필 편집",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenSize.getHeightPerSize(1.5)),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.getHeightPerSize(4),
                            width: screenSize.getWidthPerSize(30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                                shape: const BeveledRectangleBorder(),
                              ),
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                  _croppedFile = null;
                                });
                              },
                              child: cropState
                                  ? const SpinKitThreeInOut(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "프로필 제거",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenSize.getHeightPerSize(1.5)),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.getHeightPerSize(4),
                    width: screenSize.getWidthPerSize(60),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: const BeveledRectangleBorder(),
                      ),
                      onPressed: () {
                        imagePicker(ImageSource.gallery);
                      },
                      child: pikerState
                          ? const SpinKitThreeInOut(
                              color: Colors.white,
                            )
                          : Text(
                              "앨범",
                              style: TextStyle(
                                  color: Colors.black, fontSize: screenSize.getHeightPerSize(1.8)),
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
            bottom: focusNodeNickName.hasFocus ? -screenSize.getHeightPerSize(8) : 0,
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
                  if (_registrationThirdFormKey.currentState!.validate() && loadingState == false) {
                    saveData(context);
                  }
                },
                child: loadingState
                    ? const SpinKitThreeInOut(
                        color: Colors.white,
                      )
                    : Text(
                        "완료",
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

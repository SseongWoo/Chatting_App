import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

Future<XFile?> getImage(ImageSource imageSource) async {
  // Image Picker 인스턴스 생성
  final ImagePicker picker = ImagePicker();
  try {
    // 카메라 또는 갤러리의 이미지
    final XFile? imageFile = await picker.pickImage(source: imageSource
        //, maxHeight: 300, maxWidth: 300
        );

    if (imageFile != null) {
      return imageFile;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<XFile?> getVideo(ImageSource imageSource) async {
  // Image Picker 인스턴스 생성
  final ImagePicker picker = ImagePicker();
  try {
    // 카메라 또는 갤러리의 이미지
    final XFile? imageFile = await picker.pickMedia();

    if (imageFile != null) {
      return imageFile;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

// 여러 파일을 선택 가능하지만 이미지만 선택 가능한 기능
Future<List<XFile>?> getMultipleMedia() async {
  final ImagePicker picker = ImagePicker();
  try {
    final List<XFile> multipleImageFile = await picker.pickMultiImage();
    return multipleImageFile;
  } catch (e) {
    return null;
  }
}

// 이미지와 동영상 여러개 선택 가능한 기능
Future<List<XFile>?> getMultipleMediaV2() async {
  final ImagePicker picker = ImagePicker();
  try {
    final List<XFile> multipleImageFile = await picker.pickMultipleMedia();
    return multipleImageFile;
  } catch (e) {
    return null;
  }
}

// 이미지를 자르거나 회전하는 함수
Future<CroppedFile?> cropImage(XFile? imageFile) async {
  if (imageFile != null) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path, // 사용할 이미지 경로
      compressFormat: ImageCompressFormat.jpg, // 저장할 이미지 확장자(jpg/png)
      compressQuality: 50, // 저장할 이미지의 퀄리티
      uiSettings: [
        // 안드로이드 UI 설정
        AndroidUiSettings(
            toolbarTitle: '이미지 자르기/회전하기',
            // 타이틀바 제목
            toolbarColor: mainColor,
            // 타이틀바 배경색
            toolbarWidgetColor: Colors.white,
            // 타이틀바 단추색
            initAspectRatio: CropAspectRatioPreset.original,
            // 이미지 크로퍼 시작 시 원하는 가로 세로 비율
            lockAspectRatio: false), // 고정 값으로 자르기 (기본값 : 사용안함)
        // iOS UI 설정
        IOSUiSettings(
          title: '이미지 자르기/회전하기', // 보기 컨트롤러의 맨 위에 나타나는 제목
        ),
      ],
    );

    if (croppedFile != null) {
      // 자르거나 회전한 이미지를 앱에 출력하기 위해 앱의 상태 변경
      return croppedFile;
    }
    return null;
  }
  return null;
}

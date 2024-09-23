# Futter Talk
## 개요

- 프로젝트 : 플러터와 파이어베이스를 사용한 채팅어플
- 분류 : 개인프로젝트
- 제작기간 : 24.06~24.09
- 사용기술 : Flutter, Dart, FireBase Authentication, FireBase Cloud Firestore, FireBase Storage, FireBase Remote Config
- 사용 IDE : Android Studio
- 사용 디바이스 : iPhone 15 pro max, galaxy s23+

## 개발환경
- Android Studio Koala | 2024.1.1
- Flutter 3.24.3
- Dart 3.5.3

## 프로젝트 소개
- 이 프로젝트는 AOS, IOS 에서 동작하는 크로스플랫폼 프로젝트이며, 사용자들간 실시간 채팅을 사용하여 대화가 가능하며, 다양한 커스텀을 통해 사용자가 원하는 채팅방의 UI를 사용할수 있도록 할수 있도록 제작하였습니다.

## 주요 기능
- 1대1 채팅 및 그룹 채팅, 그룹 오픈채팅 생성 기능
- 이미지, 동영상 전송 및 다운로드 기능
- Firebase 인증을 통한 이메일 인증기능
- 채팅방의 배경, 말풍선, 문자 크기등 다양한 커스텀 기능

## 프로젝트 구성
### 화면 구성


### 디렉토리 구조

```sh
assets
├── fonts
│   └── GyeonggiTitle_Medium.ttf : 어플 기본 글꼴
└── images
    ├── blank_profile.png : 유저 기본 이미지
    └── logo.png : 타이틀 로고
```

```sh
lib
├── error : 에러관련 폴더
│   ├── error_dialog.dart
│   └── error_report_screen.dart
├── firebase_options.dart
├── home : 메인화면 폴더
│   ├── chat	: 채팅관련 폴더
│   │   ├── chat_list_data.dart
│   │   ├── chat_list_screen.dart
│   │   ├── chat_list_widget.dart
│   │   ├── chat_room : 채팅방 관련 폴더
│   │   │   ├── add_person : 채팅방 인원초대 관련 폴더
│   │   │   │   ├── add_person_data.dart
│   │   │   │   └── add_person_screen.dart
│   │   │   ├── chat_room_data.dart
│   │   │   ├── chat_room_dialog.dart
│   │   │   ├── chat_room_screen.dart
│   │   │   ├── chat_room_widget.dart
│   │   │   ├── search_chat : 검색 관련 폴더
│   │   │   │   ├── search_room_data.dart
│   │   │   │   ├── search_room_dialog.dart
│   │   │   │   ├── search_room_screen.dart
│   │   │   │   └── search_room_widget.dart
│   │   │   └── setting_chat_room : 채팅방 설정 관련 폴더
│   │   │       ├── setting_room.dart
│   │   │       ├── setting_room_data.dart
│   │   │       ├── setting_room_manager.dart
│   │   │       └── setting_room_widget.dart
│   │   └── create_chat : 채팅방 생성 관련 폴더
│   │       ├── creat_chat_data.dart
│   │       └── creat_chat_screen.dart
│   ├── friend : 친구 관련 폴더
│   │   ├── category : 친구 분류를 위한 카테고리 관련 폴더
│   │   │   ├── category_data.dart
│   │   │   ├── category_setting_screen.dart
│   │   │   └── category_widget.dart
│   │   ├── detail : 친구 상세정보 관련 폴더
│   │   │   ├── detail_change_screen.dart
│   │   │   └── detail_information_screen.dart
│   │   ├── friend_data.dart
│   │   ├── friend_screen.dart
│   │   ├── friend_widget.dart
│   │   └── request : 친구 추가,요청 관련 폴더
│   │       ├── friend_request_screen.dart
│   │       ├── request_data.dart
│   │       └── request_widget.dart
│   ├── home_screen.dart : 메인화면
│   └── information : 어플 설정 폴더
│       ├── delete_user_information
│       │   └── delete_user_information_screen.dart
│       ├── information_data.dart
│       ├── information_dialog.dart
│       ├── information_screen.dart
│       ├── information_widget.dart
│       ├── questions : 문의사항 폴더
│       │   └── questions_screen.dart
│       └── update_information : 어플 버전 확인 폴더
│           └── update_information_screen.dart
├── login : 로그인 관련 폴더
│   ├── find : 계정 찾기 관련 폴더
│   │   ├── account_find_first_screen.dart
│   │   └── account_find_second_screen.dart
│   ├── login_screen.dart
│   └── registration : 회원가입 관련 폴더
│       ├── authentication.dart
│       ├── registration_dialog.dart
│       ├── registration_first_screen.dart
│       ├── registration_second_screen.dart
│       └── registration_third_screen.dart
├── main.dart
├── splash : 로딩창 관련 폴더
│   ├── splash_dialog.dart
│   └── splash_screen.dart
└── utils : 다양한 기능 관련 폴더
    ├── color : 색상 관련 폴더
    │   ├── color.dart
    │   └── color_picker.dart
    ├── convert_array.dart : 맵, 리스트 형식변환 기능
    ├── copy.dart : 복사 기능
    ├── data_refresh.dart : 데이터 새로고침 기능
    ├── date_check.dart : 날짜 일수 검사 기능
    ├── file_download.dart : 파일 다운로드 기능
    ├── get_people_data.dart : 유저 데이터 가져오는 기능
    ├── image : 이미지 관련 폴더
    │   ├── image_picker.dart
    │   ├── image_viewer.dart
    │   └── image_widget.dart
    ├── launch_browser.dart : 외부 브라우저 호출 기능
    ├── logger.dart : 로그 기능
    ├── my_data.dart : 사용자 데이터 파일
    ├── platform_check.dart : os 체크 기능
    ├── public_variable_data.dart : 전역변수 파일
    ├── screen_movement.dart : 화면 이동 효과 기능
    ├── screen_size.dart : 화면 크기 파일
    ├── shared_preferences.dart : 내부 저장소 저장,불러오기 기능
    ├── snackbar_message.dart : 스낵바 메세지 호출 기능
    └── state_observer.dart : 어플 구동상태 확인 기능
```

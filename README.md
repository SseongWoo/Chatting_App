# Futter Talk
<img src = "https://github.com/user-attachments/assets/83c2f12e-7a73-455a-829a-8afbd391c265" width="350" height="350">

## 프로젝트 소개
- 이 프로젝트는 AOS, IOS 에서 동작하는 크로스플랫폼 프로젝트이며, 사용자들간 실시간 채팅을 사용하여 대화가 가능하며, 다양한 커스텀을 통해 사용자가 원하는 채팅방의 UI를 사용할수 있도록 할수 있도록 제작하였습니다.

## 개요
- 프로젝트 : 플러터와 파이어베이스를 사용한 채팅어플
- 분류 : 개인프로젝트
- 제작기간 : 24.06~24.09
- 사용기술 : Flutter, Dart, FireBase Authentication, FireBase Cloud Firestore, FireBase Storage, FireBase Remote Config
- 사용 IDE : Android Studio
- 사용 디바이스 : iPhone 15 pro max, Galaxy S23+

## 개발환경
- Android Studio Koala | 2024.1.1
- Flutter 3.24.3
- Dart 3.5.3

## 주요 기능
- 1대1 채팅 및 그룹 채팅, 그룹 오픈채팅 생성 기능
- 이미지, 동영상 전송 및 다운로드 기능
- Firebase 인증을 통한 이메일 인증기능
- 채팅방의 배경, 말풍선, 문자 크기등 다양한 커스텀 기능

## 프로젝트 구성
### 화면 구성
|로그인|메인화면_친구|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/25e4cb88-0cd1-4d8b-83d7-cc4a8601ebdc" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/aff6ce0e-6678-4ccd-b34e-eb54b95f8971" width="350" height="750">|
|메인화면_개인,단체채팅|내정보 및 설정|
|<img src = "https://github.com/user-attachments/assets/ba5b4a2a-f93d-4b1f-b19d-064a8d3f3ab0" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/7d62a4da-f2c5-49ab-9ca3-dd3b2e9c8058" width="350" height="750">|
|채팅방 화면||
|<img src = "https://github.com/user-attachments/assets/2e8cd6f5-4599-47b3-9b29-6acb1d3c01ad" width="350" height="750">||

<details><summary>회원가입 및 비밀번호 찾기 화면구성</summary>
    
|회원가입 1단계|회원가입 2단계|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/687091ac-494e-4dda-945e-f9d8bbd7971c" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/5530ec1e-33ec-49c4-9834-065229d5891b" width="350" height="750">|    
|회원가입 3단계|계정 찾기 1단계|
|<img src = "https://github.com/user-attachments/assets/d3a42b74-07fb-402e-ab02-1546c6c5e83b" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/bcd06624-4740-4a5d-8fc8-d64d0d4a6b5b" width="350" height="750">|
|계정 찾기 2단계||
|<img src = "https://github.com/user-attachments/assets/6ec8a9bd-b5d1-435e-acbf-639fe6d482a8" width="350" height="750">|>|
</details>

<details><summary>친구 추가 요청 및 상세정보 화면구성</summary>
    
|친구 추가_보낸 요청|친구 추가_받은 요청|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/4e271877-672b-42f2-a485-427c2a13fadc" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/e29ae69b-5824-41a2-81ef-d4217f642e10" width="350" height="750">|
|친구 상세정보|친구 정보수정|
|<img src = "https://github.com/user-attachments/assets/fcae3763-2a19-4a0a-be9a-9e97e9d57fe7" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/aeb4f18d-174c-41b2-9081-9e9bc9d8e9bc" width="350" height="750">|
</details>

<details><summary>카테고리 및 채팅방 생성 화면구성</summary>
    
|카테고리 설정|채팅방 생성|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/b916b00f-abc5-4e73-80be-01d117a81766" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/15aae425-4ccd-4a99-9f56-588a6311647f" width="350" height="750">|
</details>

<details><summary>채팅방 자세한 화면구성</summary>
    
|개인 채팅방 드로어|개인,단체 채팅방 커스텀 설정|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/460cf5d2-e4c8-42fb-9618-e578697531f2" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/651cb726-33ce-4411-a94b-87747a35465a" width="350" height="750">|
|단체 채팅방 드로어|단체 채팅방 기본 설정|
|<img src = "https://github.com/user-attachments/assets/a9d3e794-62dc-4931-b213-6d0c5d3502d5" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/5c45931b-2d66-493e-86e9-ad141cdd0854" width="350" height="750">|
</details>

<details><summary>검색 화면구성</summary>
    
|내부 검색|외부 검색|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/10048cd4-5dc1-4e8a-9043-c17309b2a28b" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/e9bc69c7-733f-4f72-98a5-b866ed876932" width="350" height="750">|
</details>

<details><summary>설정 화면구성</summary>
    
|문의|회원 탈퇴|
|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/449c7c3f-ed22-4bc6-af69-08b683b4d20e" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/b0f8f63d-79b8-40c0-86e2-75dc5ea67e15" width="350" height="750">|
|색상 설정|글자 크기 설정|
|<img src = "https://github.com/user-attachments/assets/3fcec1ef-1b37-4ef3-b008-5d56cc6388c5" width="350" height="750">|<img src = "https://github.com/user-attachments/assets/ca38303a-a635-4293-b2ce-a5f8475876c0" width="350" height="750">|
</details>

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

### 사용한 라이브러리
```sh
  cupertino_icons: ^1.0.6 : 더 다양한 아이콘 패키지
  firebase_core: ^2.32.0 : 파이어베이스 패키지
  cloud_firestore: ^4.17.5 : 파이어베이스 파이어스토어 데이터베이스 패키지
  firebase_auth: ^4.20.0 : 파이어베이스 인증 패키지
  flutter_spinkit: ^5.2.1 : 로딩GIF 패키지
  intl: ^0.19.0 : DateTime의 형식을 변경하기 위한 패키지
  image_picker: ^1.1.1 : 갤러리에서 이미지 가져오는 패키지
  image_cropper: ^6.0.0 : 이미지 수정 패키지
  firebase_storage: ^11.7.7 : 파이어베이스 스토리지
  animate_do: ^3.3.4 : 다양한 위젯 애니메이션 효과를 위한 패키지
  photo_view: ^0.15.0 : 사진 뷰어 패키지
  buttons_tabbar: ^1.3.10 : 버튼 탭바 패키지
  multi_dropdown: ^3.0.0-dev.2 : 드롭 다운 패키지
  animated_reorderable_list: ^1.0.5 : 애니메이션 리스트 패키지
  dropdown_button2: ^2.3.9 : 드롭 다운 메뉴 버튼 패키지
  auto_size_text: ^3.0.0 : 글자 크기 자동 조절 패키지
  simple_tags: ^0.0.6 : 태그 뷰어 패키지
  flutter_easyloading: ^3.0.5 : 로딩창 패키지
  uuid: ^4.5.0 : 랜덤한 UID를 생성하는 패키지
  search_choices: ^2.2.7 : 검색창 패키지
  shared_preferences: ^2.2.3 : 데이터 저장 패키지
  flex_color_picker: ^3.5.0 : 색상 선택 패키지
  url_launcher: ^6.3.0 : 외부 브라우저 실행 패키지
  package_info_plus: ^8.0.0 : 앱의 정보 제공 패키지
  firebase_remote_config: : 파이어베이스 remote_config 패키지
  rxdart: ^0.28.0 : streamzip등등 다양한 기능의 패키지
  logger: ^2.4.0 : 로그 패키지
  path_provider: ^2.1.4 : 파일 시스템 접근 패키지
  permission_handler: ^11.3.1 : 권한 요청 패키지
```






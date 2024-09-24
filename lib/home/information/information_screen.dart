import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/home/information/questions/questions_screen.dart';
import 'package:chattingapp/home/information/update_information/update_information_screen.dart';
import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../login/login_screen.dart';
import '../../login/registration/authentication.dart';
import '../../utils/copy.dart';
import '../../utils/image/image_widget.dart';
import '../../utils/screen_size.dart';
import 'delete_user_information/delete_user_information_screen.dart';
import 'information_dialog.dart';
import 'information_widget.dart';

// 설정 화면
class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  // 하위 문서에서 setState을 사용하기 위한 함수
  void _refreshSize(double newSize) {
    setState(() {
      chatStringSize = newSize;
    });
  }

  // 하위 문서에서 setState을 사용하기 위한 함수
  void _refreshColor(String type, Color color) {
    setState(() {
      chatRoomColorMap[type] = color;
    });
  }

  // 하위 문서에서 setState을 사용하기 위한 함수
  void _refreshName(String newData) {
    setState(() {
      myData.myNickName = newData;
    });
  }

  // 하위 문서에서 setState을 사용하기 위한 함수
  void _refreshProfile(String newData) {
    setState(() {
      myData.myProfile = newData;
    });
  }

  // 이름 변경 다이얼로그를 실행하는 함수
  void _updateName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateMyNameDialog(onRefresh: _refreshName);
      },
    );
  }

  // 프로필 변경 다이얼로그를 실행하는 함수
  void _updateProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateMyProfileDialog(onRefresh: _refreshProfile);
      },
    );
  }

  // 이메일 인증 다이얼로그를 실행하는 다이얼로그, 인증이 안되어있는 계정일 경우에만 실행
  void _updateAuthEmail() {
    EasyLoading.show();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
      EasyLoading.dismiss();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EmailCheckDialog();
        },
      );
    } else if (user != null && user.emailVerified) {
      snackBarErrorMessage(context, '이미 이메일 인증된 계정입니다.');
    } else {
      snackBarErrorMessage(context, '로그인 정보가 잘못되었습니다. 다시 로그인하고 시도해주세요');
    }
    EasyLoading.dismiss();
  }

  // 비밀번호 변경 다이얼로그 실행 함수
  void _updatePassWord() async {
    User? user = FirebaseAuth.instance.currentUser;
    EasyLoading.show();

    if (user != null) {
      await resetPassword(myData.myEmail);
      EasyLoading.dismiss();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return UpdatePassWordDialog();
        },
      );
    } else {
      snackBarErrorMessage(context, '로그인 정보가 잘못되었습니다. 다시 로그인하고 시도해주세요');
    }
  }

  // 로그아웃 다이얼로그 실행 함수
  void _signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LogOutDialog();
      },
    );
  }

  // 계정 삭제 다이얼로그 실행 함수
  void _deleteUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteUserInformationScreen()),
    );
  }

  // 업데이트 확인 화면 실행 함수
  void _updateInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdateInformationScreen()),
    );
  }

  // 문의사항 화면 실행 함수
  void _quesrionsInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuestionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: screenSize.getHeightPerSize(2),
              ),
              Container(
                height: screenSize.getHeightPerSize(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: screenSize.getHeightPerSize(2),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myData.myNickName,
                            style: TextStyle(fontSize: screenSize.getHeightPerSize(2.5)),
                          ),
                          SizedBox(
                            height: screenSize.getHeightPerSize(0.5),
                          ),
                          GestureDetector(
                            onTap: () {
                              copyToClipboard(context, myData.myEmail, '이메일을');
                            },
                            child: Text(
                              myData.myEmail,
                              style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.getHeightPerSize(0.5),
                          ),
                          GestureDetector(
                            onTap: () {
                              copyToClipboard(context, myData.myUID, '코드를');
                            },
                            child: Text(
                              myData.myUID,
                              style: TextStyle(fontSize: screenSize.getHeightPerSize(1.2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: imageWidget(myData.myProfile),
                    ),
                    SizedBox(
                      width: screenSize.getHeightPerSize(2),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenSize.getHeightPerSize(2),
                color: Colors.white,
                child: const Divider(color: Colors.grey, thickness: 1),
              ),
              Container(
                height: screenSize.getHeightPerSize(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                  // border: Border(
                  //   bottom: BorderSide(color: Colors.grey),
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    informationMyDataSubWidget(
                      screenSize,
                      '전체 친구 수',
                      friendList.length.toString(),
                    ),
                    const VerticalDivider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    informationMyDataSubWidget(
                      screenSize,
                      '참가중인 단체 채팅방',
                      groupChatRoomSequence.length.toString(),
                    ),
                    const VerticalDivider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    informationMyDataSubWidget(
                      screenSize,
                      '아이디 생성일',
                      myData.myDate,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              /* 프로필 관리 */
              informationTitleWidget(screenSize, '프로필 관리'),
              InformationMenuWidget(
                title: '닉네임 변경',
                location: 'top',
                onTap: _updateName,
              ),
              InformationMenuWidget(
                title: '프로필 사진 변경',
                location: 'bottom',
                onTap: _updateProfile,
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              /* 채팅방 설정 */

              informationTitleWidget(screenSize, '채팅방 설정'),
              InformationColorMenuWidget(
                reflashColor: _refreshColor,
                screenSize: screenSize,
                type: 'BackgroundColor',
                title: '배경 색상 설정',
                location: 'top',
              ),
              InformationColorMenuWidget(
                reflashColor: _refreshColor,
                screenSize: screenSize,
                type: 'MyChatColor',
                title: '내 대화 색상 설정',
                location: 'middle',
              ),
              InformationColorMenuWidget(
                reflashColor: _refreshColor,
                screenSize: screenSize,
                type: 'MyChatStringColor',
                title: '내 글자 색상 설정',
                location: 'middle',
              ),
              InformationColorMenuWidget(
                reflashColor: _refreshColor,
                screenSize: screenSize,
                type: 'FriendChatColor',
                title: '상대 대화 색상 설정',
                location: 'middle',
              ),
              InformationColorMenuWidget(
                reflashColor: _refreshColor,
                screenSize: screenSize,
                type: 'FriendChatStringColor',
                title: '상대 글자 색상 설정',
                location: 'middle',
              ),
              InformationSizeMenuWidget(
                reflashSize: _refreshSize,
                screenSize: screenSize,
                title: '글자 크기 설정',
                location: 'bottom',
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              /* 계정 관리 */
              informationTitleWidget(screenSize, '계정 설정'),
              InformationMenuWidget(
                title: '이메일 인증',
                location: 'top',
                onTap: _updateAuthEmail,
              ),
              InformationMenuWidget(
                title: '비밀번호 변경',
                location: 'middle',
                onTap: _updatePassWord,
              ),
              InformationMenuWidget(
                title: '로그아웃',
                location: 'middle',
                onTap: _signOut,
              ),
              InformationMenuWidget(
                title: '회원 탈퇴',
                location: 'bottom',
                onTap: _deleteUser,
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              /* 앱 설정 */
              informationTitleWidget(screenSize, '앱 설정'),
              InformationMenuWidget(title: '업데이트 정보', location: 'top', onTap: _updateInformation),
              InformationMenuWidget(
                  title: '문의 사항', location: 'bottom', onTap: _quesrionsInformation),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              // ElevatedButton(
              //     onPressed: () async {
              //       //bool test = await checkEmailVerificationStatus();
              //       showDialog(
              //         context: context,
              //         builder: (BuildContext context) {
              //           return LogOutDialog();
              //         },
              //       );
              //     },
              //     child: Text('테스트')),
              // ElevatedButton(
              //     onPressed: () {
              //       signOut();
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => const LoginScreen()),
              //       );
              //     },
              //     child: Text('로그아웃')),
            ],
          ),
        ),
      ),
    );
  }
}

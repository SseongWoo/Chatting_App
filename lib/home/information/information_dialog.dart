import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../login/login_screen.dart';
import '../../login/registration/authentication.dart';
import '../../utils/color/color.dart';
import '../../utils/image/image_picker.dart';
import '../../utils/shared_preferences.dart';
import 'information_data.dart';
import 'information_widget.dart';

// 사용자 이름 변경 다이얼로그
class UpdateMyNameDialog extends StatelessWidget {
  final Function(String) onRefresh;

  UpdateMyNameDialog({super.key, required this.onRefresh});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('닉네임 변경'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '변경할 닉네임을 입력해주세요',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_controller.text != myData.myNickName) {
              EasyLoading.show();
              await updateMyName(_controller.text);
              onRefresh(_controller.text);
              EasyLoading.dismiss();
              snackBarMessage(context, '닉네임 변경이 완료되었습니다.');
            } else {
              snackBarErrorMessage(context, '새 닉네임이 현재 사용 중인 닉네임과 동일합니다. 다른 닉네임을 입력해 주세요.');
            }
            Navigator.of(context).pop();
          },
          child: const Text('변경하기'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
      ],
    );
  }
}

// 사용자 프로필 사진 변경 다이얼로그
class UpdateMyProfileDialog extends StatefulWidget {
  final Function(String) onRefresh;

  const UpdateMyProfileDialog({super.key, required this.onRefresh});

  @override
  State<UpdateMyProfileDialog> createState() => _UpdateMyProfileDialogState();
}

class _UpdateMyProfileDialogState extends State<UpdateMyProfileDialog> {
  late String _profile;
  late CroppedFile? _croppedProFile;
  late final Function(String) onRefresh;
  bool _check = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onRefresh = widget.onRefresh;
    _profile = myData.myProfile;
  }

  void _imagePicker(ImageSource imageSource) async {
    XFile? imageFile = await getImage(imageSource);
    if (imageFile != null) {
      _croppedProFile = await cropImage(imageFile);
      setState(() {
        if (_croppedProFile != null) {
          _profile = _croppedProFile!.path;
          _check = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('프로필 사진 변경'),
      content: GestureDetector(
        onTap: () {
          _imagePicker(ImageSource.gallery);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _profile.isNotEmpty
              ? _check
                  ? AspectRatio(
                      aspectRatio: 1, //  1대1비율
                      child: Image.asset(
                        _profile,
                        fit: BoxFit.cover,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 1, //  1대1비율
                      child: Image.network(
                        _profile,
                        fit: BoxFit.cover,
                      ),
                    )
              : Image.asset(
                  'assets/images/blank_profile.png',
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_croppedProFile != null && _croppedProFile?.path != myData.myProfile) {
              EasyLoading.show();
              await uploadMyProfile(_croppedProFile);
              onRefresh(myData.myProfile);
              EasyLoading.dismiss();
              snackBarMessage(context, '프로필 변경이 완료되었습니다.');
            } else {
              snackBarErrorMessage(context, '새 프로필이 현재 사용 중인 프로필과 동일합니다. 다른 프로필을 입력해 주세요.');
            }
            Navigator.of(context).pop();
          },
          child: const Text('변경하기'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
      ],
    );
  }
}

// 채팅방 글자 크기 변경 다이얼로그
class ChatStringSizeDialog extends StatefulWidget {
  final Function(double) reflashSize;
  final ScreenSize screenSize;
  const ChatStringSizeDialog({super.key, required this.screenSize, required this.reflashSize});

  @override
  State<ChatStringSizeDialog> createState() => _ChatStringSizeDialogState();
}

class _ChatStringSizeDialogState extends State<ChatStringSizeDialog> {
  final TextEditingController _controllerSize = TextEditingController();
  late double _chatStringSize;
  late ScreenSize _screenSize;
  late double _oldSize;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _oldSize = chatStringSize;
    _screenSize = widget.screenSize;
    _chatStringSize = chatStringSize * 10;
    _controllerSize.text = _chatStringSize.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('글자 크기 변경')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(child: previewWidget(_screenSize)),
          SizedBox(
            height: _screenSize.getHeightPerSize(1),
          ),
          Row(
            children: [
              SizedBox(
                width: _screenSize.getWidthPerSize(55),
                child: Slider(
                  value: _chatStringSize,
                  max: 25,
                  min: 10,
                  label: _chatStringSize.round().toString(),
                  divisions: 15,
                  onChanged: (value) => setState(() {
                    _chatStringSize = value;
                    setState(() {
                      chatStringSize = _chatStringSize / 10;
                      _controllerSize.text = _chatStringSize.round().toString();
                    });
                  }),
                ),
              ),
              SizedBox(
                width: _screenSize.getWidthPerSize(10),
                height: _screenSize.getHeightPerSize(3),
                child: TextField(
                  controller: _controllerSize,
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // 정수만 입력 가능하도록 설정
                  ],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      int? intValue = int.tryParse(value);
                      if (intValue == null || intValue < 10 || intValue > 25) {
                        _controllerSize.text = '';
                      }
                    }
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  chatStringSize = 1.6;
                  _chatStringSize = chatStringSize * 10;
                  _controllerSize.text = _chatStringSize.round().toString();
                });
              },
              child: const Text('초기화'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                chatStringSize = _oldSize;
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                EasyLoading.show();
                await setSizeSharedPreferencese();
                widget.reflashSize(chatStringSize);
                EasyLoading.dismiss();
                Navigator.of(context).pop();
              },
              child: const Text('변경하기'),
            ),
          ],
        )
      ],
    );
  }
}

// 이메일 인증 다이얼로그
class EmailCheckDialog extends StatefulWidget {
  EmailCheckDialog({super.key});

  @override
  State<EmailCheckDialog> createState() => _EmailCheckDialogState();
}

class _EmailCheckDialogState extends State<EmailCheckDialog> {
  late ScreenSize _screenSize;
  String _message = '인증 메일이 성공적으로 전송되었습니다.\n아래 이메일 주소로 전송된 링크를 클릭하여 인증을 완료해 주세요.';
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return AlertDialog(
      title: const Text('이메일 인증'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_message\n',
            style: TextStyle(fontSize: _screenSize.getHeightPerSize(1.7)),
          ),
          Text(
            '\n${myData.myEmail}',
            style: TextStyle(fontSize: _screenSize.getHeightPerSize(2)),
          )
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                if (_user != null) {
                  _user?.sendEmailVerification();
                  setState(() {
                    _message = '인증 메일이 다시 전송되었습니다.\n아래 이메일 주소로 전송된 링크를 클릭하여 인증을 완료해 주세요.';
                  });
                } else {
                  setState(() {
                    _message = '로그인 정보에 오류가 발생하였습니다.\n다시 로그인하여 시도해 주세요.';
                  });
                }
              },
              child: const Text('인증 메일 재전송'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                EasyLoading.show();
                bool check = await checkEmailVerificationStatus();
                if (check) {
                  snackBarMessage(context, '인증이 완료되었습니다.');
                  EasyLoading.dismiss();
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    _message = '인증에 실패하였습니다. 다시 시도해주세요';
                  });
                  EasyLoading.dismiss();
                }
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ],
    );
  }
}

// 비밀번호 변경 다이얼로그
class UpdatePassWordDialog extends StatefulWidget {
  UpdatePassWordDialog({super.key});

  @override
  State<UpdatePassWordDialog> createState() => _UpdatePassWordDialogState();
}

class _UpdatePassWordDialogState extends State<UpdatePassWordDialog> {
  late ScreenSize _screenSize;
  String _message = '비밀번호 변경 메일이 아래의 이메일로 전송이 되었습니다.\n해당 메일에서 비밀번호 변경을 완료해주세요';
  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return AlertDialog(
      title: const Text('비밀번호 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _message,
            style: TextStyle(fontSize: _screenSize.getHeightPerSize(1.7)),
          ),
          Text(
            '\n${myData.myEmail}',
            style: TextStyle(fontSize: _screenSize.getHeightPerSize(2)),
          )
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                EasyLoading.show();
                await resetPassword(myData.myEmail);
                setState(() {
                  _message = '메일이 재전송이 되었습니다.\n해당 메일에서 비밀번호 변경을 완료해주세요';
                });
                EasyLoading.dismiss();
              },
              child: const Text('메일 재전송'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        )
      ],
    );
  }
}

// 로그아웃 다이얼로그
class LogOutDialog extends StatelessWidget {
  const LogOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('로그아웃'),
      content: const Text('정말로 로그아웃 하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}

// 업데이트 확인 다이얼로그
AlertDialog updateInformationDialog(BuildContext context) {
  String message = '';

  return AlertDialog(
    title: const Text('업데이트 정보'),
    content: Text(message),
    actions: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainLightColor),
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.black),
              )),
        ],
      )
    ],
  );
}

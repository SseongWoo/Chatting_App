import 'package:auto_size_text/auto_size_text.dart';
import 'package:chattingapp/home/chat/chat_room/search_chat/search_room_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../utils/color/color.dart';
import '../../../../utils/screen_size.dart';
import '../../../friend/friend_data.dart';
import '../../../friend/request/request_data.dart';

// 검색해서 찾은 인원을 친구 추가 할때 나타나는 다이얼로그
class UserRequestDialog extends StatelessWidget {
  final UserData userData;
  const UserRequestDialog({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("친구 추가"),
      content: Text('"${userData.nickName}"에게\n친구 추가 요청을 보내시겠습니까?'),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () async {
              EasyLoading.show();
              await sendRequest(userData.uid, context); // 친구 요청을 보내는 함수
              EasyLoading.dismiss();
              Navigator.of(context).pop();
            },
            child: const Text("요청 보내기")),
      ],
    );
  }
}

// 새로운 채팅방에 들어가려고 할때 나타나는 커스텀 다이얼로그
class JoinGlobalChatRoom extends StatefulWidget {
  final ChatRoomPublicData chatRoomPublicData;
  const JoinGlobalChatRoom({super.key, required this.chatRoomPublicData});

  @override
  State<JoinGlobalChatRoom> createState() => _JoinGlobalChatRoomState();
}

class _JoinGlobalChatRoomState extends State<JoinGlobalChatRoom> {
  late ChatRoomPublicData _chatRoomPublicData;
  final String imagePath = 'assets/images/blank_profile.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomPublicData = widget.chatRoomPublicData;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Dialog(
      child: Container(
        height: screenSize.getHeightPerSize(60),
        width: screenSize.getWidthPerSize(80),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
            ),
            SizedBox(
              height: screenSize.getWidthPerSize(60),
              width: screenSize.getWidthPerSize(60),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _chatRoomPublicData.chatRoomProfile.isNotEmpty
                    ? Image.network(
                        _chatRoomPublicData.chatRoomProfile,
                        // 이미지를 서버에서 받는동안 로딩되는 기능
                        loadingBuilder:
                            (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const Center(
                            child: Text('이미지 로딩 실패'),
                          );
                        },
                      )
                    // 이미지가 없을 시 기본 이미지를 화면에 출력
                    : Image.asset(
                        imagePath,
                      ),
              ),
            ),
            SizedBox(
              height: screenSize.getWidthPerSize(2),
            ),
            SizedBox(
              height: screenSize.getWidthPerSize(10),
              width: screenSize.getWidthPerSize(70),
              child: Align(
                alignment: Alignment.centerLeft,
                // 채팅방 제목 뒤에 채팅방 참여 인원수 까지 출력
                child: Text(
                  '${_chatRoomPublicData.chatRoomName}(${_chatRoomPublicData.people})',
                  style: TextStyle(color: Colors.black, fontSize: screenSize.getHeightPerSize(3)),
                ),
              ),
            ),
            Expanded(
                child: SizedBox(
              width: screenSize.getWidthPerSize(70),
              child: Align(
                alignment: Alignment.topLeft,
                // 설명이 길어서 화면을 벗어날 경우를 방지하기 위해 AutoSizeText 사용
                child: AutoSizeText(
                  _chatRoomPublicData.chatRoomExplain.isNotEmpty
                      ? _chatRoomPublicData.chatRoomExplain
                      : '설명 없음',
                  style: TextStyle(color: Colors.black, fontSize: screenSize.getHeightPerSize(1.8)),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
            Row(
              children: [
                // 취소버튼, 왼쪽 모서라만 둥글게
                SizedBox(
                  height: screenSize.getHeightPerSize(6),
                  width: screenSize.getWidthPerSize(25),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                // 확인버튼, 오른쪽 모서리만 둥글게
                SizedBox(
                  height: screenSize.getHeightPerSize(6),
                  width: screenSize.getWidthPerSize(55),
                  child: ElevatedButton(
                      onPressed: () async {
                        EasyLoading.show();
                        // 비밀번호가 없을 시 그냥 입장, 있을 시 현재 다이얼로그 종료 후 EnterPasswordDialog 다이얼로그 생성
                        if (_chatRoomPublicData.password) {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EnterPasswordDialog(
                                chatRoomPublicData: _chatRoomPublicData,
                              );
                            },
                          );
                        } else {
                          await moveChatRoom(context, _chatRoomPublicData);
                        }
                        EasyLoading.dismiss();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        '입장하기',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// JoinGlobalChatRoom 다이얼로그에서 채팅방에 입장할 떄 암호가 있을경우 생성되는 다이얼로그
class EnterPasswordDialog extends StatefulWidget {
  final ChatRoomPublicData chatRoomPublicData;
  const EnterPasswordDialog({super.key, required this.chatRoomPublicData});

  @override
  State<EnterPasswordDialog> createState() => _EnterPasswordDialogState();
}

class _EnterPasswordDialogState extends State<EnterPasswordDialog> {
  final TextEditingController _controller = TextEditingController();
  final _enterPasswordDialogFormKey = GlobalKey<FormState>();
  late ChatRoomPublicData _chatRoomPublicData;
  bool _passwordCheck = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomPublicData = widget.chatRoomPublicData;
  }

  // 서버에서 암호 데이터를 가져와 사용자가 입력한 데이터와 같을경우 _passwordCheck변수를 true로 변경
  Future<void> _checkPassword() async {
    String password = await getPassword(_chatRoomPublicData, context);
    if (_controller.text == password) {
      _passwordCheck = true;
    } else {
      _passwordCheck = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Dialog(
      child: Container(
        height: screenSize.getHeightPerSize(30),
        width: screenSize.getWidthPerSize(80),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
            ),
            SizedBox(
              width: screenSize.getWidthPerSize(70),
              child: Text(
                '비밀번호 입력',
                style: TextStyle(
                  fontSize: screenSize.getHeightPerSize(2),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: screenSize.getHeightPerSize(1),
            ),
            SizedBox(
              width: screenSize.getWidthPerSize(70),
              child: Text(
                '"${_chatRoomPublicData.chatRoomName}"방의 비밀번호를 입력해 주세요',
                style: TextStyle(
                  fontSize: screenSize.getHeightPerSize(1.5),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: SizedBox(
                width: screenSize.getWidthPerSize(70),
                child: Center(
                  child: Form(
                    key: _enterPasswordDialogFormKey,
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '비밀번호를 입력해 주세요',
                      ),
                      obscureText: true,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      validator: (String? value) {
                        // 텍스트 필드가 비어있어나 입력한 암호가 다를시 에러메세지 출력
                        if (value?.isEmpty ?? true) return '비밀번호를 입력해 주세요';
                        if (!_passwordCheck) return '입력하신 비밀번호가 올바르지 않습니다. 다시 한 번 확인해 주세요.';
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  height: screenSize.getHeightPerSize(6),
                  width: screenSize.getWidthPerSize(25),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(6),
                  width: screenSize.getWidthPerSize(55),
                  child: ElevatedButton(
                      onPressed: () async {
                        EasyLoading.show();
                        // 텍스트필드에 입력된 값이 채팅방 암호와 일치할경우 moveChatRoom 함수 실행
                        await _checkPassword();
                        if (_enterPasswordDialogFormKey.currentState!.validate()) {
                          await moveChatRoom(context, _chatRoomPublicData);
                        }
                        EasyLoading.dismiss();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        '입장하기',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

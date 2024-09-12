import 'package:auto_size_text/auto_size_text.dart';
import 'package:chattingapp/home/chat/chat_list_data.dart';
import 'package:chattingapp/home/chat/chat_room/search_chat/search_room_data.dart';
import 'package:chattingapp/home/chat/chat_room/search_chat/search_room_dialog.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/data_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../utils/get_people_data.dart';
import '../../../../utils/image_viewer.dart';
import '../../../../utils/screen_size.dart';
import '../../create_chat/creat_chat_data.dart';
import '../chat_room_data.dart';
import '../chat_room_screen.dart';

// search_room_screen의 _chatRoomSequence, _userDataSequence 리스트 뷰에 사용되는 위젯
class UserWidget extends StatefulWidget {
  final UserData userData;
  const UserWidget({
    super.key,
    required this.userData,
  });

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  late ScreenSize _screenSize;
  late UserData userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return GestureDetector(
      onTap: () {
        // 해당 위젯의 유저를 친구 추가 하기 위한 작업
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UserRequestDialog(
              userData: userData,
            );
          },
        );
      },
      child: Container(
        height: _screenSize.getHeightPerSize(8),
        width: _screenSize.getWidthSize(),
        color: Colors.white,
        child: Column(children: [
          SizedBox(
            height: _screenSize.getHeightPerSize(8),
            child: Row(
              children: [
                SizedBox(
                  width: _screenSize.getWidthPerSize(2),
                ),
                GestureDetector(
                  // 이미지 클릭시 이미지 뷰어로 이동
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageViewer(imageURL: userData.profile)),
                    );
                  },
                  child: SizedBox(
                    height: _screenSize.getHeightPerSize(6),
                    width: _screenSize.getHeightPerSize(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        userData.profile,
                        // 이미지 로딩
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
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _screenSize.getWidthPerSize(2),
                ),
                SizedBox(
                  height: _screenSize.getHeightPerSize(6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData.nickName,
                          style: TextStyle(
                            fontSize: _screenSize.getHeightPerSize(2),
                          ),
                        ),
                        Text(
                          userData.email,
                          style: TextStyle(
                            fontSize: _screenSize.getHeightPerSize(1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// 외부데이터 중 공개된 채팅방리스트에 사용되는 위젯
class GlobalChatListWidget extends StatefulWidget {
  final ChatRoomPublicData chatRoomPublicData;

  const GlobalChatListWidget({
    super.key,
    required this.chatRoomPublicData,
  });

  @override
  State<GlobalChatListWidget> createState() => _GlobalChatListWidgetState();
}

class _GlobalChatListWidgetState extends State<GlobalChatListWidget> {
  late ScreenSize _screenSize;
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
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        // 해당 채팅방이 사용자가 이미 들어가 있는 채팅방인지 확인 후 맞을경우 채팅방 입장,
        // 아닐경우 JoinGlobalChatRoom 다이얼로그 생성하여 입장과정을 거침
        if (chatRoomList.containsKey(_chatRoomPublicData.chatRoomUid)) {
          await getChatData(_chatRoomPublicData.chatRoomUid);
          List<ChatPeopleClass> chatPeople = await getPeopleData(_chatRoomPublicData.chatRoomUid);
          await refreshData();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chatRoomSimpleData: chatRoomList[_chatRoomPublicData.chatRoomUid]!,
                chatPeopleList: chatPeople,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return JoinGlobalChatRoom(
                chatRoomPublicData: _chatRoomPublicData,
              );
            },
          );
        }

        EasyLoading.dismiss();
      },
      child: Container(
        height: _screenSize.getHeightPerSize(7),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            SizedBox(
              width: _screenSize.getWidthPerSize(4),
            ),
            SizedBox(
              height: _screenSize.getHeightPerSize(6),
              width: _screenSize.getHeightPerSize(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _chatRoomPublicData.chatRoomProfile.isNotEmpty
                    ? Image.network(
                        _chatRoomPublicData.chatRoomProfile,
                        // 이미지 로딩
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
                    : Image.asset(
                        imagePath,
                      ),
              ),
            ),
            SizedBox(
              width: _screenSize.getWidthPerSize(2),
            ),
            Expanded(
              child: AutoSizeText(
                _chatRoomPublicData.chatRoomName,
                maxLines: 1,
                style: TextStyle(color: Colors.black, fontSize: _screenSize.getHeightPerSize(1.7)),
              ),
            ),
            SizedBox(
              width: _screenSize.getWidthPerSize(2),
            ),
          ],
        ),
      ),
    );
  }
}

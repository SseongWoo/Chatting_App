import 'package:chattingapp/home/chat/chat_room/chat_room_screen.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:search_choices/search_choices.dart';
import '../../../../utils/get_people_data.dart';
import '../../../../utils/my_data.dart';
import '../../../friend/friend_data.dart';
import '../../chat_list_data.dart';
import '../../create_chat/creat_chat_data.dart';
import '../chat_room_data.dart';
import 'add_person_data.dart';

// 채팅방 인원 초대 화면
class AddPersonScreen extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;
  final List<ChatPeopleClass> chatPeopleList;

  const AddPersonScreen(
      {super.key, required this.chatRoomSimpleData, required this.chatPeopleList});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  List<int> _selectValueList = []; // 선택한 인원 리스트
  final List<String> _itemList = []; // 내 친구 리스트
  late ChatRoomSimpleData _chatRoomSimpleData; // 채팅방 데이터
  final List<String> _chatPeopleList = []; // 채팅방에 속해있는 인원 리스트
  final List<String> _newPeopleList = []; // 새롭게 들어오는 인원 리스트

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomSimpleData = widget.chatRoomSimpleData;
    _chatPeopleList.clear();
    _itemList.clear();

    // chatPeopleList클래스의 uid를 _chatPeopleList에 넣는 작업
    for (var item in widget.chatPeopleList) {
      _chatPeopleList.add(item.uid);
    }

    // 내 친구데이터에 있는 친구중 채팅방에 없는 인원들만 _itemList리스트에 넣는 작업
    for (var item in friendListUidKey.entries) {
      if (!_chatPeopleList.contains(item.key)) {
        _itemList.add(item.value);
      }
    }
  }

  // 채팅방에 추가할 인원을 파이어베이스에 넣는 작업을 시작하는 함수
  void startAddPerson() async {
    DateTime dateTime = DateTime.now();
    _newPeopleList.clear();
    EasyLoading.show();

    String message = '${myData.myNickName}님이'; // 채팅방 시스템 메세지 내용

    // 채팅방 시스템 메세지 내용에 초대한 인원수만큼 반복해서 메세지에 추가한 인원들의 이름을 넣는 작업
    for (int i = 0; i < _selectValueList.length; i++) {
      if (i == _selectValueList.length - 1) {
        message = '$message ${_itemList[_selectValueList[i]]}님을 초대하였습니다.';
      } else {
        message = '$message ${_itemList[_selectValueList[i]]}님,';
      }
      String uid = friendList[_itemList[_selectValueList[i]]]!.friendUID;
      _chatPeopleList.add(uid);
      _newPeopleList.add(uid);
    }

    // 파이어베이스에 데이터를 등록하는 작업
    await addNewPeople(_chatRoomSimpleData.chatRoomUid, _chatPeopleList, _newPeopleList, context);
    // 시스템 메세지를 채팅방에 생성하는 작업
    await setChatData(_chatRoomSimpleData.chatRoomUid, message, 'system', dateTime, context);
    // 시스템 메세지를 채팅방 마지막 메세지 데이터로 업데이트하는 작업
    await setChatRealTimeData(
        _chatPeopleList, _chatRoomSimpleData.chatRoomUid, message, dateTime, context);

    // 업데이트된 채팅방 인원을 다시 가져와서 내부 데이터를 업데이트 하는 작업
    List<ChatPeopleClass> chatPeople = await getPeopleData(_chatRoomSimpleData.chatRoomUid);

    EasyLoading.dismiss();

    // 모든 직업이 완료되면 다시 채팅방으로 되돌아감
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
                chatRoomSimpleData: _chatRoomSimpleData, chatPeopleList: chatPeople)),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 추가'),
        actions: [
          TextButton(
              onPressed: () {
                // 초대할 인원을 선택 안했을시, 또는 초대할 인원 + 기존 인원의 수가 100명이 넘을경우 기능이 실행되지 않기 위한 작업
                if (_selectValueList.isNotEmpty &&
                    (_chatPeopleList.length + _selectValueList.length) <= 100) {
                  startAddPerson();
                } else if ((_chatPeopleList.length + _selectValueList.length) > 100) {
                  snackBarErrorMessage(context,
                      '채팅방의 최대 인원 제한(100명)을 초과하여 더 이상 초대할 수 없습니다. 기존 인원을 조정하거나 새로운 채팅방을 생성해 주세요.');
                } else {
                  snackBarErrorMessage(context, '초대할 인원을 선택해 주세요.');
                }
              },
              child: Text(
                '확인',
                style: TextStyle(fontSize: screenSize.getHeightPerSize(2), color: Colors.black),
              ))
        ],
      ),
      body: Column(
        children: [
          //search_choices 라이브러리를 사용한 검색창 다이얼로그, 검색 아이템 드롭다운메뉴 기능을 구현
          SearchChoices.multiple(
            // 내 친구중 채팅방에 속하지 않은 친구들의 목록을 아이템 데이터로 저장
            items: _itemList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            // 사용자가 선택한 아이템 리스트
            selectedItems: _selectValueList,

            hint: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('초대할 친구들을 선택해주세요'),
            ),
            searchHint: '초대할 친구들을 선택해주세요',

            // 사용자가 아이템을 선택하거나 취소했을때 _selectValueList 리스트를 업데이트
            onChanged: (value) {
              setState(() {
                _selectValueList = value;
              });
            },

            // 저장 버튼
            closeButton: (selectedItems) {
              return (selectedItems.isNotEmpty
                  ? "${selectedItems.length == 1 ? '"${_itemList[selectedItems.first]}"' : '${selectedItems.length}명'} 저장"
                  : "선택하지 않고 저장");
            },
            isExpanded: true,
          ),

          // 선택한 아이템들을 리스트뷰로 사용자의 화면에 보이게 함
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _selectValueList.length,
              itemBuilder: (context, index) {
                FriendData? friendData = friendList[_itemList[_selectValueList[index]]];
                return Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(friendData!.friendNickName),
                        leading: friendData.friendProfile.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                friendData.friendProfile,
                              ))
                            : const Icon(Icons.person),
                      ),
                    ),
                    SizedBox(
                        width: screenSize.getWidthPerSize(15),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectValueList.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.close))),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

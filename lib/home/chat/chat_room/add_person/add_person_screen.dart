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

class AddPersonScreen extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;
  final List<ChatPeopleClass> chatPeopleList;

  const AddPersonScreen(
      {super.key, required this.chatRoomSimpleData, required this.chatPeopleList});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  List<int> _selectValueList = [];
  final List<String> _itemList = [];
  late ScreenSize _screenSize;
  late ChatRoomSimpleData _chatRoomSimpleData;
  final List<String> _chatPeopleList = [];
  List<String> _newPeopleList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatRoomSimpleData = widget.chatRoomSimpleData;
    _chatPeopleList.clear();
    _itemList.clear();

    for (var item in widget.chatPeopleList) {
      _chatPeopleList.add(item.uid);
    }

    for (var item in friendListUidKey.entries) {
      if (!_chatPeopleList.contains(item.key)) {
        _itemList.add(item.value);
      }
    }
  }

  void startAddPerson() async {
    _newPeopleList.clear();
    EasyLoading.show();

    String message = '${myData.myNickName}님이';

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

    await addNewPeople(_chatRoomSimpleData.chatRoomUid, _chatPeopleList, _newPeopleList);
    await setChatData(_chatRoomSimpleData.chatRoomUid, message, "system");

    List<ChatPeopleClass> chatPeople = await getPeopleData(_chatRoomSimpleData.chatRoomUid);

    EasyLoading.dismiss();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
                chatRoomSimpleData: _chatRoomSimpleData, chatPeopleList: chatPeople)),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 추가'),
        actions: [
          TextButton(
              onPressed: () {
                if (_selectValueList.isNotEmpty) {
                  startAddPerson();
                } else {
                  snackBarErrorMessage(context, '초대할 인원을 선택해 주세요.');
                }
              },
              child: Text(
                '확인',
                style: TextStyle(fontSize: _screenSize.getHeightPerSize(2), color: Colors.black),
              ))
        ],
      ),
      body: Column(
        children: [
          SearchChoices.multiple(
            items: _itemList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            selectedItems: _selectValueList,
            hint: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('초대할 친구들을 선택해주세요'),
            ),
            searchHint: '초대할 친구들을 선택해주세요',
            onChanged: (value) {
              setState(() {
                _selectValueList = value;
              });
            },
            closeButton: (selectedItems) {
              return (selectedItems.isNotEmpty
                  ? "${selectedItems.length == 1 ? '"${_itemList[selectedItems.first]}"' : '${selectedItems.length}명'} 저장"
                  : "선택하지 않고 저장");
            },
            isExpanded: true,
          ),
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
                            : Icon(Icons.person),
                      ),
                    ),
                    SizedBox(
                        width: _screenSize.getWidthPerSize(15),
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

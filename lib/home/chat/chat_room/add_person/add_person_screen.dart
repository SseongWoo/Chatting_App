import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import '../../../friend/friend_data.dart';
import '../../chat_data.dart';
import '../../create_chat/creat_chat_data.dart';

class AddPersonScreen extends StatefulWidget {
  final ChatRoomSimpleData chatRoomSimpleData;
  final List<ChatPeopleClass> chatPeopleList;

  const AddPersonScreen(
      {super.key, required this.chatRoomSimpleData, required this.chatPeopleList});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  List<int> selectValueList = [];
  late ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 추가'),
        actions: [
          TextButton(
              onPressed: () {},
              child: Text(
                '확인',
                style: TextStyle(fontSize: screenSize.getHeightPerSize(2), color: Colors.black),
              ))
        ],
      ),
      body: Column(
        children: [
          SearchChoices.multiple(
            items: friendListSequence.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            selectedItems: selectValueList,
            hint: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('초대할 친구들을 선택해주세요'),
            ),
            searchHint: '초대할 친구들을 선택해주세요',
            onChanged: (value) {
              setState(() {
                selectValueList = value;
              });
            },
            closeButton: (selectedItems) {
              return (selectedItems.isNotEmpty
                  ? "${selectedItems.length == 1 ? '"${friendListSequence[selectedItems.first]}"' : '${selectedItems.length}명'} 저장"
                  : "선택하지 않고 저장");
            },
            isExpanded: true,
          ),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: selectValueList.length,
              itemBuilder: (context, index) {
                FriendData? friendData = friendList[friendListSequence[selectValueList[index]]];
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
                        width: screenSize.getWidthPerSize(15),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                selectValueList.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.close))),
                  ],
                );
                //
                // return SizedBox(
                //   height: screenSize.getHeightPerSize(6),
                //   child: ListTile(
                //     leading: proFile.isNotEmpty
                //         ? CircleAvatar(
                //         backgroundImage: NetworkImage(
                //           proFile,
                //         ))
                //         : Icon(Icons.person),
                //     title: Text(name ?? '에러'),
                //     onTap: () {
                //     },
                //   ),
                // );
              },
            ),
          )
        ],
      ),
    );
  }
}

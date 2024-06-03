import 'package:auto_size_text/auto_size_text.dart';
import 'package:chattingapp/home/friend/friend_data.dart';
import 'package:chattingapp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:simple_tags/simple_tags.dart';
import '../../../utils/copy.dart';
import '../../../utils/image_viewer.dart';
import '../../../utils/screen_size.dart';

class DetailInformationScreen extends StatefulWidget {
  final FriendData friendData;

  const DetailInformationScreen({super.key, required this.friendData});

  @override
  State<DetailInformationScreen> createState() =>
      _DetailInformationScreenState();
}

class _DetailInformationScreenState extends State<DetailInformationScreen> {
  late ScreenSize screenSize;
  late FriendData friendData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friendData = widget.friendData;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: screenSize.getHeightPerSize(25),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => ImageViewer(
                        imageURL: friendData.friendProfile)));
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(screenSize.getHeightPerSize(2)),
                    child: Image.network(
                      friendData.friendProfile,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(5),
                child: Center(
                    child: AutoSizeText(
                      friendData.friendCustomName == ""
                          ? friendData.friendNickName
                          : "${friendData.friendCustomName}(${friendData.friendNickName})",
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(3)),
                      maxLines: 1, // 한 줄을 넘지 않도록 설정
                      minFontSize: 8, // 최소 글자 크기
                      overflow: TextOverflow.ellipsis, // 텍스트가 넘칠 때 '...'로 표시
                    ),
                ),
              ),
              SizedBox(
                  height: screenSize.getHeightPerSize(4),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenSize.getWidthPerSize(8),
                        ),
                        Text(
                          friendData.friendEmail,
                          style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                        ),
                        SizedBox(
                          width: screenSize.getWidthPerSize(8),
                          child: IconButton(onPressed: () {
                            copyToClipboard(context, friendData.friendEmail, "이메일을");
                          }, icon: Icon(Icons.copy, size: screenSize.getHeightPerSize(2),)),
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                  height: screenSize.getHeightPerSize(4),
                  child: Center(
                    child: Text(
                      "카테고리",
                      style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                    ),
                  )),
              Container(
                height: 1,
                width: screenSize.getWidthPerSize(80),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                ),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(80),
                child: Center(
                  child: SimpleTags(
                    content: friendData.category,
                    wrapSpacing: 4,
                    wrapRunSpacing: 4,
                    tagContainerPadding: const EdgeInsets.all(6),
                    tagTextStyle: TextStyle(color: mainBoldColor),
                    tagContainerDecoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(139, 139, 142, 0.16),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(1.75, 3.5), // c
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 1,
                width: screenSize.getWidthPerSize(80),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              ElevatedButton(onPressed: () {
                copyToClipboard(context, friendData.friendUID, "친구 코드를");
              }, child: const Text("친구 코드 복사하기",style: TextStyle(color: Colors.black),))
            ],
          ),
        ),
      ),
    );
  }
}

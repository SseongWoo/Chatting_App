import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({super.key});

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  late ScreenSize screenSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Container(
      height: screenSize.getHeightPerSize(7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenSize.getWidthPerSize(4),
          ),
          SizedBox(
            height: screenSize.getHeightPerSize(6),
            width: screenSize.getHeightPerSize(6),
            child: Center(
              child: Text("이미지"),
            ),
          ),
          SizedBox(
            width: screenSize.getWidthPerSize(2),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: screenSize.getHeightPerSize(3.5),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "채팅창 제목",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: screenSize.getHeightPerSize(1.7)),
                      )),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(0.5),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(2.8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "채팅방",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenSize.getHeightPerSize(1.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: screenSize.getWidthPerSize(2),
          ),
          SizedBox(
            height: screenSize.getHeightPerSize(5),
            width: screenSize.getWidthPerSize(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "8월 2일\n오전 11:08",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenSize.getHeightPerSize(1.5)),
              ),
            ),
          ),
          SizedBox(
            width: screenSize.getWidthPerSize(2),
          ),
        ],
      ),
    );
  }
}

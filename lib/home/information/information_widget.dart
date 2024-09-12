import 'package:chattingapp/utils/screen_size.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import '../../utils/color.dart';
import '../../utils/color_picker.dart';
import '../../utils/shared_preferences.dart';
import 'information_dialog.dart';

// 설정 위젯중 사용자의 정보를 표시해주는 위젯
Widget informationMyDataSubWidget(ScreenSize screenSize, String title, String content) {
  return SizedBox(
    width: screenSize.getWidthPerSize(30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        SizedBox(
          height: screenSize.getHeightPerSize(0.5),
        ),
        Text(
          content,
          style: TextStyle(fontSize: screenSize.getHeightPerSize(2), color: mainColor),
        ),
      ],
    ),
  );
}

// 설정 제목 위젯
Widget informationTitleWidget(ScreenSize screenSize, String title) {
  return Container(
    margin: EdgeInsets.fromLTRB(screenSize.getHeightPerSize(3), screenSize.getHeightPerSize(0.5),
        screenSize.getHeightPerSize(3), screenSize.getHeightPerSize(0.5)),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(title),
    ),
  );
}

// 설정 메뉴 위젯
class InformationMenuWidget extends StatefulWidget {
  final String title;
  final String location;
  final VoidCallback onTap;
  const InformationMenuWidget(
      {super.key, required this.title, required this.location, required this.onTap});

  @override
  State<InformationMenuWidget> createState() => _InformationMenuWidgetState();
}

class _InformationMenuWidgetState extends State<InformationMenuWidget> {
  late ScreenSize _screenSize;
  late String _title;
  late String _location;
  late VoidCallback _onTap;
  RoundedRectangleBorder? _shape;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _title = widget.title;
    _location = widget.location;
    _onTap = widget.onTap;

    if (_location == 'top') {
      _shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.0),
          topLeft: Radius.circular(15.0),
        ),
      );
    } else if (_location == 'bottom') {
      _shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        ),
      );
    } else {
      _shape = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = ScreenSize(MediaQuery.of(context).size);
    return Container(
      margin: EdgeInsets.fromLTRB(
          _screenSize.getHeightPerSize(2), 0, _screenSize.getHeightPerSize(2), 0),
      child: ListTile(
        onTap: _onTap,
        tileColor: Colors.white,
        title: Text(_title),
        shape: _shape,
      ),
    );
  }
}

// 설정 메뉴 위젯의 오른쪽에 색 표현을 나타낸 위젯
class InformationColorMenuWidget extends StatefulWidget {
  final Function(String, Color) reflashColor;
  final ScreenSize screenSize;
  final String title;
  final String type;
  final String location;

  const InformationColorMenuWidget({
    super.key,
    required this.reflashColor,
    required this.screenSize,
    required this.title,
    required this.type,
    required this.location,
  });

  @override
  _InformationColorMenuWidgetState createState() => _InformationColorMenuWidgetState();
}

class _InformationColorMenuWidgetState extends State<InformationColorMenuWidget> {
  RoundedRectangleBorder? getShape() {
    if (widget.location == 'top') {
      return const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.0),
          topLeft: Radius.circular(15.0),
        ),
      );
    } else if (widget.location == 'bottom') {
      return const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        widget.screenSize.getHeightPerSize(2),
        0,
        widget.screenSize.getHeightPerSize(2),
        0,
      ),
      child: ListTile(
        tileColor: Colors.white,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulColorPickerDialog(
                type: widget.type,
                screenSize: widget.screenSize,
                reflashColor: widget.reflashColor,
              );
            },
          );
        },
        title: Text(widget.title),
        trailing: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ColorIndicator(
              borderColor: Colors.black,
              width: widget.screenSize.getHeightPerSize(4),
              height: widget.screenSize.getHeightPerSize(4),
              borderRadius: 4,
              color: chatRoomColorMap[widget.type]!,
              onSelectFocus: false,
            )),
        shape: getShape(),
      ),
    );
  }
}

// 설정 메뉴 위젯의 오른쪽에 글자 크기를 나타낸 위젯
class InformationSizeMenuWidget extends StatefulWidget {
  final Function(double) reflashSize;
  final ScreenSize screenSize;
  final String title;
  final String location;

  const InformationSizeMenuWidget({
    super.key,
    required this.reflashSize,
    required this.screenSize,
    required this.title,
    required this.location,
  });

  @override
  _InformationSizeMenuWidget createState() => _InformationSizeMenuWidget();
}

class _InformationSizeMenuWidget extends State<InformationSizeMenuWidget> {
  RoundedRectangleBorder? getShape() {
    if (widget.location == 'top') {
      return const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.0),
          topLeft: Radius.circular(15.0),
        ),
      );
    } else if (widget.location == 'bottom') {
      return const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        widget.screenSize.getHeightPerSize(2),
        0,
        widget.screenSize.getHeightPerSize(2),
        0,
      ),
      child: ListTile(
        tileColor: Colors.white,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ChatStringSizeDialog(
                reflashSize: widget.reflashSize,
                screenSize: widget.screenSize,
              );
            },
          );
        },
        title: Text(widget.title),
        trailing: Text(
          (chatStringSize * 10).round().toString(),
          style: TextStyle(fontSize: widget.screenSize.getHeightPerSize(2)),
        ),
        shape: getShape(),
      ),
    );
  }
}

// 채팅방 색, 글자 크기 설정 다이얼로그에서 미리보기 화면으로 채팅방을 보여주기 위한 위젯
Container previewWidget(ScreenSize screenSize) {
  return Container(
    width: screenSize.getWidthPerSize(60),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: chatRoomColorMap['BackgroundColor'],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                    0, 0, screenSize.getWidthPerSize(1), screenSize.getWidthPerSize(1)),
                child: Text(
                  '오전 00시 00분',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenSize.getWidthPerSize(70), // 최대 너비
                  maxHeight: screenSize.getHeightPerSize(40), // 최대 높이
                ),
                child: Container(
                  padding: EdgeInsets.all(screenSize.getWidthPerSize(2)),
                  decoration: BoxDecoration(
                      color: chatRoomColorMap['MyChatColor'],
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    '안녕하세요',
                    style: TextStyle(
                        fontSize: screenSize.getHeightPerSize(chatStringSize),
                        color: chatRoomColorMap['MyChatStringColor']),
                    maxLines: null, // 줄바꿈을 허용
                    overflow: TextOverflow.visible, // 텍스트가 넘어갈 경우 줄바꿈
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(screenSize.getWidthPerSize(1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenSize.getWidthPerSize(10),
                width: screenSize.getWidthPerSize(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/blank_profile.png',
                  ),
                ),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(1.5),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사용자',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: screenSize.getWidthPerSize(40), // 최대 너비
                          maxHeight: screenSize.getHeightPerSize(20), // 최대 높이
                        ),
                        child: Container(
                          padding: EdgeInsets.all(screenSize.getWidthPerSize(2)),
                          decoration: BoxDecoration(
                              color: chatRoomColorMap['FriendChatColor'],
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '안녕하세요',
                            style: TextStyle(
                                fontSize: screenSize.getHeightPerSize(chatStringSize),
                                color: chatRoomColorMap['FriendChatStringColor']),
                            maxLines: null, // 줄바꿈을 허용
                            overflow: TextOverflow.visible, // 텍스트가 넘어갈 경우 줄바꿈
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            screenSize.getWidthPerSize(1), 0, 0, screenSize.getWidthPerSize(1)),
                        child: Text(
                          '오전 00시 00분',
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(1), color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

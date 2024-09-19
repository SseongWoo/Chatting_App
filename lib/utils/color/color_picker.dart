import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../home/information/information_widget.dart';
import 'color.dart';

// 채팅방의 여러 오브젝트의 색을 사용자가 원하는 색으로 선택할수 있게 도와주는 색 선택 다이얼로그

const Color guidePrimary = Color(0xFF6200EE);
const Color guidePrimaryVariant = Color(0xFF3700B3);
const Color guideSecondary = Color(0xFF03DAC6);
const Color guideSecondaryVariant = Color(0xFF018786);
const Color guideError = Color(0xFFB00020);
const Color guideErrorDark = Color(0xFFCF6679);
const Color blueBlues = Color(0xFF174378);

final Map<ColorSwatch<Object>, String> colorsNameMap = <ColorSwatch<Object>, String>{
  ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
  ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
  ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
  ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
  ColorTools.createPrimarySwatch(guideError): 'Guide Error',
  ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
  ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
};

class StatefulColorPickerDialog extends StatefulWidget {
  final Function(String, Color) reflashColor;
  final ScreenSize screenSize;
  final String type;

  const StatefulColorPickerDialog(
      {super.key, required this.type, required this.screenSize, required this.reflashColor});

  @override
  _StatefulColorPickerDialogState createState() => _StatefulColorPickerDialogState();
}

class _StatefulColorPickerDialogState extends State<StatefulColorPickerDialog> {
  late String _type;
  late ScreenSize _screenSize;
  String _typeMessage = '';
  late Color beforColor;

  void _setString() {
    switch (_type) {
      case 'AppbarColor':
        _typeMessage = '앱바';
        break;
      case 'BackgroundColor':
        _typeMessage = '배경';
        break;
      case 'MyChatColor':
        _typeMessage = '내 채팅';
        break;
      case 'MyChatStringColor':
        _typeMessage = '내 글자';
        break;
      case 'FriendChatColor':
        _typeMessage = '상대 채팅';
        break;
      case 'FriendChatStringColor':
        _typeMessage = '상대 글자';
        break;
      default:
        _typeMessage = '';
        break;
    }
  }

  // Map<String, Color> chatRoomColorMap = {
  //   'AppbarColor': Colors.white,
  //   'BackgroundColor': mainBackgroundColor,
  //   'MyChatColor': mainLightColor,
  //   'MyChatStringColor': Colors.black,
  //   'FriendChatColor': Colors.white,
  //   'FriendChatStringColor': Colors.black,
  // };

  void _resetString() {
    switch (_type) {
      case 'BackgroundColor':
        chatRoomColorMap[_type] = mainBackgroundColor;
        break;
      case 'MyChatColor':
        chatRoomColorMap[_type] = mainLightColor;
        break;
      case 'MyChatStringColor':
        chatRoomColorMap[_type] = Colors.black;
        break;
      case 'FriendChatColor':
        chatRoomColorMap[_type] = Colors.white;
        break;
      case 'FriendChatStringColor':
        chatRoomColorMap[_type] = Colors.black;
        break;
      default:
        chatRoomColorMap[_type] = mainBackgroundColor;
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _screenSize = widget.screenSize;
    _type = widget.type;
    _setString();
    beforColor = chatRoomColorMap[_type]!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$_typeMessage색상 설정'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            previewWidget(_screenSize),
            ColorPicker(
              color: chatRoomColorMap[_type]!,
              onColorChanged: (Color color) => setState(() => chatRoomColorMap[_type] = color),
              width: 40,
              height: 40,
              borderRadius: 4,
              spacing: 5,
              runSpacing: 5,
              wheelDiameter: 155,
              subheading: Text(
                '색상 톤 선택',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              wheelSubheading: Text(
                '색상 톤 선택',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              showMaterialName: true,
              showColorName: true,
              showColorCode: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                longPressMenu: true,
              ),
              materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
              colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
              colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.bw: false,
                ColorPickerType.custom: true,
                ColorPickerType.wheel: true,
              },
              customColorSwatchesAndNames: colorsNameMap,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                setState(() {
                  _resetString();
                });
              },
              child: const Text('초기화'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                chatRoomColorMap[_type] = beforColor;
                Navigator.of(context).pop(false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                EasyLoading.show();
                await setColorSharedPreferencese(_type, chatRoomColorMap[_type]!);
                widget.reflashColor(_type, chatRoomColorMap[_type]!);
                EasyLoading.dismiss();
                Navigator.of(context).pop(true);
              },
              child: const Text('확인'),
            ),
          ],
        )
      ],
    );
  }
}

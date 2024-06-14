import 'package:chattingapp/home/friend/category/category_setting_screen.dart';
import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/color.dart';
import '../../../utils/screen_movement.dart';
import 'category_data.dart';

class CategoryWidget extends StatefulWidget {
  final ScreenSize screenSize;
  final String categoryName;
  const CategoryWidget({super.key, required this.screenSize, required this.categoryName});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late ScreenSize screenSize;
  late String categoryName;
  late int index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    screenSize = widget.screenSize;
    categoryName = widget.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: screenSize.getWidthSize(),
        height: screenSize.getHeightPerSize(6),
        margin: EdgeInsets.fromLTRB(
            0, screenSize.getHeightPerSize(0.5), 0, screenSize.getHeightPerSize(0.5)),
        decoration: BoxDecoration(
          color: mainLightColor,
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              screenSize.getWidthPerSize(4), 0, screenSize.getWidthPerSize(2), 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
              ),
              Row(
                children: [
                  IconButton(
                      tooltip: "이름 변경",
                      onPressed: () {
                        renameCategoryDialog(context, categoryName);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      tooltip: "순서 변경",
                      onPressed: () {
                        showSequenceCategoryDialog(context, categoryName);
                      },
                      icon: const Icon(Icons.swap_vert)),
                  IconButton(
                      tooltip: "삭제",
                      onPressed: () {
                        deleteCategoryDialog(context, categoryName);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}

void renameCategoryDialog(BuildContext getContext, String categoryName) {
  final renameFormKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  showDialog(
    context: getContext,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("이름 변경"),
        content: Form(
          key: renameFormKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: categoryName,
            ),
            validator: (value) {
              if (value == null || value.length >= 10) {
                return "1글자 이상 10글자 이하로 입력해 주세요";
              } else if (categoryList.containsKey(value)) {
                return "이미 존재하는 이름입니다.";
              }
              return null;
            },
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                if (renameFormKey.currentState!.validate()) {
                  reNameCategory(categoryName, controller.text);
                  Navigator.of(context).pushAndRemoveUntil(
                    screenMovementZero(const CategorySettingScreen(
                      checkData: true,
                    )),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text("변경")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소")),
        ],
      );
    },
  );
}

void deleteCategoryDialog(BuildContext getContext, String categoryName) {
  showDialog(
    context: getContext,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("이름 변경"),
        content: const Text("정말로 삭제하시겠습니까?"),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                deleteCategory(categoryName);
                Navigator.of(context).pushAndRemoveUntil(
                  screenMovementZero(const CategorySettingScreen(
                    checkData: true,
                  )),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("삭제")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소")),
        ],
      );
    },
  );
}

//순서변경 기능부터 시작
class SequenceCategoryDialog extends StatefulWidget {
  final String categoryName;

  const SequenceCategoryDialog({super.key, required this.categoryName});

  @override
  _SequenceCategoryDialogState createState() => _SequenceCategoryDialogState();
}

class _SequenceCategoryDialogState extends State<SequenceCategoryDialog> {
  final GlobalKey<FormState> _sequenceCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late String categoryName;
  late int newIndex;
  late int oldIndex;

  @override
  void initState() {
    super.initState();
    categoryName = widget.categoryName;
    oldIndex = getIndex(categoryName);
    newIndex = oldIndex;
    _controller.text = newIndex.toString();
  }

  void _decrementValue() {
    setState(() {
      int currentValue = int.parse(_controller.text);
      if (currentValue > 1) {
        newIndex = currentValue - 1;
        _controller.text = newIndex.toString();
      }
    });
  }

  void _incrementValue() {
    setState(() {
      int currentValue = int.parse(_controller.text);
      if (categorySequence.length > currentValue) {
        newIndex = currentValue + 1;
        _controller.text = newIndex.toString();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("순서 변경"),
      content: Form(
        key: _sequenceCategoryFormKey,
        child: Row(
          children: [
            IconButton(
              onPressed: _decrementValue,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: TextFormField(
                controller: _controller,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                validator: (value) {
                  if (oldIndex == int.parse(value!)) {
                    return "현재 위치와 동일한 위치로\n이동할 수 없습니다.";
                  }
                  return null;
                },
                onTapOutside: (event) {
                  if (_controller.text.isNotEmpty) {
                    int valueIndex = int.parse(_controller.text);
                    if (valueIndex >= 1 && valueIndex < categorySequence.length) {
                      newIndex = valueIndex;
                    } else {
                      _controller.text = newIndex.toString();
                    }
                  } else {
                    _controller.text = newIndex.toString();
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
            IconButton(
              onPressed: _incrementValue,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (_sequenceCategoryFormKey.currentState!.validate()) {
              changeSequenceCategory(oldIndex, newIndex);
              Navigator.of(context).pushAndRemoveUntil(
                screenMovementZero(const CategorySettingScreen(checkData: true)),
                (Route<dynamic> route) => false,
              );
            }
          },
          child: const Text("변경"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("취소"),
        ),
      ],
    );
  }
}

void showSequenceCategoryDialog(BuildContext context, String categoryName) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return SequenceCategoryDialog(categoryName: categoryName);
    },
  );
}

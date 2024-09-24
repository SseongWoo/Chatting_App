import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/color/color.dart';
import '../../../utils/logger.dart';
import '../../../utils/screen_size.dart';

// 문의사항 화면
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final _questionsFirstFormKey = GlobalKey<FormState>();
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDetails = TextEditingController();

  Future<void> _setQuestions() async {
    try {
      var uuid = const Uuid();
      String newUid = uuid.v4();
      await FirebaseFirestore.instance
          .collection('report')
          .doc('questions')
          .collection('unconfirmed')
          .doc(newUid)
          .set({
        'report_uid': newUid,
        'user_uid': myData.myUID,
        'user_name': myData.myNickName,
        'user_email': myData.myEmail,
        'questions_title': _controllerTitle.text,
        'questions_details': _controllerDetails.text,
        'questions_details_time': DateTime.now(),
      });
      snackBarMessage(context, '문의사항 전송이 완료되었습니다. 소중한 의견 감사합니다.');
    } catch (e) {
      snackBarErrorMessage(
          context, '문의사항 등록이 정상적으로 처리되지 않았습니다. 불편을 드려 죄송합니다. [email]으로 내용을 보내주시면 빠르게 처리하겠습니다.');
      logger.e('setQuestions오류 : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 사항'),
        backgroundColor: mainLightColor,
      ),
      body: Center(
        child: Form(
          key: _questionsFirstFormKey,
          child: SizedBox(
            width: screenSize.getWidthPerSize(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenSize.getHeightPerSize(2.5),
                ),
                SizedBox(
                  child: Text(
                    '유저코드 : ${myData.myUID}',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                  ),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(1),
                ),
                SizedBox(
                  child: Text(
                    '유저명 : ${myData.myNickName}',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                  ),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(1),
                ),
                SizedBox(
                  child: Text(
                    '답변 받을 이메일 : ${myData.myEmail}',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                  ),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(1),
                ),
                SizedBox(
                  child: Text(
                    '제목',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                  ),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(1),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(), // 외곽선만 있는 스타일
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: mainLightColor, // 포커스 시 외곽선 색상
                        width: 2.0, // 외곽선 두께
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // 기본 외곽선 색상
                        width: 1.0, // 외곽선 두께
                      ),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(1.3)),
                  maxLines: 1,
                  maxLength: 20,
                  controller: _controllerTitle,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return '제목을 입력해 주세요';
                    } else if (value!.length < 2) {
                      return '두글자이상 입력해 주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  child: Text(
                    '내용',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                  ),
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(1),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: '문의하신 내용에 대한 답변은 등록하신 이메일로\n전송됩니다.',
                    border: const OutlineInputBorder(), // 외곽선만 있는 스타일
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: mainLightColor, // 포커스 시 외곽선 색상
                        width: 2.0, // 외곽선 두께
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // 기본 외곽선 색상
                        width: 1.0, // 외곽선 두께
                      ),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(1.5)),
                  maxLines: 10,
                  maxLength: 200,
                  controller: _controllerDetails,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return '내용을 입력해 주세요';
                    } else if (value!.length < 2) {
                      return '두글자이상 입력해 주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.getHeightPerSize(2),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(90),
                  height: screenSize.getHeightPerSize(6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainLightColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    onPressed: () async {
                      if (_questionsFirstFormKey.currentState!.validate()) {
                        EasyLoading.show();
                        await _setQuestions();
                        EasyLoading.dismiss();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      '문의하기',
                      style:
                          TextStyle(fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

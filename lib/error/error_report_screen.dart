import 'package:chattingapp/utils/my_data.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';
import '../utils/color/color.dart';
import '../utils/logger.dart';
import '../utils/screen_size.dart';

class ErrorReportScreen extends StatefulWidget {
  final String errorMessage;
  const ErrorReportScreen({
    super.key,
    required this.errorMessage,
  });

  @override
  State<ErrorReportScreen> createState() => _ErrorReportScreenState();
}

class _ErrorReportScreenState extends State<ErrorReportScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _setBugReport() async {
    try {
      var uuid = const Uuid();
      String newUid = uuid.v4();
      await FirebaseFirestore.instance
          .collection('report')
          .doc('error')
          .collection('unconfirmed')
          .doc(newUid)
          .set({
        'report_uid': newUid,
        'user_uid': myData.myUID,
        'user_name': myData.myNickName,
        'bug_location': '',
        'bug_content': widget.errorMessage,
        'bug_details': _controller.text,
        'bug_reoprt_time': DateTime.now(),
      });
      snackBarMessage(context, '버그 제보가 완료되었습니다. 소중한 의견 감사합니다.');
    } catch (e) {
      snackBarErrorMessage(
          context, '제보가 정상적으로 처리되지 않았습니다. 불편을 드려 죄송합니다. [email]으로 내용을 보내주시면 빠르게 처리하겠습니다.');
      logger.e('setBugReport오류 : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('버그 제보'),
        backgroundColor: mainLightColor,
      ),
      body: Center(
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
                  '버그 발생 위치 : ',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              SizedBox(
                child: Text(
                  '버그 내용 : ${widget.errorMessage}',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              SizedBox(
                child: Text(
                  '버그 상세 설명',
                  style: TextStyle(fontSize: screenSize.getHeightPerSize(1.8)),
                ),
              ),
              SizedBox(
                height: screenSize.getHeightPerSize(1),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: '입력하지 않아도 계속 진행할 수 있습니다.',
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
                controller: _controller,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
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
                    EasyLoading.show();
                    await _setBugReport();
                    EasyLoading.dismiss();
                    Navigator.pop(context);
                  },
                  child: Text(
                    '제보하기',
                    style: TextStyle(fontSize: screenSize.getHeightPerSize(3), color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

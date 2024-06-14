import 'dart:ui';

import 'package:intl/intl.dart';

int dateDifference(String dateString) {
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  // 문자열을 DateTime 객체로 변환
  DateTime inputDate = dateFormat.parse(dateString);
  // 오늘 날짜 가져오기
  DateTime today = DateTime.now();
  // 두 날짜의 차이 계산
  int differenceInDays = today.difference(inputDate).inDays;
  // 7일 이상 차이가 나는지 확인
  return differenceInDays;
}

// 받은 DateTime 형식을 변환해서 오전 05시 30분 같은 형식으로 바꾸어서 내보내는 함수
String dateTimeConvert(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('a hh시 mm분');
  return dateFormat.format(dateTime).replaceAll('AM', '오전').replaceAll('PM', '오후');
}

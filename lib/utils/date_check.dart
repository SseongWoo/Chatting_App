import 'package:intl/intl.dart';

int dateDifference(String dateString){
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
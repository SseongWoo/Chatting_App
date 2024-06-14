import 'dart:io' show Platform;

// dart:io의 기능중 Platform 기능을 사용하여 지금 앱을 실행하는 기기의 OS를 체크하는 기능
String getPlatform(){
  if (Platform.isAndroid) {
    return "AOS";
  } else if (Platform.isIOS) {
    return "IOS";
  } else {
    return "AnotherOS";
  }
}
import 'dart:io' show Platform;

String getPlatform(){
  if (Platform.isAndroid) {
    return "AOS";
  } else if (Platform.isIOS) {
    return "IOS";
  } else {
    return "AnotherOS";
  }
}
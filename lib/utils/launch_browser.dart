import 'package:url_launcher/url_launcher.dart';

// 외부 브라우저를 실행시키는 함수
final Uri _url = Uri.parse('https://github.com/SseongWoo/Chatting_App');
Future<void> launchBrowser() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'logger.dart';

// 플랫폼별로 다운로드 폴더 경로를 가져오기
Future<String> getStoragePath() async {
  try {
    Directory directory;
    if (Platform.isAndroid) {
      // Android에서는 외부 저장소 경로를 사용
      directory = (await getExternalStorageDirectory())!;
    } else if (Platform.isIOS) {
      // iOS에서는 내부 저장소 경로를 사용
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
    return directory.path;
  } catch (e) {
    logger.e('getStoragePath오류 : $e');
    return '';
  }
}

// 파일 다운로드 함수
Future<void> downloadFile(String url, String fileName) async {
  try {
    // HTTP GET 요청으로 파일 다운로드
    final response = await http.get(Uri.parse(url));

    // 응답 성공 여부 확인
    if (response.statusCode == 200) {
      // 기기에 저장할 경로 얻기
      String downloadPath = await getStoragePath();
      if (downloadPath != '') {
        final filePath = '$downloadPath/fluttalk$fileName';
        final File file = File(filePath);

        // 파일 쓰기
        await file.writeAsBytes(response.bodyBytes);
      }
    } else {
      logger.e('downloadFile오류 : 파일 다운로드 실패');
    }
  } catch (e) {
    logger.e('downloadFile오류 : $e');
  }
}

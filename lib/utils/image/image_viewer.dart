import 'package:chattingapp/utils/screen_size.dart';
import 'package:chattingapp/utils/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../file_download.dart';

// 전달받은 이미지의 url을 사용해서 화면에 이미지를 띄워주는 화면
class ImageViewer extends StatefulWidget {
  final String imageURL;
  const ImageViewer({super.key, required this.imageURL});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late ScreenSize screenSize;
  @override
  Widget build(BuildContext context) {
    screenSize = ScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(imageProvider: NetworkImage(widget.imageURL)),
          Positioned(
            top: screenSize.getHeightPerSize(4),
            left: screenSize.getWidthPerSize(2),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          Positioned(
            top: screenSize.getHeightPerSize(4),
            right: screenSize.getWidthPerSize(2),
            child: IconButton(
              onPressed: () async {
                await downloadFile(widget.imageURL, DateTime.now().toString());
                snackBarMessage(context, '이미지 다운로드 완료');
              },
              icon: const Icon(Icons.download, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

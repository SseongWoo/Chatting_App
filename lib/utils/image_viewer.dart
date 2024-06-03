import 'package:chattingapp/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
        ],
      ),
    );
  }
}
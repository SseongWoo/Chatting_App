import 'package:flutter/material.dart';

// 이미지를 불러올때 로딩을 구현한 위젯
Widget imageWidget(String imageUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: imageUrl.isNotEmpty
        ? AspectRatio(
            aspectRatio: 1, //  1대1비율
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder:
                  (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child; // 이미지 로드 완료
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                }
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Center(
                  child: Text('이미지 로딩 오류'),
                );
              },
            ),
          )
        : Image.asset(
            'assets/images/blank_profile.png',
          ),
  );
}

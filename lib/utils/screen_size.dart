import 'package:flutter/material.dart';

// 화면 사이즈 클래스
class ScreenSize {
  late Size screenSize;

  ScreenSize(this.screenSize);

  double getHeightSize() {
    return screenSize.height;
  }

  double getWidthSize() {
    return screenSize.width;
  }

  double getHeightPerSize(double per) {
    return (screenSize.height * per) / 100;
  }

  double getWidthPerSize(double per) {
    return (screenSize.width * per) / 100;
  }
}

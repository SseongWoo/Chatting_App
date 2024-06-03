import 'package:flutter/material.dart';

import '../login/registration/authentication.dart';

class StateObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 어플리케이션이 종료될 때 실행되는 함수 호출
      appClosed();
    }
  }

// 앱이 종료될 때 실행
  void appClosed() {
    //signOut();
    print('어플리케이션이 종료됩니다.');
  }
}

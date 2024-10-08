import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:flutter/material.dart';

// 앱의 상태를 감지하는 기능
class StateObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 어플리케이션이 종료될 때 실행되는 함수 호출
      appClosed();
    }
  }

// 앱이 종료될 때 실행
  void appClosed() async {
    //signOut();
    print('어플리케이션이 종료됩니다.');
    await setTapShared();
  }
}

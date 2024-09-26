import 'package:chattingapp/utils/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../home/chat/chat_list_data.dart';
import '../home/friend/friend_data.dart';
import 'my_data.dart';

// 데이터를 새로 불러오는 함수
Future<void> refreshData(BuildContext context) async {
  await getFriendDataList(context);
  await getChatRoomData(context);
  await getChatRoomDataList(context);
  await getMyData();
  await getTapShared();
  await getRealTimeData(context);
}

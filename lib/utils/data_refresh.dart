import 'package:chattingapp/utils/shared_preferences.dart';
import '../home/chat/chat_list_data.dart';
import '../home/friend/friend_data.dart';
import 'my_data.dart';

// 데이터를 새로 불러오는 함수
Future<void> refreshData() async {
  await getFriendDataList();
  await getChatRoomData();
  await getChatRoomDataList();
  await getMyData();
  await getTapShared();
  await getRealTimeData();
}

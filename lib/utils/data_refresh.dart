import '../home/chat/chat_data.dart';
import '../home/friend/friend_data.dart';

Future<void> refreshData() async {
  await getFriendDataList();
  await getChatRoomData();
  await getChatRoomDataList();
}

import '../home/chat/chat_list_data.dart';
import '../home/friend/friend_data.dart';

Future<void> refreshData() async {
  await getFriendDataList();
  await getChatRoomData();
  await getChatRoomDataList();
}

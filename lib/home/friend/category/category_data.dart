import 'package:chattingapp/utils/my_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/convert_array.dart';
import '../../../utils/logger.dart';
import '../friend_data.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
List<String> categorySequence = [];
Map<String, List<String>> categoryList = {};
bool categoryControlCheck = false;
List<String> deleteUserList = [];

// 카테고리 데이터를 서버에서 가져와 리스트에 저장하는 함수
Future<void> getCategoryList() async {
  try {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(myData.myUID).get();
    if (documentSnapshot.exists) {
      categoryList = convertMap(documentSnapshot.get('category'));
      categorySequence = convertList(documentSnapshot.get('category_sequence'));
    } else {
      logger.e('getCategoryList오류');
    }
  } catch (e) {
    logger.e('getCategoryList오류 : $e');
  }
}

// getCategoryList 에서 저장한 카테고리 리스트에 친구 데이터를 넣는 함수
void getCategory() {
  FriendData? friendData;
  if (friendList.isNotEmpty) {
    for (int i = 0; i < friendList.length; i++) {
      friendData = friendList[friendListSequence[i]];
      if (friendData!.category.isNotEmpty) {
        for (var categoryL in friendData.category) {
          if (!categoryList.containsKey(categoryL)) {
            categoryList[categoryL] = [];
            categorySequence.add(categoryL);
          } else {
            categoryList[categoryL]?.add(friendData.friendUID);
          }
        }
      }
    }
  }
}

// 카테고리 설정 화면에서 카테고리를 수정했을 경우 실행되는 함수이며
// deleteCategory 함수에서 설정 된 deleteUserList 리스트에 속해있는 친구데이터의 카테고리를 수정뒤,
// 사용자의 카테고리 데이터도 수정하는 함수
Future<void> setCategory() async {
  try {
    for (var item in deleteUserList) {
      await firestore.collection('users').doc(myData.myUID).collection('friend').doc(item).update({
        'category': friendList[friendListUidKey[item]]?.category,
      });
    }
    await firestore.collection('users').doc(myData.myUID).update({
      'category': categoryList,
      'category_sequence': categorySequence,
    });
    deleteUserList.clear();
  } catch (e) {
    logger.e('setCategory오류 : $e');
  }
}

// 카테고리 이름이 중복이 없을 경우 카테고리 리스트에 추가하는 함수
void addCategory(String newCategoryName) {
  List<String> newList = [];
  if (!categoryList.containsKey(newCategoryName)) {
    categorySequence.add(newCategoryName);
    categoryList[newCategoryName] = newList;
  }
}

// 카테고리를 삭제하는 함수
// 삭제될 카테고리에 속해 있던 친구의 카테고리 데이터를 수정하기 위해
// deleteUserList 리스트에 친구데이터를 저장뒤 setCategory에서 수정
void deleteCategory(String deleteCategoryName) {
  if (categoryList.containsKey(deleteCategoryName)) {
    for (var categoryUser in categoryList[deleteCategoryName]!) {
      friendList[friendListUidKey[categoryUser]]?.category.remove(deleteCategoryName);
      if (!deleteUserList.contains(categoryUser)) {
        deleteUserList.add(categoryUser);
      }
    }
    categorySequence.removeAt(getIndex(deleteCategoryName));
    categoryList.remove(deleteCategoryName)!;
  }
}

// 카테고리 이름을 카테고리 리스트에서 수정하는 함수
void reNameCategory(String oldCategoryName, String newCategoryName) {
  if (categoryList.containsKey(oldCategoryName)) {
    categorySequence[getIndex(oldCategoryName)] = newCategoryName;
    categoryList[newCategoryName] = categoryList.remove(oldCategoryName)!;
  }
}

// 특정 카테고리가 리스트에서 몇번째에 위치해있는지 출력해주는 함수
int getIndex(String categoryName) {
  return categorySequence.indexOf(categoryName);
}

// 카테고리의 리스트 위치를 변경하는 함수
void changeSequenceCategory(int oldIndex, int newIndex) {
  String item = categorySequence.removeAt(oldIndex);
  categorySequence.insert(newIndex, item);
}

// DB에 카테고리 리스트와 친구 데이터의 카테고리 데이터를 수정하는 작업
Future<void> addCategoryUserData(List<String> category, FriendData friendData) async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      // 기존 친구가 속해있는 카테고리 데이터에서 친구 데이터 삭제
      for (var item in friendData.category) {
        categoryList[item]?.remove(friendData.friendUID);
      }

      // category 리스트에 있는 카테고리 데이터에 새롭게 친구 데이터 등록
      for (var item in category) {
        if (!categoryList[item]!.contains(friendData.friendUID)) {
          categoryList[item]?.add(friendData.friendUID);
        }
      }

      // friendList리스트에 있는 친구의 카테고리 데이터 업데이트
      friendList[friendData.friendNickName]?.category = category;

      // DB에 카테고리 데이터 업데이트
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('friend')
          .doc(friendData.friendUID)
          .update({
        'category': category,
      });
      await firestore.collection('users').doc(user.uid).update({
        'category': categoryList,
      });
    }
  } catch (e) {
    logger.e('addCategoryUserData오류 : $e');
  }
}

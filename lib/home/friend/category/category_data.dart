import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/convert_array.dart';
import '../friend_data.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
List<String> categorySequence = [];
Map<String, List<String>> categoryList = {};
bool categoryControlCheck = false;
List<String> deleteUserList = [];



Future<void> getCategoryList() async {
  try {
    User? user = _auth.currentUser;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (documentSnapshot.exists) {
      // Map<String, dynamic> mapData = documentSnapshot.get('category');
      // List<dynamic> listData = documentSnapshot.get('category_sequence');
      // categoryList = mapData.map((key, value) {
      //   return MapEntry(key, List<String>.from(value));
      // });
      // categorySequence = List<String>.from(listData);
      categoryList = convertMap(documentSnapshot.get('category'));
      categorySequence = convertList(documentSnapshot.get('category_sequence'));
    } else {
      print("getCategoryList에러1");
    }
  } catch (e) {
    print('getCategoryList에러: $e');
  }
}

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

Future<void> setCategory() async {
  User? user = _auth.currentUser;
  if (user != null) {
    for(var item in deleteUserList){
      await firestore.collection("users").doc(user.uid).collection("friend").doc(item).update({
        "category": friendList[friendListUidKey[item]]?.category,
      });
    }
    await firestore.collection("users").doc(user.uid).update({
      "category": categoryList,
      "category_sequence": categorySequence,
    });
  }
  deleteUserList = [];
}

void addCategory(String newCategoryName) {
  List<String> newList = [];
  if (!categoryList.containsKey(newCategoryName)) {
    categorySequence.add(newCategoryName);
    categoryList[newCategoryName] = newList;
  }
}

void deleteCategory(String deleteCategoryName) {
  if (categoryList.containsKey(deleteCategoryName)) {
    for(var categoryUser in categoryList[deleteCategoryName]!){
       friendList[friendListUidKey[categoryUser]]?.category.remove(deleteCategoryName);
      if(!deleteUserList.contains(categoryUser)){
        deleteUserList.add(categoryUser);
      }
    }
    categorySequence.removeAt(getIndex(deleteCategoryName));
    categoryList.remove(deleteCategoryName)!;
  }
}

void reNameCategory(String oldCategoryName, String newCategoryName) {
  if (categoryList.containsKey(oldCategoryName)) {
    categorySequence[getIndex(oldCategoryName)] = newCategoryName;
    categoryList[newCategoryName] = categoryList.remove(oldCategoryName)!;
  }
}

int getIndex(String categoryName) {
  return categorySequence.indexOf(categoryName);
}

void changeSequenceCategory(int oldIndex, int newIndex) {
  String item = categorySequence.removeAt(oldIndex);
  categorySequence.insert(newIndex, item);
}

Future<void> addCategoryUserData(
    List<String> category, FriendData friendData) async {
  try{
    User? user = _auth.currentUser;
    if (user != null) {
      for(var item in friendData.category){
        categoryList[item]?.remove(friendData.friendUID);
      }
      for (var item in category) {
        if(!categoryList[item]!.contains(friendData.friendUID)){
          categoryList[item]?.add(friendData.friendUID);
        }
      }
      friendList[friendData.friendNickName]?.category = category;
      await firestore
          .collection("users")
          .doc(user.uid)
          .collection("friend")
          .doc(friendData.friendUID)
          .update({
        "category": category,
      });
      await firestore
          .collection("users")
          .doc(user.uid)
          .update({
        "category": categoryList,
      });
    }
  }catch(e){
    print("addCategoryUserData 오류 : $e");
  }

}

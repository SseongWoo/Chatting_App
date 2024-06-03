// import 'package:animated_reorderable_list/animated_reorderable_list.dart';
// import 'package:buttons_tabbar/buttons_tabbar.dart';
// import 'package:chattingapp/home/friend/request/friend_request_screen.dart';
// import 'package:chattingapp/utils/screen_size.dart';
// import 'package:flutter/material.dart';
//
// class Example extends StatefulWidget {
//   Example({Key? key}) : super(key: key);
//
//   @override
//   _ExampleState createState() => _ExampleState();
// }
//
// class _ExampleState extends State<Example> with TickerProviderStateMixin {
//   late TabController tabController;
//   List<String> testList = ["전체"];
//   int count = 1;
//   late ScreenSize screenSize;
//
//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: testList.length, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }
//
//   void _updateTabController() {
//     tabController.dispose();
//     tabController = TabController(length: testList.length, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     screenSize = ScreenSize(MediaQuery.of(context).size);
//     return MaterialApp(
//       home: DefaultTabController(
//         length: testList.length,
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text('Buttons TabBar with Category List'),
//             actions: [
//               IconButton(
//                 onPressed: () {
//                   setState(() {
//                     testList.add("$count번째 카테고리 입니다.");
//                     count++;
//                     _updateTabController();
//                   });
//                 },
//                 icon: Icon(Icons.ac_unit),
//               ),
//             ],
//           ),
//           body: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: ButtonsTabBar(
//                       controller: tabController,
//                       backgroundColor: Colors.red,
//                       unselectedBackgroundColor: Colors.grey[300],
//                       borderWidth: 1,
//                       borderColor: Colors.black,
//                       unselectedBorderColor: Colors.grey,
//                       labelStyle: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       unselectedLabelStyle: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       tabs: testList
//                           .map((String name) => Tab(text: name))
//                           .toList(),
//                     ),
//                   ),
//                   Container(
//                     width: 50,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         left: BorderSide(color: Colors.grey, width: 0.5),
//                       ),
//                     ),
//                     child: IconButton(
//                       onPressed: () {},
//                       icon: const Icon(Icons.settings),
//                     ),
//                   ),
//                 ],
//               ),
//               Expanded(
//                 child: AnimatedReorderableListView(
//                   items: testList,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Container(
//                       key: Key(testList[index]), // 고유한 Key 사용
//                       width: screenSize.getWidthSize(),
//                       height: screenSize.getHeightPerSize(10),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey, width: 0.5),
//                       ),
//                       child: Center(child: Text(testList[index])),
//                     );
//                   },
//                   enterTransition: [FadeIn(), ScaleIn()],
//                   exitTransition: [ScaleIn()],
//                   insertDuration: const Duration(milliseconds: 300),
//                   removeDuration: const Duration(milliseconds: 300),
//                   onReorder: (int oldIndex, int newIndex) {
//                     setState(() {
//                       if (newIndex > oldIndex) {
//                         newIndex -= 1;
//                       }
//                       final String item = testList.removeAt(oldIndex);
//                       testList.insert(newIndex, item);
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

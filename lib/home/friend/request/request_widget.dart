import 'package:flutter/material.dart';
import 'request_data.dart';
import '../../../utils/screen_size.dart';

// 보낸 요청 위젯
class RequestSentWidget extends StatefulWidget {
  final ScreenSize screenSize;
  final int index;

  const RequestSentWidget(
      {super.key, required this.screenSize, required this.index});

  @override
  State<RequestSentWidget> createState() => _RequestSentWidgetState();
}

class _RequestSentWidgetState extends State<RequestSentWidget> {
  late ScreenSize screenSize;
  late int index;
  bool deleteWidget = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    screenSize = widget.screenSize;
    index = widget.index;
  }

  Future<void> delete() async {
    if(!deleteWidget){    // 거부된 요청이 아닐경우
      await deleteRequest(requestSendList[index].requestUID, true, true);
    }else{                //거부된 요청일 경우
      await deleteRequest(requestSendList[index].requestUID, true, false);
    }
    setState(() {
      requestSendList.removeAt(index);
      deleteWidget = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.getHeightPerSize(10),
      width: screenSize.getWidthSize(),
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: Colors.grey, width: 0.2),
      )),
      child: deleteWidget
          ? const Center(
              child: Text("삭제된 요청입니다."),
            )
          : Row(
              children: [
                SizedBox(
                  width: screenSize.getWidthPerSize(2),
                ),
                SizedBox(
                    width: screenSize.getWidthPerSize(18),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        requestSendList[index].requestProfile,
                      ),
                    )),
                SizedBox(
                  width: screenSize.getWidthPerSize(1),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          requestSendList[index].requestNickName,
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(2)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          requestSendList[index].requestCheck
                              ? "요청 거부됨"
                              : "수락 대기중",
                          style: TextStyle(
                              fontSize: screenSize.getHeightPerSize(1),
                              color: requestSendList[index].requestCheck
                                  ? Colors.red
                                  : Colors.grey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(26),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const BeveledRectangleBorder(),
                      ),
                      onPressed: () {
                        delete();
                      },
                      child: Text(
                        requestSendList[index].requestCheck ? "삭제" : "취소",
                        style: TextStyle(
                            fontSize: screenSize.getHeightPerSize(2),
                            color: requestSendList[index].requestCheck
                                ? Colors.red
                                : Colors.black),
                      )),
                ),
                SizedBox(
                  width: screenSize.getWidthPerSize(2),
                ),
              ],
            ),
    );
  }
}

class RequestReceivedWidget extends StatefulWidget {
  final ScreenSize screenSize;
  final int index;

  const RequestReceivedWidget(
      {super.key, required this.screenSize, required this.index});

  @override
  State<RequestReceivedWidget> createState() => _RequestReceivedWidgetState();
}

class _RequestReceivedWidgetState extends State<RequestReceivedWidget> {
  late ScreenSize screenSize;
  late int index;
  bool deleteWidget = false; // 사용자가 조작을 한 상태인지 아닌지 구분해주는 변수
  bool checkWidget = false;  // 수락한 요청인지, 거절한 요청인지 구분해주는 변수

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    screenSize = widget.screenSize;
    index = widget.index;
    if (requestReceivedList[index].requestCheck) {
      deleteWidget = true;
      checkWidget = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.getHeightPerSize(12),
      width: screenSize.getWidthSize(),
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: Colors.grey, width: 0.2),
      )),
      child: Stack(
        children: [
          Visibility(
            visible: deleteWidget && !checkWidget,
            child: Positioned(
                top: 0,
                right: 0,
                child: IconButton(onPressed: () {
                  setState(() {
                    deleteRequest(requestReceivedList[index].requestUID,true,false);
                  });
            }, icon: const Icon(Icons.close))),
          ),
          Row(
            children: [
              SizedBox(
                width: screenSize.getWidthPerSize(2),
              ),
              SizedBox(
                  width: screenSize.getWidthPerSize(22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      requestReceivedList[index].requestProfile,
                    ),
                  )),
              SizedBox(
                width: screenSize.getWidthPerSize(1),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(73),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenSize.getHeightPerSize(1),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        requestReceivedList[index].requestNickName,
                        style: TextStyle(fontSize: screenSize.getHeightPerSize(2)),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: screenSize.getHeightPerSize(1),
                    ),
                    deleteWidget
                        ? Center(
                      child: Text(
                        checkWidget ? "수락한 요청입니다." : "거절한 요청입니다.",
                        style: TextStyle(
                            color: checkWidget
                                ? Colors.greenAccent
                                : Colors.redAccent),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenSize.getWidthPerSize(36),
                          height: screenSize.getHeightPerSize(4),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async{
                                bool check = await requestCheck(requestReceivedList[index].requestUID);
                                if(check){
                                  setState(() {
                                    deleteWidget = true;
                                    checkWidget = true;
                                  });
                                  addFriendRequest(
                                      requestReceivedList[index].requestUID,
                                      context);
                                }else{
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text("문제가 발생하였습니다. 다시 시도해 주세요")));
                                }
                              },
                              child: Text(
                                "수락",
                                style: TextStyle(
                                    fontSize:
                                    screenSize.getHeightPerSize(1.5),
                                    color: Colors.black),
                              )),
                        ),
                        SizedBox(
                          width: screenSize.getWidthPerSize(1),
                        ),
                        SizedBox(
                          width: screenSize.getWidthPerSize(36),
                          height: screenSize.getHeightPerSize(4),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async{
                                bool check = await requestCheck(requestReceivedList[index].requestUID);
                                if(check){
                                  setState(() {
                                    deleteWidget = true;
                                    checkWidget = false;
                                  });
                                  updateRequest(
                                      requestReceivedList[index].requestUID);
                                }else{
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text("문제가 발생하였습니다. 다시 시도해 주세요")));
                                }
                              },
                              child: Text(
                                "거절",
                                style: TextStyle(
                                    fontSize:
                                    screenSize.getHeightPerSize(1.5),
                                    color: Colors.black),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.getWidthPerSize(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newflutter/model/category_info.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<CategoryType> category = CategoryType.values;
  CategoryType selectedCategory = CategoryType.values[0];

  final Map<DateTime, List<Color>> _markers = {}; // 날짜별 여러 마커를 저장


  // 입금처 & 입금 금액
  TextEditingController depositPlace = TextEditingController();
  TextEditingController depositMoney = TextEditingController();

  // 지출처 & 지출 금액
  TextEditingController withdrawPlace = TextEditingController();
  TextEditingController withdrawMoney = TextEditingController();
  
  // 메모
  TextEditingController depositMemo = TextEditingController();
  TextEditingController withdrawMemo = TextEditingController();
  TextEditingController plainMemo = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '일정 관리',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 25,
          ),
        ),
      ),
      body: TableCalendar(
        rowHeight: 100,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          showScheduleList(context);
        },
        onHeaderTapped: _showDatePicker,
        onDayLongPressed: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          showOptions(context, selectedDay);
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, _) {
            if (_markers.containsKey(day)) {
              return Positioned(
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _markers[day]!
                      .map(
                        (color) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      .toList(),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
  
  // DatePicker 팝업 함수
  void _showDatePicker(focusedDay) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: focusedDay,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year, // 연도와 월을 선택할 수 있도록 설정
    );

    if (pickedDate != null) {
      setState(() {
        _focusedDay = pickedDate; // 선택한 날짜로 이동
      });
    }
  }

  // 날짜 롱클릭시 나타날 메뉴 선택창 팝업 함수
  void showOptions(BuildContext context, DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.add,
                color: Colors.blue,
              ),
              title: Text('입금 내역 추가'),
              onTap: () {
                Navigator.pop(context);
                showDepositDialog(context, selectedDay);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.remove,
                color: Colors.red,
              ),
              title: Text('지출 내역 추가'),
              onTap: () {
                Navigator.pop(context);
                showWithdrawDialog(context, selectedDay);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('메모 추가'),
              onTap: () {
                Navigator.pop(context);
                showAddMemoDialog(context, selectedDay);
              },
            ),
          ],
        );
      },
    );
  }

  // 특정 날짜를 탭했을 때 해당 날짜의 메모 및 입금/지출 내역을 불러와 표시하는 함수
  void showScheduleList(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FutureBuilder<QuerySnapshot>( // 비동기 작업을 Build
            future: FirebaseFirestore.instance.collection('transactions').get(), // 할 작업 : users 컬렉션 읽기

            // AsyncSnapshot : 비동기 작업의 진행 상태와 결과 값을 저장.
            // 여기서 AsyncSnapshot의 결과값은 비동기 작업(FutureBuilder)의 결과물인 QuerySnapshot.
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              
              // 비동기 작업의 진행 상태에 따라 서로 다른 UI 보여줌
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 로딩 상태
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                // 에러 상태
                return Center(child: Text('오류가 발생했습니다.'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // 데이터가 없을 때
                return Center(child: Text('사용자 데이터가 없습니다.'));
              }

              // Firestore 문서 데이터를 UI로 변환
              // QueryDocumentSnapshot은 문서 하나하나를 나타냄
              final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

              return SingleChildScrollView( // 한 화면에 정보를 모두 띄우지 못할 경우 스크롤 가능
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  // map 함수는 각 docs의 각 항목(문서)을 순회.
                  children: docs.map((doc) {
                    // 각 문서의 정보를 <String, dynamic>의 Map 구조로 변환.
                    final data = doc.data() as Map<String, dynamic>;

                    // 각 문서의 정보를 하나의 컨테이너에 담아서 반환.
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.entries.map((entry) {
                          return Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(fontSize: 14),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 입금 내역 추가 dialog
  void showDepositDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 카테고리 선택시 변동 사항이 즉시 반영되도록 StatefulBuilder 사용.

          // setState 사용시 마커가 다이얼로그 종료 후 찍히거나 카테고리 변동 사항이 늦게 반영되는 오류 발생.
          // 따라서 다이얼로그 위젯 외부에 작동하는 setState와 다이얼로그 내에서에 작동하는 dialogSetState를 구분,
          // 마커나 카테고리 변동이 다이얼로그의 라이프 사이클과 관계없이 적용되도록 함.
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: Text(
                "입금 내역 추가",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: TextStyle(
                      color : Colors.white,
                    ),
                    controller: depositPlace,
                    decoration: const InputDecoration(
                      labelText: "입금처",
                      hintText: "입금처",
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      color : Colors.white,
                    ),
                    controller: depositMoney,
                    decoration: const InputDecoration(
                      labelText: "입금 금액",
                      hintText: "입금 금액",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      color : Colors.white,
                    ),
                    maxLines: 2,
                    controller: depositMemo,
                    decoration: const InputDecoration(
                      labelText: "메모",
                      hintText: "메모",
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "카테고리 선택",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: DropdownButton(
                          dropdownColor: Colors.black,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          hint: Text("카테고리를 선택하세요."),
                          value: selectedCategory,
                          items: category.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.categoryName),
                          )).toList(),
                          onChanged: (value) {
                            dialogSetState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                    depositPlace.clear();
                    depositMoney.clear();
                    depositMemo.clear();
                  },
                  child: Text(
                    "취소",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if(depositPlace.text == "" || depositMoney.text == "" || depositMemo.text == "") {
                      cannotSendFirebaseToast();
                    }

                    else {
                      // 입금 내역 firebase firestore로 전송
                      addDeposit();

                      setState(() {

                        // 선택된 날짜에 입금 내역이 없다면 마커 자리를 마련한 후 파란색 마커를 추가
                        if (!_markers.containsKey(selectedDay)) {
                          _markers[selectedDay] = [];
                        }
                        if (!_markers[selectedDay]!.contains(Colors.blue)) {
                          _markers[selectedDay]!.add(Colors.blue);
                        }
                      });

                      // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                      depositPlace.clear();
                      depositMoney.clear();
                      depositMemo.clear();

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    "확인",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          });
      },
    );
  }

  // 지출 내역 추가 dialog
  void showWithdrawDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 카테고리 선택시 변동 사항이 즉시 반영되도록 StatefulBuilder 사용.

          // setState 사용시 마커가 다이얼로그 종료 후 찍히거나 카테고리 변동 사항이 늦게 반영되는 오류 발생.
          // 따라서 다이얼로그 위젯 외부에 작동하는 setState와 다이얼로그 내에서에 작동하는 dialogSetState를 구분,
          // 마커나 카테고리 변동이 다이얼로그의 라이프 사이클과 관계없이 적용되도록 함.
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: Text("지출 내역 추가"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: withdrawPlace,
                    decoration: const InputDecoration(
                      labelText: "지출처",
                      hintText: "지출처",
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: withdrawMoney,
                    decoration: const InputDecoration(
                      labelText: "지출 금액",
                      hintText: "지출 금액",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    maxLines: 2,
                    controller: withdrawMemo,
                    decoration: const InputDecoration(
                      labelText: "메모",
                      hintText: "메모",
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "카테고리 선택",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: DropdownButton(
                          isExpanded: true,
                          hint: Text("카테고리를 선택하세요."),
                          value: selectedCategory,
                          items: category.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.categoryName),
                          )).toList(),
                          onChanged: (value) {
                            dialogSetState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                    withdrawPlace.clear();
                    withdrawMoney.clear();
                    withdrawMemo.clear();
                  },
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    if(withdrawPlace.text == "" || withdrawMoney.text == "" || withdrawMemo.text == "") {
                      cannotSendFirebaseToast();
                    }

                    else {
                      // 지출 내역 firebase firestore로 전송
                      addWithdraw();

                      setState(() {
                        // 선택된 날짜에 지출 내역이 없다면 마커 자리를 마련한 후 빨간색 마커를 추가
                        if (!_markers.containsKey(selectedDay)) {
                          _markers[selectedDay] = [];
                        }
                        if (!_markers[selectedDay]!.contains(Colors.red)) {
                          _markers[selectedDay]!.add(Colors.red);
                        }
                      });

                      // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                      withdrawPlace.clear();
                      withdrawMoney.clear();
                      withdrawMemo.clear();

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("확인"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void showAddMemoDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 카테고리 선택시 변동 사항이 즉시 반영되도록 StatefulBuilder 사용.

          // setState 사용시 마커가 다이얼로그 종료 후 찍히거나 카테고리 변동 사항이 늦게 반영되는 오류 발생.
          // 따라서 다이얼로그 위젯 외부에 작동하는 setState와 다이얼로그 내에서에 작동하는 dialogSetState를 구분,
          // 마커나 카테고리 변동이 다이얼로그의 라이프 사이클과 관계없이 적용되도록 함.
            builder: (BuildContext context, StateSetter dialogSetState) {
              return AlertDialog(
                title: Text("메모 추가"),
                content: TextField(
                  maxLines: 5,
                  controller: plainMemo,
                  decoration: const InputDecoration(
                    labelText: "메모",
                    hintText: "메모",
                  ),
                  keyboardType: TextInputType.text,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                      plainMemo.clear();
                    },
                    child: Text("취소"),
                  ),
                  TextButton(
                    onPressed: () {
                      if(plainMemo.text == "") {
                        cannotSendFirebaseToast();
                      }

                      else {
                        // 메모를 firebase firestore로 전송
                        addMemo();

                        setState(() {
                          // 메모의 마커 기능은 일단 보류.
                          /*
                          선택된 날짜에 지출 내역이 없다면 마커 자리를 마련한 후 빨간색 마커를 추가
                          if (!_markers.containsKey(selectedDay)) {
                            _markers[selectedDay] = [];
                          }

                          if (!_markers[selectedDay]!.contains(Colors.red)) {
                            _markers[selectedDay]!.add(Colors.red);
                          }
                        */
                        });

                        // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                        plainMemo.clear();

                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // 입금 내역을 firebase firestore로 전송하는 함수
  void addDeposit() async {
    try {
      await firestore.collection('transactions').doc().set({
        'isDeposit': true,
        'date': Timestamp.fromDate(_selectedDay ?? DateTime.now()), // DateTime -> Timestamp 변환
        'category': selectedCategory.categoryName,
        'place': depositPlace.text,
        'price': int.parse(depositMoney.text), // 문자열 -> 숫자 변환
        'memo': depositMemo.text,
        'userId': auth.currentUser?.email,
      });
    } catch (e) {
      sendErrorToast();
    }
  }

  // 지출 내역을 firebase firestore로 전송하는 함수
  void addWithdraw() async {
    try {
      await firestore.collection('transactions').doc().set({
        'isDeposit': false,
        'date': Timestamp.fromDate(_selectedDay ?? DateTime.now()), // DateTime -> Timestamp 변환
        'category': selectedCategory.categoryName,
        'place': withdrawPlace.text,
        'price': int.parse(withdrawMoney.text), // 문자열 -> 숫자 변환
        'memo': withdrawMemo.text,
        'userId': auth.currentUser?.email,
      });
    } catch (e) {
      sendErrorToast();
    }
  }

  // 메모를 firebase firestore로 전송하는 함수
  void addMemo() async {
    try {
      await firestore.collection('memo').doc().set({
        'date': Timestamp.fromDate(_selectedDay ?? DateTime.now()), // DateTime -> Timestamp 변환
        'memo': plainMemo.text,
        'userId': auth.currentUser?.email,
      });
    } catch (e) {
      sendErrorToast();
    }
  }

  // 입금, 지출 내역 추가시 필요한 정보를 빠트렸을 때 띄울 Toast 함수
  void cannotSendFirebaseToast() {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      msg: '필요한 정보를 모두 작성했는지 확인하세요!',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // 에러 관련 Toast
  void sendErrorToast() {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      msg: '에러 발생',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

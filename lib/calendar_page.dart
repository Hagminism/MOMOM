import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newflutter/model/category_info.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.userId});
  final String userId;

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

  bool _isDataFetched=false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 데이터를 한 번만 가져오기 위해 플래그 사용
    if (!_isDataFetched) {
      _fetchMarkersFromFirestore();
      _isDataFetched = true;
    }
  }

  Future<void> _fetchMarkersFromFirestore() async {
    try {
      final transactionsSnapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: widget.userId)
          .get();

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp?;
        final isDeposit = data['isDeposit'] as bool;
        final memo = data['memo'] as String?;

        if (timestamp != null) {
          // 날짜를 UTC 형식으로 변환
          final date = DateTime.utc(
            timestamp.toDate().year,
            timestamp.toDate().month,
            timestamp.toDate().day,
          );

          // 기존 마커가 없는 경우 초기화
          _markers[date] = _markers[date] ?? [];

          // 입금 마커 추가 (초록색)
          if (isDeposit && !_markers[date]!.contains(Colors.blue)) {
            _markers[date]!.add(Colors.blue);
          }

          // 지출 마커 추가 (빨간색, 중복 방지)
          if (!isDeposit && !_markers[date]!.contains(Colors.red)) {
            _markers[date]!.add(Colors.red);
          }
        }
      }

      final memoSnapshot = await firestore
          .collection('memo')
          .where('userId',isEqualTo : widget.userId)
          .get();

      for (var doc in memoSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp?;
        final memoContent = data['memo'] as String?;

        if (timestamp != null && memoContent != null && memoContent.isNotEmpty) {
          // 날짜를 UTC 형식으로 변환
          final date = DateTime.utc(
            timestamp.toDate().year,
            timestamp.toDate().month,
            timestamp.toDate().day,
          );

          // 기존 마커가 없는 경우 초기화
          _markers[date] = _markers[date] ?? [];

          // 메모 마커 추가 (노란색, 중복 방지)
          if (!_markers[date]!.contains(Colors.yellow)) {
            _markers[date]!.add(Colors.yellow);
          }
        }
      }

      // 상태 갱신
      setState(() {
        // UI 업데이트
      });

      print("Firestore 데이터 처리 완료: $_markers");
    } catch (e) {
      print('Error fetching markers: $e');
    }
  }


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
        locale: 'ko_KR',
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
            // 캘린더에 마커 렌더링
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
      locale: const Locale('ko', 'KR'),
      context: context,
      initialDate: focusedDay,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year, // 연도와 월을 선택할 수 있도록 설정
    );

    if (pickedDate != null) {
      setState(() {
        _focusedDay = pickedDate; // 선택한 날짜로 이동
        _selectedDay = pickedDate;
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

  // 날짜를 탭했을 때 띄울 내역 및 메모 목록
  void showScheduleList(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchSchedules(),
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다.'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('해당 날짜에 데이터가 없습니다.'));
              }

              final schedules = snapshot.data!;
              return SizedBox(
                width: 50,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: schedules.map((schedule) {
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: schedule['color'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (schedule['type'] == '입금 내역') {
                              showEditDepositDialog(context, schedule);
                            } else if (schedule['type'] == '지출 내역') {
                              showEditWithdrawDialog(context, schedule);
                            } else if (schedule['type'] == '일반 메모') {
                              showEditMemoDialog(context, schedule);
                            }
                          },
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: schedule['color'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(schedule['type'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('날짜: ${schedule['date'].toString().substring(0, 10)}', style: TextStyle(fontSize: 14)),
                                if (schedule['type'] == '입금 내역' || schedule['type'] == '지출 내역') ...[
                                  Text('장소: ${schedule['place']}', style: TextStyle(fontSize: 14)),
                                  Text('금액: ${schedule['price']}원', style: TextStyle(fontSize: 14)),
                                  Text('카테고리: ${schedule['category']}', style: TextStyle(fontSize: 14)),
                                  Text('메모: ${schedule['memo']}', style: TextStyle(fontSize: 14)),
                                ] else if (schedule['type'] == '일반 메모') ...[
                                  Text('내용: ${schedule['content']}', style: TextStyle(fontSize: 14)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showEditDepositDialog(BuildContext context, Map<String, dynamic> schedule) {
    depositPlace.text = schedule['place'];
    depositMoney.text = schedule['price'].toString();
    depositMemo.text = schedule['memo'];

    // 기존 카테고리를 불러와 초기값으로 설정
    selectedCategory = category.firstWhere((e) => e.categoryName == schedule['category'], orElse: () => category[0]);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("입금 내역 수정"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: depositPlace,
                    decoration: const InputDecoration(
                      labelText: "입금처",
                      hintText: "입금처",
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
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
                      Text("카테고리 선택", style: TextStyle(fontSize: 15)),
                      DropdownButton<CategoryType>(
                        value: selectedCategory,
                        items: category.map((e) {
                          return DropdownMenuItem<CategoryType>(
                            value: e,
                            child: Text(e.categoryName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    depositPlace.clear();
                    depositMoney.clear();
                    depositMemo.clear();
                  },
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    if (depositPlace.text.isEmpty || depositMoney.text.isEmpty || depositMemo.text.isEmpty) {
                      cannotSendFirebaseToast();
                    } else {
                      updateDeposit(schedule['id']);
                      Navigator.of(context).pop();

                      depositPlace.clear();
                      depositMoney.clear();
                      depositMemo.clear();

                      showScheduleList(context);
                    }
                  },
                  child: Text("수정"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void showEditWithdrawDialog(BuildContext context, Map<String, dynamic> schedule) {
    withdrawPlace.text = schedule['place'];
    withdrawMoney.text = schedule['price'].toString();
    withdrawMemo.text = schedule['memo'];

    // 기존 카테고리를 불러와 초기값으로 설정
    selectedCategory = category.firstWhere((e) => e.categoryName == schedule['category'], orElse: () => category[0]);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("지출 내역 수정"),
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
                      Text("카테고리 선택", style: TextStyle(fontSize: 15)),
                      DropdownButton<CategoryType>(
                        value: selectedCategory,
                        items: category.map((e) {
                          return DropdownMenuItem<CategoryType>(
                            value: e,
                            child: Text(e.categoryName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    withdrawPlace.clear();
                    withdrawMoney.clear();
                    withdrawMemo.clear();
                  },
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    if (withdrawPlace.text.isEmpty || withdrawMoney.text.isEmpty || withdrawMemo.text.isEmpty) {
                      cannotSendFirebaseToast();
                    } else {
                      updateWithdraw(schedule['id']);
                      Navigator.of(context).pop();

                      withdrawPlace.clear();
                      withdrawMoney.clear();
                      withdrawMemo.clear();
                    }
                  },
                  child: Text("수정"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void showEditMemoDialog(BuildContext context, Map<String, dynamic> schedule) {
    plainMemo.text = schedule['content']; // 일반 메모의 내용 불러오기

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("일반 메모 수정"),
          content: TextField(
            maxLines: 5,
            controller: plainMemo,
            decoration: const InputDecoration(
              labelText: "메모",
              hintText: "메모를 입력하세요",
            ),
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                plainMemo.clear();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                if (plainMemo.text == "") {
                  cannotSendFirebaseToast();
                } else {
                  updateMemo(schedule['id']); // 메모 수정 함수 호출
                  Navigator.of(context).pop();
                  plainMemo.clear();
                }
              },
              child: Text("수정"),
            ),
          ],
        );
      },
    );
  }


  void updateDeposit(String id) async {
    try {
      await firestore.collection('transactions').doc(id).update({
        'place': depositPlace.text,
        'price': int.parse(depositMoney.text),
        'memo': depositMemo.text,
        'category': selectedCategory.categoryName, // 수정된 카테고리 저장
      });
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        msg: '입금 내역이 수정되었습니다!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      sendErrorToast();
    }
  }

  void updateWithdraw(String id) async {
    try {
      await firestore.collection('transactions').doc(id).update({
        'place': withdrawPlace.text,
        'price': int.parse(withdrawMoney.text),
        'memo': withdrawMemo.text,
        'category': selectedCategory.categoryName, // 수정된 카테고리 저장
      });
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        msg: '지출 내역이 수정되었습니다!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      sendErrorToast();
    }
  }


  void updateMemo(String id) async {
    try {
      await firestore.collection('memo').doc(id).update({
        'memo': plainMemo.text, // 올바른 필드 이름으로 수정
      });
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        msg: '메모가 수정되었습니다!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      sendErrorToast();
    }
  }



  // 특정 날짜의 내역과 메모를 모두 가져와 정렬하는 함수
  Future<List<Map<String, dynamic>>> _fetchSchedules() async {
    final String userId = auth.currentUser?.email ?? '';

    // 선택한 날짜의 시작과 끝 시간 계산 (UTC 기준)
    final DateTime startOfDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    try {
      // Firestore에서 transactions 데이터 가져오기
      final QuerySnapshot transactionsSnapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Firestore에서 memo 데이터 가져오기
      final QuerySnapshot memoSnapshot = await firestore
          .collection('memo')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay.toUtc()))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay.toUtc()))
          .get();

      // transactions 데이터 변환
      final List<Map<String, dynamic>> transactions = transactionsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // 문서 ID 추가
          'type': data['isDeposit'] == true ? '입금 내역' : '지출 내역',
          'date': (data['date'] as Timestamp).toDate().add(const Duration(hours: 9)), // UTC+9로 변환
          'place': data['place'] ?? '정보 없음',
          'price': data['price'] ?? 0,
          'memo': data['memo'] ?? '메모 없음',
          'category': data['category'] ?? '카테고리 없음',
          'color': data['isDeposit'] == true ? Colors.blue[100] : Colors.red[100],
        };
      }).toList();

      // memo 데이터 변환
      final List<Map<String, dynamic>> memos = memoSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // 문서 ID 추가
          'type': '일반 메모',
          'date': (data['date'] as Timestamp).toDate().add(const Duration(hours: 9)), // UTC+9로 변환
          'content': data['memo'] ?? '메모 없음',
          'color': Colors.orange[100],
        };
      }).toList();

      // 모든 데이터를 합치고 날짜 기준으로 정렬
      final List<Map<String, dynamic>> combined = [...transactions, ...memos];
      combined.sort((a, b) {
        final DateTime dateA = a['date'];
        final DateTime dateB = b['date'];
        return dateA.compareTo(dateB);
      });

      return combined;
    } catch (e) {
      print('Error fetching schedules: $e');
      return [];
    }
  }

  DateTime adjustToKoreanTimeZone(DateTime date) {
    return date.add(const Duration(hours: 9));
  }

  // 입금 내역 추가 dialog
  void showDepositDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 카테고리 선택시 변동 사항이 즉시 반영되도록 StatefulBuilder 사용.

          // setState 사용시 마커가 다이얼로그 종료 후 찍히거나 카테고리 변동 사항이 늦게 반영되는 오류 발생.
          // 따라서 다이얼로그 위젯 외부에 작동하는 setState와 다이얼로그 내에서에 작동하는 dialogSetState를 구분,
          // 마커나 카테고리 변동이 다이얼로그의 라이프 사이클과 관계없이 적용되도록 함.

            builder: (BuildContext context, StateSetter dialogSetState) {
              return AlertDialog(
                title: Text(
                  "입금 내역 추가",
                  style: TextStyle(
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: depositPlace,
                      decoration: const InputDecoration(
                        labelText: "입금처",
                        hintText: "입금처",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      style: TextStyle(
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
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: DropdownButton(
                            style: TextStyle(
                              color: Colors.black,
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

                        // 입금 내역이 추가되었다는 Toast 등장
                        addDepositToast();
                      }
                    },
                    child: Text(
                      "확인",
                      style: TextStyle(
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
      barrierDismissible: false,
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
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: DropdownButton(
                            style: TextStyle(
                              color: Colors.black,
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

                        // 지출 내역이 추가되었다는 Toast 등장
                        addWithdrawToast();
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
      barrierDismissible: false,
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
                          if (!_markers.containsKey(selectedDay)) {
                            _markers[selectedDay] = [];
                          }

                          if (!_markers[selectedDay]!.contains(Colors.yellow)) {
                            _markers[selectedDay]!.add(Colors.yellow);
                          }
                        });

                        // 다이얼로그가 다시 팝업되었을 때 이전 값을 보여주지 않도록 함
                        plainMemo.clear();

                        Navigator.of(context).pop();

                        // 메모가 추가되었다는 Toast 등장
                        addMemoToast();
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

  // 입금 내역을 추가했을 때 띄울 Toast 함수
  void addDepositToast() {
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      msg: '입금 내역이 추가되었습니다!',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // 지출 내역을 추가했을 때 띄울 Toast 함수
  void addWithdrawToast() {
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      msg: '지출 내역이 추가되었습니다!',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // 메모를 추가했을 때 띄울 Toast 함수
  void addMemoToast() {
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      msg: '메모가 추가되었습니다!',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

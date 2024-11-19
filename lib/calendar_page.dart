import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Map<DateTime, List<Color>> _markers = {}; // 날짜별 여러 마커를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 관리'),
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

  void showOptions(BuildContext context, DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.event),
              title: Text('입금 내역 추가'),
              onTap: () {
                Navigator.pop(context);
                showDepositDialog(context, selectedDay);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('출금 내역 추가'),
              onTap: () {
                Navigator.pop(context);
                showWithdrawDialog(context, selectedDay);
              },
            ),
          ],
        );
      },
    );
  }

  //
  void showScheduleList(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FutureBuilder<QuerySnapshot>( // 비동기 작업을 Build
            future: FirebaseFirestore.instance.collection('users').get(), // 할 작업 : users 컬렉션 읽기

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
        return AlertDialog(
          title: Text("입금 내역 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(
                  labelText: "입금처",
                  hintText: "입금처",
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "입금 금액",
                  hintText: "입금 금액",
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "메모",
                  hintText: "메모",
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // 선택된 날짜에 입금 내역이 없다면 마커 자리를 마련한 후 파란색 마커를 추가
                  if (!_markers.containsKey(selectedDay)) {
                    _markers[selectedDay] = [];
                  }

                  if (!_markers[selectedDay]!.contains(Colors.blue)) {
                    _markers[selectedDay]!.add(Colors.blue);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 지출 내역 추가 dialog
  void showWithdrawDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("지출 내역 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(
                  labelText: "지출처",
                  hintText: "지출처",
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "지출 금액",
                  hintText: "지출 금액",
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "메모",
                  hintText: "메모",
                ),
                keyboardType: TextInputType.text,
              ),
            ],

          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // 선택된 날짜에 지출 내역이 없다면 마커 자리를 마련한 후 빨간색 마커를 추가
                  if (!_markers.containsKey(selectedDay)) {
                    _markers[selectedDay] = [];
                  }

                  if (!_markers[selectedDay]!.contains(Colors.red)) {
                    _markers[selectedDay]!.add(Colors.red);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }
}

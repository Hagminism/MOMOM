import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/category_info.dart';
import '../model/finance_info.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryType; // 카테고리 이름
  final String userId; // 사용자 ID
  final String selectedMonth; // 선택된 월

  const CategoryDetailPage({
    Key? key,
    required this.categoryType,
    required this.userId,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<FinanceInfo> financeList = [];
  late CategoryType category; // CategoryType 변수를 클래스 상태로 저장

  @override
  void initState() {
    super.initState();
    category = CategoryType.values.firstWhere(
          (e) => e.categoryName == widget.categoryType,
    );
    _fetchFinanceData();
  }

  Future<void> _fetchFinanceData() async {
    // 선택된 월의 시작 및 종료 날짜 계산
    DateTime startDate = DateTime(
      int.parse(widget.selectedMonth.split('-')[0]),
      int.parse(widget.selectedMonth.split('-')[1]),
      1,
    );

    DateTime endDate = DateTime(
      startDate.year,
      startDate.month + 1,
      1,
    );
    // Firestore에서 데이터 가져오기
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: widget.userId)
        .where('category', isEqualTo: widget.categoryType)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .where('isDeposit', isEqualTo: false) // isDeposit이 true인 데이터만 가져오기
        .orderBy('date', descending: true)
        .get();

    setState(() {
      financeList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; // doc.data()를 Map으로 캐스팅
        return FinanceInfo(
          categoryType: category,
          price: data['price'], // 데이터 접근
          date: (data['date'] as Timestamp).toDate(), // Timestamp를 DateTime으로 변환
          place: data.containsKey('place') ? data['place'] : '페이먼트 장소', // place 속성 확인 후 기본값 설정
        );
      }).toList();
    });
  }

  Map<DateTime, List<FinanceInfo>> _groupByDate(List<FinanceInfo> financeList) {
    Map<DateTime, List<FinanceInfo>> groupedData = {};
    for (var finance in financeList) {
      DateTime date = DateTime(finance.date.year, finance.date.month, finance.date.day);
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(finance);
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    // 총 금액 및 회수 수치
    int totalAmount = financeList.fold(0, (sum, item) => sum + item.price);
    int totalCount = financeList.length;

    // 날짜별로 그룹화
    Map<DateTime, List<FinanceInfo>> groupedFinance = _groupByDate(financeList);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.categoryType), // 카테고리 이름 표시
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 정보 표시
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '총 금액',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalAmount 원',
                          style: const TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '총 $totalCount 회',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 오른쪽 아이콘 (예시)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon, // 카테고리 타입의 아이콘 사용
                      color: Colors.blue.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // 소비 내역 리스트
            Container(
              padding: const EdgeInsets.all(24.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupedFinance.keys.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  DateTime dateKey = groupedFinance.keys.elementAt(index);
                  List<FinanceInfo> dailyFinances = groupedFinance[dateKey]!;

                  String dateString = '${dateKey.month}월 ${dateKey.day}일 ${_getDayOfWeek(dateKey)}요일';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateString,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color:Colors.black),
                      ),
                      ...dailyFinances.map((finance) => _accountItem(finance)).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[date.weekday % 7];
  }

  Widget _accountItem(FinanceInfo financeInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: financeInfo.categoryType.backgroundColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${financeInfo.price} 원',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  '${financeInfo.place}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

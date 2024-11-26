import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newflutter/categoryDetail_page.dart';
import '../model/category_info.dart';

class CategoryPage extends StatefulWidget {
  final String userId;
  const CategoryPage({super.key, required this.userId});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  DateTime selectedDate = DateTime.now(); // 선택된 날짜
  late String monthKey; // "YYYY-MM" 형식의 키

  @override
  void initState() {
    super.initState();
    monthKey = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
  }

  void _changeMonth(int offset) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset);
      monthKey = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: const Text(
              '월별 소비',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 월 선택 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, size: 50),
                  onPressed: () => _changeMonth(-1),
                ),
                SizedBox(width: 16),
                Text(
                  '${selectedDate.year}년 ${selectedDate.month}월',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.arrow_right, size: 50),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          // 거래 내역 표시
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('userId', isEqualTo: widget.userId)
                  .where('isDeposit', isEqualTo:false)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('입출금 정보가 없습니다.'));
                }

                // 월별로 데이터 분류
                Map<String, List<DocumentSnapshot>> monthlyData = {};
                int totalAmount = 0; // 전체 지출 금액 초기화

                for (var doc in snapshot.data!.docs) {
                  Timestamp timestamp = doc['date'];
                  DateTime date = timestamp.toDate();
                  String monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

                  if (!monthlyData.containsKey(monthKey)) {
                    monthlyData[monthKey] = [];
                  }
                  monthlyData[monthKey]!.add(doc);

                  if(monthKey==this.monthKey){
                    int price =(doc['price'] as num).toInt();
                    totalAmount += price;
                  }
                }

                // 선택된 월에 해당하는 거래 내역만 필터링
                List<DocumentSnapshot> transactions = monthlyData[monthKey] ?? [];

                // 각 카테고리의 총 금액 계산
                Map<String, int> categoryTotals = {};
                for (var doc in transactions) {
                  String category = doc['category'];
                  int price = (doc['price'] as num).toInt();

                  if (!categoryTotals.containsKey(category)) {
                    categoryTotals[category] = 0;
                  }
                  categoryTotals[category] = categoryTotals[category]! + price;
                }

                // 카테고리 총 금액을 기준으로 정렬
                var sortedCategories = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)); // 내림차순 정렬

                return Column(
                  children: [
                    // 카테고리 소비 비율 바
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 20,
                              decoration : BoxDecoration(
                                color: Colors.grey[300], // 기본 막대 배경색
                                //borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: sortedCategories.map((entry) {
                                  String category = entry.key;
                                  int categoryAmount = entry.value;
                                  double percentage = (totalAmount > 0) ? (categoryAmount / totalAmount) * 100 : 0;
                                  Color categoryColor = CategoryType.values.firstWhere((e) => e.categoryName == category).backgroundColor;

                                  return Expanded(
                                    flex : (percentage*100).toInt(),
                                    child:Container(
                                      height:20,
                                      color:categoryColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 거래 내역 리스트
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: sortedCategories.length,
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
                        itemBuilder: (BuildContext context, int index) {
                          var entry = sortedCategories[index];
                          String category = entry.key;
                          int categoryAmount = entry.value;

                          // 전체 지출 금액 대비 비율 계산
                          double percentage = (totalAmount > 0) ? (categoryAmount / totalAmount) * 100 : 0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailPage(
                                    categoryType: category,
                                    userId: widget.userId,
                                    selectedMonth: monthKey,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            CategoryType.values.firstWhere((e) => e.categoryName == category).icon,
                                            color: Colors.blue.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category,
                                            style: const TextStyle(color: Colors.black, fontSize: 18),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${percentage.toStringAsFixed(1)}%',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // 오른쪽에 금액 표시
                                  Text(
                                    '${categoryAmount} 원', // 카테고리 금액과 비율 표시
                                    style: const TextStyle(color: Colors.black, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

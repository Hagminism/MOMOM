import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/category_info.dart';
import '../model/finance_info.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName; // 카테고리 이름
  final String userId; // 사용자 ID

  const CategoryDetailPage({Key? key, required this.categoryName, required this.userId}) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<FinanceInfo> financeList = [];

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
  }

  Future<void> _fetchFinanceData() async {
    // Firestore에서 데이터 가져오기
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: widget.userId)
        .where('category', isEqualTo: widget.categoryName)
        .orderBy('date') // 날짜별로 정렬
        .get(GetOptions(source: Source.cache)); // 로컬 캐시에서 데이터 가져오기
    setState(() {
      financeList = snapshot.docs.map((doc) {
        return FinanceInfo(
          categoryType: CategoryType.FOOD, // 실제 카테고리 타입으로 변경 필요
          price: '${doc['price']}원',
        );
      }).toList();
    });
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
                child: Center(child: Text(financeInfo.categoryType.logoImg)),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  financeInfo.price,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  '원래 페이먼드 장소 | 원래 페이먼트 방법 있던 곳',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 총 금액 및 회수 수치
    int totalAmount = financeList.fold(0, (sum, item) => sum + int.parse(item.price.replaceAll(',', '').replaceAll('원', '')));
    int totalCount = financeList.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.categoryName), // 카테고리 이름 표시
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
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white),
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
                itemCount: financeList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _accountItem(financeList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newflutter/categoryDetail_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 로그인한 사용자의 ID
    final String userId = "junho087387@gmail.com"; // 실제 사용자 ID로 변경

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: const Text(
              '카테고리별 소비',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .get(GetOptions(source: Source.cache)), // 로컬 캐시에서 데이터 가져오기
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('입출금 정보가 없습니다.'));
          }

          // 카테고리별로 데이터 분류
          Map<String, List<DocumentSnapshot>> categorizedData = {};

          for (var doc in snapshot.data!.docs) {
            String category = doc['category'];
            if (!categorizedData.containsKey(category)) {
              categorizedData[category] = [];
            }
            categorizedData[category]!.add(doc);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: categorizedData.keys.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
            itemBuilder: (BuildContext context, int index) {
              String category = categorizedData.keys.elementAt(index);
              List<DocumentSnapshot> transactions = categorizedData[category]!;

              // 카테고리별 거래 총액 계산
              int totalAmount = transactions.fold(0, (sum, doc) => sum + (doc['price'] as int));

              return GestureDetector(
                onTap: () {
                  // CategoryDetailPage로 이동하며 카테고리 이름 전달
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(categoryName: category, userId: userId),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10), // 클릭 가능한 높이 설정
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent), // 클릭 영역을 위한 투명한 테두리
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            // 카테고리에 따라 아이콘 설정
                            category == '식비' ? Icons.fastfood :
                            category == '쇼핑' ? Icons.shopping_cart :
                            category == '이체' ? Icons.account_balance_wallet :
                            category == '교통비' ? Icons.train :
                            Icons.more_horiz,
                            color: Colors.blue.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category, // 카테고리 이름
                              style: const TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            // 총액 표시
                            Text(
                              '$totalAmount 원', // 카테고리 총액
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

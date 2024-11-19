import 'package:flutter/material.dart';
import 'package:newflutter/categoryDetail_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

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
              '카테고리별 소비',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 총액 및 프로그래스 바
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
              children: [
                // 이전 월 버튼
                IconButton(
                  icon: const Icon(Icons.arrow_left, color: Colors.black),
                  onPressed: () {
                    // 이전 월로 이동하는 로직 추가
                  },
                ),
                // 월 및 금액 표시
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
                  children: const [
                    Text(
                      '11월',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '521,170원',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // 다음 월 버튼
                IconButton(
                  icon: const Icon(Icons.arrow_right, color: Colors.black),
                  onPressed: () {
                    // 다음 월로 이동하는 로직 추가
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 프로그래스 바
          Container(
            height: 15, // 높이를 키움
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.66, // 이체 비율
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: 6,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    //CategoryDetailPage로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context)=>const CategoryDetailPage()),
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
                              index == 0
                                  ? Icons.account_balance_wallet
                                  : index == 1
                                  ? Icons.shopping_cart
                                  : index == 2
                                  ? Icons.fastfood
                                  : Icons.more_horiz,
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
                                index == 0 ? '이체' : index == 1 ? '쇼핑' : index == 2 ? '식비' : '기타',
                                style: const TextStyle(color: Colors.black, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              // 퍼센트 표시
                              Text(
                                index == 0 ? '66.1%' : index == 1 ? '10.5%' : index == 2 ? '7.6%' : '4.5%',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        // 가격 표시
                        Text(
                          index == 0 ? '344,180원' : index == 1 ? '55,000원' : index == 2 ? '40,000원' : '23,500원',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

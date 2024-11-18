import 'package:flutter/material.dart';
import '../model/finance_info.dart';
import '../model/category_info.dart';

enum BlockType { TODAY, YESTERDAY }

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({Key? key}) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<FinanceInfo> todayList = [
    FinanceInfo(categoryType: CategoryType.FOOD, price: '-43,300원', paymentPlace: 'T머니', paymentMethod: '나라사랑카드'),
    FinanceInfo(categoryType: CategoryType.FOOD, price: '-3,000원', paymentPlace: 'SWING', paymentMethod: 'SW_PAYG'),
  ];

  List<FinanceInfo> yesterdayList = [
    FinanceInfo(categoryType: CategoryType.FOOD, price: '-1,080원', paymentPlace: 'SWING', paymentMethod: 'SW_PAYG'),
    FinanceInfo(categoryType: CategoryType.FOOD, price: '-920원', paymentPlace: 'SWING', paymentMethod: 'SW_PAYG'),
  ];

  Widget _accountItem(BlockType blockType, FinanceInfo financeInfo) {
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
              blockType == BlockType.TODAY
                  ? Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  child: const Center(
                      child: Icon(Icons.star, color: Colors.white, size: 8)),
                  decoration: const BoxDecoration(
                      color: Colors.lightBlue, shape: BoxShape.circle),
                ),
              )
                  : const SizedBox(),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  financeInfo.price,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${financeInfo.paymentPlace} ${financeInfo.paymentMethod}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountList({required BlockType blockType, required List<FinanceInfo> list}) {
    String title = '';
    switch (blockType) {
      case BlockType.TODAY:
        title = '11월 19일';
        break;
      case BlockType.YESTERDAY:
        title = '11월 18일';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(list.length, (index) => _accountItem(blockType, list[index])),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 총 금액 및 회수 수치
    int totalAmount = todayList.fold(0, (sum, item) => sum + int.parse(item.price.replaceAll(',', '').replaceAll('원', '')));
    int totalCount = todayList.length + yesterdayList.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('소비 카테고리'),
        backgroundColor: Colors.black,
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
                  // 왼쪽 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '2024년 10월 교통·자동차 총 금액',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalAmount 원',
                          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
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
                  // 오른쪽 아이콘
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.white),
                  ),
                ],
              ),
            ),
            // 오늘과 어제의 지출 내역
            _accountList(list: todayList, blockType: BlockType.TODAY),
            _accountList(list: yesterdayList, blockType: BlockType.YESTERDAY),
          ],
        ),
      ),
    );
  }
}

import '../model/category_info.dart';

class FinanceInfo {
  final CategoryType categoryType;
  final int price;
  final DateTime date;

  FinanceInfo({
    required this.categoryType,
    required this.price,
    required this.date,
  });
}
import '../model/category_info.dart';

class FinanceInfo {
  final CategoryType categoryType;
  final int price;
  final DateTime date;
  final String place;

  FinanceInfo({
    required this.categoryType,
    required this.price,
    required this.date,
    required this.place,
  });
}
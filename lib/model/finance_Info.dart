import '../model/category_info.dart';

class FinanceInfo {
  final CategoryType categoryType;
  final String price;
  final String paymentPlace;
  final String paymentMethod;

  FinanceInfo({
    required this.categoryType,
    required this.price,
    required this.paymentPlace,
    required this.paymentMethod,
  });
}

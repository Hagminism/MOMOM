import 'package:flutter/material.dart';

enum CategoryType { TRANSPORT, FOOD, ENTERTAINMENT, UTILITIES }

extension ParseToCategoryType on CategoryType {
  String get categoryName {
    switch (this) {
      case CategoryType.TRANSPORT:
        return '교통비';
      case CategoryType.FOOD:
        return '식비';
      case CategoryType.ENTERTAINMENT:
        return '오락';
      case CategoryType.UTILITIES:
        return '공과금';
      default:
        return '';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CategoryType.TRANSPORT:
        return const Color.fromARGB(255, 0, 71, 254);
      case CategoryType.FOOD:
        return const Color.fromARGB(255, 17, 35, 98);
      case CategoryType.ENTERTAINMENT:
        return const Color.fromARGB(255, 75, 143, 232);
      case CategoryType.UTILITIES:
        return const Color.fromARGB(255, 241, 213, 72);
      default:
        return Colors.white;
    }
  }

  String get logoImg {
    switch (this) {
      case CategoryType.TRANSPORT:
        return 'TP';
      case CategoryType.FOOD:
        return 'FD';
      case CategoryType.ENTERTAINMENT:
        return 'EM';
      case CategoryType.UTILITIES:
        return 'UT';
      default:
        return '';
    }
  }
}

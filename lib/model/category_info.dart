import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CategoryType {
  TRANSPORT,                  //교통비
  FOOD,                       //식비
  CAFE,                       //카페, 간식
  STORE,                      //편의점, 마트
  ENTERTAINMENT,              //유흥
  SHOPPING,                   //쇼핑
  HOBBY,                      //취미
  HEALTH,                     //건강
  TAX,                        //보험, 세금
  BEAUTY,                     //미용
  EDUCATION,                  //교육
  LIVING,                     //생활비(통신, 주거)
  DONATION,                   //기부
  SAVING,                     //저축
}

extension ParseToCategoryType on CategoryType {
  String get categoryName {
    switch (this) {
      case CategoryType.TRANSPORT:
        return '교통비';
      case CategoryType.FOOD:
        return '식비';
      case CategoryType.CAFE:
        return '카페ㆍ간식';
      case CategoryType.STORE:
        return '편의점ㆍ마트';
      case CategoryType.ENTERTAINMENT:
        return '오락';
      case CategoryType.SHOPPING:
        return '쇼핑';
      case CategoryType.HOBBY:
        return '취미';
      case CategoryType.HEALTH:
        return '건강';
      case CategoryType.TAX:
        return '보험ㆍ세금';
      case CategoryType.BEAUTY:
        return '미용';
      case CategoryType.EDUCATION:
        return '교육';
      case CategoryType.LIVING:
        return '교육';
      case CategoryType.DONATION:
        return '기부';
      case CategoryType.SAVING:
        return '저축';

      default:
        return '카레고리 없음';
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
      default:
        return Colors.white;
    }
  }

  IconData get icon{
    switch(this){
      case CategoryType.TRANSPORT:
        return Icons.train;
      case CategoryType.FOOD:
        return Icons.fastfood;

      case CategoryType.CAFE:
        return Icons.coffee;
      case CategoryType.STORE:
        return Icons.storefront;
      case CategoryType.ENTERTAINMENT:
        return Icons.videogame_asset_rounded;
      case CategoryType.SHOPPING:
        return Icons.shopping_cart;
      case CategoryType.HOBBY:
        return Icons.local_fire_department;
      case CategoryType.HEALTH:
        return Icons.health_and_safety_outlined;
      case CategoryType.TAX:
        return Icons.monetization_on_outlined;
      case CategoryType.BEAUTY:
        return Icons.face;
      case CategoryType.EDUCATION:
        return Icons.book;
      case CategoryType.LIVING:
        return Icons.house;
      case CategoryType.DONATION:
        return Icons.assistant;
      case CategoryType.SAVING:
        return Icons.savings_outlined;

      default:
        return Icons.no_adult_content;
    }
  }
}

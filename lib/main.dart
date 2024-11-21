import 'package:flutter/material.dart';
import 'package:newflutter/analysis_page.dart';
import 'package:newflutter/categoryDetail_page.dart';
import 'package:newflutter/category_page.dart';
import 'package:newflutter/main_page.dart';
import 'package:newflutter/mypage_page.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // 앱 시작 시 로그인 페이지로 이동
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/main':
            final args = settings.arguments as Map<String, dynamic>; // 매개변수 받을 준비
            return MaterialPageRoute(
              builder: (context) => MainPage(userId: args['userId']), // userId 전달
            );
          case '/category':
            final args = settings.arguments as Map<String, dynamic>; // 매개변수 받을 준비
            return MaterialPageRoute(
              builder: (context) => CategoryPage(userId: args['userId']), // userId 전달
            );
          case '/categoryDetail':
            final args = settings.arguments as Map<String, dynamic>; // 매개변수 받을 준비
            return MaterialPageRoute(
              builder: (context) => CategoryDetailPage(
                categoryType: args['categoryName'],
                userId: args['userId'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

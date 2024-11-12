import 'package:flutter/material.dart';
import 'package:newflutter/category_page.dart';
import 'package:newflutter/main_page.dart';
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
      routes: {
        '/': (context) => LoginPage(),  // 로그인 페이지
        //'/main': (context) => MainPage(),  // 로그인 후 메인 페이지로 이동
        //'/category': (context) => CategoryPage(),  // 카테고리 페이지
      },
    );
  }
}
/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Text('안녕'),
      ),
    );
  }
}
*/
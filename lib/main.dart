import 'package:flutter/material.dart';
import 'package:newflutter/analysis_page.dart';
import 'package:newflutter/categoryDetail_page.dart';
import 'package:newflutter/category_page.dart';
import 'package:newflutter/main_page.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 자신에게 필요한 언어 locale을 모두 추가
      supportedLocales: [
        Locale('en'), // 영어
        Locale('ko'), // 한국어
      ],
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
                selectedMonth: args['selectedMonth'],
              ),
            );
          case '/analysis':  // 분석 페이지 라우트 추가
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AnalysisPage(userId: args['userId']),
            );
          default:
            return null;
        }
      },
    );
  }
}

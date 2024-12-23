import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'mypage_page.dart';
import 'analysis_page.dart';
import 'category_page.dart';

class MainPage extends StatefulWidget {
  final String userId;

  const MainPage({super.key, required this.userId});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 네비게이션 바에서 전환할 페이지 리스트
  late final List<Widget> _pages; // late로 선언하여 나중에 초기화

  @override
  void initState() {
    super.initState();
    // userId를 CategoryPage에 전달
    _pages = [
      CalendarPage(userId: widget.userId),
      AnalysisPage(userId: widget.userId),
      CategoryPage(userId: widget.userId), // userId 전달
      MyPageScreen(), // 추가된 페이지
    ];
  }

  // 네비게이션 아이템 클릭 시 호출
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 선택된 페이지를 표시
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 0.5, right: 0.5, top: 0.5),
          color: Colors.white24,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(color: Colors.grey),
            unselectedItemColor: Colors.black,
            unselectedLabelStyle: const TextStyle(color: Colors.black),
            currentIndex: _selectedIndex, // 고정값 0 대신 _selectedIndex 사용
            onTap: _onItemTapped, // 클릭 시 인덱스 업데이트
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
              BottomNavigationBarItem(icon: Icon(Icons.category), label: '카테고리'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
            ],
          ),
        ),
      ),
    );
  }
}

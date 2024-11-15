import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("마이페이지", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // 프로필 사진, 이름, 이메일 부분
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    "https://via.placeholder.com/150", // 프로필 이미지 URL
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "카리나 님",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("katarinabluu@aespa.com", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // '나의 메뉴' 텍스트
                    Text(
                      "나의 메뉴",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // 메뉴 버튼들
                    MenuItem(
                      text: "월 예산 설정",
                      onTap: () {
                        showBudgetDialog(context);
                      },
                    ),
                    MenuItem(
                      text: "계정 설정",
                      onTap: () {
                        showAccountSettingsDialog(context);
                      },
                    ),
                    MenuItem(
                      text: "회원 탈퇴",
                      onTap: () {
                        showDeleteAccountDialog(context);
                      },
                    ),
                    MenuItem(text: "로그아웃", onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "통계"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "카테고리"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
        ],
        currentIndex: 3,
        onTap: (index) {
          // 네비게이션 아이템 클릭 시 동작 추가 가능
        },
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  MenuItem({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

void showBudgetDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("월 예산 설정"),
        content: TextField(
          decoration: InputDecoration(labelText: "월 예산"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

void showAccountSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("계정 설정"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "변경할 사용자 이름",
                hintText: "이름",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "변경할 패스워드",
                hintText: "패스워드",
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "패스워드 확인",
                hintText: "패스워드 확인",
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

void showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("회원 탈퇴"),
        content: Text("정말로 회원 탈퇴를 하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              // 여기서 회원 탈퇴 로직 추가
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

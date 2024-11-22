import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 숫자 입력 제한을 위한 패키지
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';

 Firebase 인증(Authentication) 객체
 late 선언하면 로그아웃 -> 재로그인 -> 다시 로그아웃시,
 auth 객체가 이미 존재하는 상태에서 late 상태로 선언을 한 번 더 하게 되면서 중복이 발생.
final FirebaseAuth auth = FirebaseAuth.instance;

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
                padding: EdgeInsets.all(40),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // '나의 메뉴' 텍스트
                    Text(
                      "나의 메뉴",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
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
                    MenuItem(text: "로그아웃", onTap: () { showSignOutDialog(context); }),
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 허용
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

void showAccountSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("계정 설정"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showChangeNameDialog(context);
              },
              child: Text("이름 변경"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showChangePasswordDialog(context);
              },
              child: Text("비밀번호 변경"),
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
        ],
      );
    },
  );
}

void showChangeNameDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("이름 변경"),
        content: TextField(
          decoration: InputDecoration(
            labelText: "변경할 사용자 이름",
            hintText: "이름",
          ),
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
              // 이름 변경 로직 추가
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

void showChangePasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("비밀번호 변경"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "변경할 비밀번호",
                hintText: "비밀번호",
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "비밀번호 확인",
                hintText: "비밀번호 확인",
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
              // 비밀번호 변경 로직 추가
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
              deleteUser(context);
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

void showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("로그아웃"),
        content: Text("정말로 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              signOut(context);
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

void signOut(BuildContext context) {
  auth.signOut(); // 로그아웃 진행

  // 메인 페이지로 이동하면서 백스택 제거
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => LoginPage(),
    ),(route) => false,
  );

  // 로그아웃 되었다는 내용의 Toast 생성
  signOutToast();
}

// 로그아웃시 띄울 Toast 함수
void signOutToast() {
  Fluttertoast.showToast(
    msg: '로그아웃되었습니다.',
    gravity: ToastGravity.BOTTOM,
    toastLength: Toast.LENGTH_SHORT,
  );
}

void deleteUser(BuildContext context) {
  auth.currentUser?.delete(); // 로그아웃 진행

  // 메인 페이지로 이동하면서 백스택 제거
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => LoginPage(),
    ),(route) => false,
  );

  // 로그아웃 되었다는 내용의 Toast 생성
  deleteUserToast();
}

void deleteUserToast() {
  Fluttertoast.showToast(
    msg: '정상적으로 탈퇴되었습니다.',
    gravity: ToastGravity.BOTTOM,
    toastLength: Toast.LENGTH_SHORT,
  );
}

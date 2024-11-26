import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 숫자 입력 제한을 위한 패키지
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: 20),
          // 프로필 사진, 이름, 이메일 부분
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(auth.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return Text("사용자 정보를 불러오는 데 실패했습니다.");
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        userData['profile_image'] ??
                            "https://via.placeholder.com/150", // 프로필 이미지 URL
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${userData['username']} 님",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['email'],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 450,
                padding: EdgeInsets.all(35),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // '나의 메뉴' 텍스트
                    Text(
                      "나의 메뉴",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
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
                    MenuItem(
                      text: "로그아웃",
                      onTap: () {
                        showSignOutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
  TextEditingController budgetController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("월 예산 설정"),
        content: TextField(
          controller: budgetController,
          decoration: InputDecoration(
            labelText: "월 예산",
            hintText: "숫자만 입력해주세요",
          ),
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
            onPressed: () async {
              String input = budgetController.text.trim();
              int? budget = int.tryParse(input);

              if (budget == null || budget < 0) {
                Fluttertoast.showToast(
                  msg: "유효한 월 예산 금액을 입력해주세요.",
                  gravity: ToastGravity.BOTTOM,
                );
                return;
              }

              try {
                // Firestore 업데이트
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(auth.currentUser?.uid)
                    .update({'monthly_budget': budget});

                Fluttertoast.showToast(
                  msg: "월 예산이 성공적으로 설정되었습니다!",
                  gravity: ToastGravity.BOTTOM,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "월 예산 설정에 실패했습니다. 오류: $e",
                  gravity: ToastGravity.BOTTOM,
                );
              }

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
  TextEditingController nameController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("이름 변경"),
        content: TextField(
          controller: nameController,
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
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(auth.currentUser?.uid)
                      .update({'username': newName});
                  Fluttertoast.showToast(msg: "이름이 변경되었습니다.");
                } catch (e) {
                  Fluttertoast.showToast(msg: "이름 변경에 실패했습니다: $e");
                }
              }
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

void showChangePasswordDialog(BuildContext context) {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("비밀번호 변경"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "변경할 비밀번호",
                hintText: "비밀번호",
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
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
            onPressed: () async {
              String newPassword = passwordController.text.trim();
              String confirmPassword = confirmPasswordController.text.trim();

              if (newPassword.isEmpty || confirmPassword.isEmpty) {
                Fluttertoast.showToast(msg: "비밀번호를 입력해주세요.");
                return;
              }
              if (newPassword != confirmPassword) {
                Fluttertoast.showToast(msg: "비밀번호가 일치하지 않습니다.");
                return;
              }
              try {
                await auth.currentUser?.updatePassword(newPassword);
                Fluttertoast.showToast(msg: "비밀번호가 성공적으로 변경되었습니다.");
              } catch (e) {
                Fluttertoast.showToast(msg: "비밀번호 변경에 실패했습니다: $e");
              }
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
            onPressed: () async {
              try {
                String? userId = auth.currentUser?.uid;

                // Firestore에서 사용자 데이터 삭제
                if (userId != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .delete();
                }

                // Firebase Authentication에서 사용자 삭제
                await auth.currentUser?.delete();

                // 탈퇴 성공 시 로그인 페이지로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
                Fluttertoast.showToast(msg: "정상적으로 회원 탈퇴가 완료되었습니다.");
              } catch (e) {
                Fluttertoast.showToast(msg: "회원 탈퇴에 실패했습니다: $e");
              }
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
            onPressed: () async {
              await signOut(context);
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

Future<void> signOut(BuildContext context) async {
  try {
    await auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
    Fluttertoast.showToast(msg: "로그아웃되었습니다.");
  } catch (e) {
    Fluttertoast.showToast(msg: "로그아웃에 실패했습니다: $e");
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newflutter/main_page.dart';
import 'package:newflutter/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance; // Firebase 인증(Authentication) 객체
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Firebase Firestore 객체
  late User? user; // 사용자 및 인증에 관련된 정보가 포함된 User 객체 late로 선언
  late String username; // 사용자 이름을 저장할 변수. 로그인 성공시 해당 계정의 username을 가져와 초기화 예정

  // controller 객체. 위젯의 속성으로 추가해서 네이티브에서의 id처럼 사용 가능하다.
  // 가령, 이메일 텍스트 필드의 텍스트를 가져오고 싶다면 email.text로 가져올 수 있음.
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  // 로그인 로직
  void logIn() async {
    try {
      // signInWithEmailAndPassword 함수는 성공시 UserCredential 객체를 반환.
      // UserCredential 객체 내에는 사용자 및 인증에 관련된 정보가 포함됨.
      final credential = await auth.signInWithEmailAndPassword(email: email.text, password: password.text);
      user = credential.user;
      if(user != null) {
        DocumentSnapshot userDoc = await firestore.collection('users').doc(user!.uid).get();
        username = userDoc['username'];

        // 메인 페이지로 이동하면서 백스택 제거
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(userId: auth.currentUser!.email.toString()),
          ),(route) => false,
        );

        // 로그인에 성공했다는 내용의 Toast 생성
        loginSuccessedToast();
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Container(
                height: 40.0,
                child: Text("입력된 정보를 다시 확인하세요!"))));
    } catch (e) {
      print(e);
    }
  }

  // 로그인을 성공했을 때 띄울 Toast 함수
  void loginSuccessedToast() {
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      msg: '${username}님 환영합니다!',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // void loginFailedToast() {
  //   Fluttertoast.showToast(
  //     msg: '${user?.email}님 환영합니다!',
  //     gravity: ToastGravity.BOTTOM,
  //     toastLength: Toast.LENGTH_SHORT,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginpage_img.png'), // 배경 이미지
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 140),
              Text(
                'My Own Money,\nMy Own Management',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 25), // login header까지의 간격
              Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 50), // FrameLayout 상단 간격
              Container(
                width: 329, height: 420,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: 250,
                      height: 40,
                      child: TextField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: '이메일 주소',
                          hintStyle: TextStyle(color: Color(0x80000000)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 60),
                    Container(
                      width: 250,
                      height: 40,
                      child: TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호',
                          hintStyle: TextStyle(color: Color(0x80000000)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 60),
                    Builder(
                        builder: (context) {
                          return ElevatedButton(
                            onPressed: logIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(250, 40),
                            ),
                            child: Text(
                              '로그인하기',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                    ),
                    SizedBox(height: 36),
                    Builder(
                        builder: (context) {
                          return ElevatedButton(
                            onPressed: () {
                              // 회원가입 페이지로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(250, 40),
                            ),
                            child: Text(
                              '회원가입',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

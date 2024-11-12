import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newflutter/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth auth = FirebaseAuth.instance; // Firebase 인증(Authentication) 객체
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Firebase Firestore 객체
  late User? user; // 사용자 및 인증에 관련된 정보가 포함된 User 객체 late로 선언

  // controller 객체. 위젯의 속성으로 추가해서 네이티브에서의 id처럼 사용 가능하다.
  // 가령, 이메일 텍스트 필드의 텍스트를 가져오고 싶다면 email.text로 가져올 수 있음.
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordChecking = TextEditingController();

  // 회원가입 로직
  void registerUser() async {

    // 회원가입에 필요한 정보를 모두 입력하지 않았을 경우(입력란이 하나라도 비어있는 경우)
    if(userName.text == "" || email.text == "" || password.text == "" || passwordChecking.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Container(
              height: 20.0,
              child: Text("필요한 정보를 모두 작성했는지 확인하세요!"))));
    }
    
    // 입력란은 모두 채웠으나 비밀번호 값이 일치하지 않았을 경우
    else if(password.text != passwordChecking.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Container(
              height: 20.0,
              child: Text("비밀번호가 일치하지 않습니다!"))));
    }

    // 빈칸도 없고 비밀번호 확인까지 문제없으나 너무 짧은 경우(8자 미만)
    else if(password.text.length < 8) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Container(
              height: 20.0,
              child: Text("비밀번호가 너무 짧아요! 8자 이상으로 입력해주세요."))));
    }

    // 비밀번호가 너무 긴 경우(15자 초과)
    else if(password.text.length > 15) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Container(
              height: 20.0,
              child: Text("비밀번호가 너무 길어요! 15자 이하로 입력해주세요."))));
    }

    // 회원가입에 필요한 정보를 모두 입력했다면, 입력값들을 토대로 회원가입 로직 작동.
    else {
      try {
        // createUserWithEmailAndPassword 함수는 성공시 UserCredential 객체를 반환.
        // UserCredential 객체 내에는 사용자 및 인증에 관련된 정보가 포함됨.
        final credential = await auth.createUserWithEmailAndPassword(email: email.text, password: password.text);
        if(credential.user != null) {
          // 회원가입시 입력한 값들을 firestore에 해당 필드 이름으로 저장.
          await firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set({
            'username' : userName.text,
            'email' : email.text,
            'password' : password.text,
          });
        }

        // 저장 완료 후 로그인 페이지로 이동하면서 백스택 제거
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),(route) => false,
        );

        // 회원가입에 성공했다는 내용의 Toast 생성
        registerSuccessedToast();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Container(
                height: 60.0,
                child: Text(e.message!))));
      }
    }
  }

  // 회원가입을 성공했을 때 띄울 Toast 함수
  void registerSuccessedToast() {
    Fluttertoast.showToast(
      msg: '회원가입이 완료되었습니다!',
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginpage_img.png'), // 배경 이미지 경로
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
                  fontSize: 20.0,
                  color: Colors.black,
                  fontFamily: 'sans-serif',
                ),
              ),
              SizedBox(height: 25),
              Text(
                '회원가입',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 36.0,
                  color: Colors.black,
                  fontFamily: 'sans-serif',
                ),
              ),
              SizedBox(height: 50),
              Container(
                width: 329.0,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 250,
                      height: 40,
                      child: TextField(
                        controller: userName,
                        decoration: InputDecoration(
                          hintText: '사용자 이름',
                          hintStyle: TextStyle(color: Color(0x80000000)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
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
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      width: 250,
                      height: 40,
                      child: TextField(
                        controller: password,
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
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      width: 250,
                      height: 40,
                      child: TextField(
                        controller: passwordChecking,
                        decoration: InputDecoration(
                          hintText: '비밀번호 확인',
                          hintStyle: TextStyle(color: Color(0x80000000)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 35.0),
                    ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 버튼 배경색
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      ),
                      child: Text(
                        '회원가입하기',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
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

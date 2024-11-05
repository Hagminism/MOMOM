import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                      onPressed: () {
                        // 회원가입 로직 처리
                      },
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

import 'package:flutter/material.dart';
import 'package:newflutter/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
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
                            onPressed: () {},
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterPage()));
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
      ),
    );
  }
}
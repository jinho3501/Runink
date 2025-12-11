import 'package:flutter/material.dart';
import 'SignUpScreen.dart';
import 'LoginScreen.dart';

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 393,
          height: 852, // 전체 화면 크기를 393x852로 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 이미지 크기를 고정
              Container(
                width: 393,
                height: 553,
                child: Image.asset(
                  'assets/images/Start.png', // 이미지 경로
                  fit: BoxFit.cover,
                ),
              ),
              // 텍스트 설명
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  '러닝크와 함께 지도에 그림을 그려보세요.',
                  style: TextStyle(fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold), // 텍스트 색상을 흰색으로 설정
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(), // 텍스트와 버튼 사이의 여백
              // Join for free 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0), // 양쪽 여백 14
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()), // 다음 화면으로 이동
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1287AE), // 버튼 색상을 #1287AE로 설정
                    padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼 높이 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // 버튼 모서리 둥글게 설정
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Join for free',
                      style: TextStyle(color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5), // 버튼과 로그인 버튼 사이 간격
              // Log in 텍스트 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()), // 다음 화면으로 이동
                    );
                  },
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Color(0xFF1287AE), // 텍스트 색상을 버튼과 동일하게 #1287AE로 설정
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

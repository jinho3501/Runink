import 'package:flutter/material.dart';

import 'Watch_Sign.dart';
import 'package:RunInk/Bottom_Bar.dart';

class Watch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            child: Image.asset(
              'assets/images/watch.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20), // 이미지와 텍스트 사이 간격
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '웨어러블 기기가 있나요?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10),
                Text(
                  '앱 연동을 도와줄게요',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10),
                Text(
                  '러닝과 운동을 더 재밌고, 효과적으로 관리하세요.\n'
                      '30초면 충분하며, Apple Watch를 가지고 있지 않아도 됩니다.\n'
                      'RunInk는 운동 데이터만 사용하므로, 개인 정보는 안전하게 보호됩니다',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 50), // 텍스트와 버튼 사이 간격
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // '건너 뛰기' 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BottomBarApp()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF1287AE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '건너 뛰기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1287AE),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // '기기 등록' 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WatchSign()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    backgroundColor: Color(0xFF1287AE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '기기 등록',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40), // 버튼과 하단 사이 간격
        ],
      ),
    );
  }
}
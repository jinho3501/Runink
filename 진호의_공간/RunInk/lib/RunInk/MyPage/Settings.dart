import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:RunInk/Member/Start.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 필드
            SettingItem(label: '이름', value: '김진혜성'),
            Divider(color: Colors.grey),
            // 핸드폰 번호 필드
            SettingItem(label: '핸드폰 번호', value: '010-1234-5678'),
            Divider(color: Colors.grey),
            // 신장 필드
            SettingItem(label: '신장', value: '165cm'),
            Divider(color: Colors.grey),
            // 체중 필드
            SettingItem(label: '체중', value: '58kg'),
            Divider(color: Colors.grey),
            // 기타 항목들
            // ...
            SizedBox(height: 20),
            // 로그아웃 버튼
            Center(
              child: TextButton(
                onPressed: () async {
                  // 로그아웃 함수 구현
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Start()),
                    );
                  }
                },
                child: Text('로그아웃', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String label;
  final String value;

  const SettingItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
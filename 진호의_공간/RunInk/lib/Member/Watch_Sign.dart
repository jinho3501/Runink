import 'package:flutter/material.dart';


class WatchSign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기기 등록',
            style: TextStyle(fontSize: 25,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              '러닝크와 연동할 기기를 등록하세요.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Apple Watch나 다른 웨어러블 기기를 RunInk에 등록하여, 운동 데이터와 목표를 더 효과적으로 관리할 수 있습니다.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 기기 등록 로직을 추가할 수 있습니다.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('기기가 등록되었습니다.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1287AE),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '기기 등록',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF1287AE)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '취소',
                  style: TextStyle(color: Color(0xFF1287AE), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
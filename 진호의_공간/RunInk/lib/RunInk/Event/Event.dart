import 'package:flutter/material.dart';
import 'package:RunInk/RunInk/Event/Brand/Brand.dart';
import 'package:RunInk/RunInk/Event/Local/Local.dart';
import 'package:RunInk/RunInk/Event/Anniversary/Anniversary.dart';
import 'package:RunInk/RunInk/Event/Ink/Ink.dart';

class Event extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: 393,
            height: 852,
            color: Colors.grey[900],
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 66),
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    'Ink',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 393,
                  height: 1,
                  color: Colors.white,
                ),
                SizedBox(height: 31.5),

                // Ink 항목을 가장 위로 이동
                buildEventBox(
                  context,
                  title: 'Ink',
                  description: '자신만의 루트를 만들어봐요',
                  imagePath: 'assets/GIF/Ink.gif',
                  destination: MapPage(),
                ),

                SizedBox(height: 29),

                // 기존 항목 1
                buildEventBox(
                  context,
                  title: 'Brand',
                  description: '유명 브랜드 로고를 따라 그리기',
                  imagePath: 'assets/GIF/Nike.gif',
                  destination: Brand(),
                ),

                SizedBox(height: 29),

                // 기존 항목 2
                buildEventBox(
                  context,
                  title: 'Anniversary',
                  description: '기념일을 기념하며 달리기',
                  imagePath: 'assets/GIF/Anniversary.gif',
                  destination: Anniversary(),
                ),

                SizedBox(height: 29),

                // 기존 항목 3
                buildEventBox(
                  context,
                  title: 'Local',
                  description: '지역 코스를 따라 달리기',
                  imagePath: 'assets/GIF/Local.gif',
                  destination: Local(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEventBox(BuildContext context, {required String title, required String description, required String imagePath, required Widget destination}) {
    return Padding(
      padding: const EdgeInsets.only(left: 27),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // 모서리 둥글기 설정
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                imagePath,
                width: 340,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 12,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 120,
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 155,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'with Run',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),bottom: 10,
          ),
        ],
      ),
    );
  }
}
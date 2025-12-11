import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int _currentAdIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('상점', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Column(
        children: [
          // 광고 슬라이드
          CarouselSlider(
            items: [
              Image.asset('assets/images/GS.png', fit: BoxFit.cover),
              Image.asset('assets/images/Cu.png', fit: BoxFit.cover),
            ],
            options: CarouselOptions(
              height: 150,
              autoPlay: true,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentAdIndex = index;
                });
              },
            ),
          ),
          // Best 섹션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text("⭐ Best ⭐", style: TextStyle(color: Colors.amber, fontSize: 18)),
          ),
          CarouselSlider(
            items: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/Culture.jpeg', width: 100, height: 100, fit: BoxFit.cover),
                  Image.asset('assets/images/banana.jpeg', width: 100, height: 100, fit: BoxFit.cover),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/Culture.jpeg', width: 100, height: 100, fit: BoxFit.cover),
                  Image.asset('assets/images/banana.jpeg', width: 100, height: 100, fit: BoxFit.cover),
                ],
              ),
            ],
            options: CarouselOptions(
              height: 150,
              enlargeCenterPage: true,
            ),
          ),
          SizedBox(height: 20),
          // 카테고리 버튼 그리드
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCategoryButton('assets/images/Online Store.png', '편의점'),
                _buildCategoryButton('assets/images/Gift Card.png', '상품권'),
                _buildCategoryButton('assets/images/Cutlery.png', '외식'),
                _buildCategoryButton('assets/images/Cafe.png', '카페'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 버튼 위젯
  Widget _buildCategoryButton(String assetPath, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(assetPath, width: 50, height: 50, color: Colors.white),
        SizedBox(height: 10),
        Text(title, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
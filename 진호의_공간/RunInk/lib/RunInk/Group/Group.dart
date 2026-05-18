import 'package:flutter/material.dart';
import 'package:RunInk/RunInk/Group/Group_Search.dart';
import 'package:RunInk/RunInk/Group/Group_Edit.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Groups',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _showGroupSelection(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: 'Groups'),
            Tab(text: 'One-day'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCrewInfo(), // 가입된 크루 정보 표시
          _buildOneDayInfo(), // One-day 크루 정보 표시
        ],
      ),
    );
  }

  Widget _buildCrewInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // 게시글을 스크롤 가능하게 만들기
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage('assets/images/Crew.png'), // 대표 사진 설정
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  left: 20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle, // 로고를 네모로 설정
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/Logo.png', // 로고 이미지 설정
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Byte-King',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WritePage()),
                    );
                  },
                  child: Text('Edit',style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 18),
                SizedBox(width: 5),
                Text(
                  '대한민국 광주광역시',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flag,color: Colors.white,size: 18,),
                SizedBox(width: 5,),
                Text(
                  '13,203m ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Icon(Icons.group,color: Colors.white,size: 18,),
                SizedBox(width: 5,),
                Text(
                  '5 ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '안녕하세요! 한입에 씹어먹어버리자! 러닝에 진심인 크루 \nByte-King입니다.',
              style: TextStyle(color: Colors.white70),
            ),
            Divider(color: Colors.white54, thickness: 0.5, height: 30),
            _buildPost("Heram Lee", "2024.11.23", "우리팀과 함께 광주천 달리기", 'assets/images/ByteKing.png'),
            // 추가 포스트는 _buildPost 위젯으로 추가 가능
          ],
        ),
      ),
    );
  }

  Widget _buildOneDayInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One-day',
                  style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  ': 단기간 크루\n\n24시간 내 단기간 크루를 결성하여 러닝 프로그램\n\n함께 달릴까요?',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPost(String user, String date, String content, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/Icon.png'), // 사용자 프로필 이미지
              radius: 15,
            ),
            SizedBox(width: 8),
            Text(
              user,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              date,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
        ),
        Divider(color: Colors.white54, thickness: 0.5, height: 30),
      ],
    );
  }

  void _showGroupSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          content: Container(
            height: 150,
            child: Column(
              children: [
                Text(
                  'Create Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton('Groups', Colors.green, () {
                      Navigator.pop(context);
                      // 그룹 선택 후 원하는 작업 추가
                    }),
                    _buildButton('One-day', Colors.blue, () {
                      Navigator.pop(context);
                      // One-day 선택 후 원하는 작업 추가
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
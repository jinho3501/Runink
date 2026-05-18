import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:RunInk/RunInk/MyPage/Settings.dart';
import 'package:RunInk/RunInk/MyPage/Store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MypageSetting extends StatefulWidget {
  @override
  _MypageSettingState createState() => _MypageSettingState();
}

class _MypageSettingState extends State<MypageSetting> {
  File? _profileImage;
  String _userName = '사용자';
  String _profileImageUrl = '';
  bool _isLoading = false;


  // 추가된 상태 변수들
  int _myRank = 0;
  int _crewRank = 0;
  int _points = 0;
  double _monthlyGoal = 100.0;
  double _total_distance = 0.0;

  // 사용자 인증 정보
  final String _userId = "123456@naver.com"; // 예시 값

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'http://43.203.107.133:8000/user';
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'userId': _userId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);
        setState(() {
          _userName = data['name'] ?? '사용자';
          _profileImageUrl = data['profile_image'] ?? '';
          _points = data['points'] ?? 0;
          _monthlyGoal = (data['monthly_goal'] ?? 100.0).toDouble();
          _total_distance = double.tryParse(data['total_distance'].toString()) ?? 0.0;
        });

        await fetchRankings();
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchRankings() async {
    final rankUrl = 'http://43.203.107.133:8000/rankings';
    final headers = {
      'Content-Type': 'application/json',

    };
    final body = json.encode({
      'userId': _userId,
    });

    try {
      final response = await http.post(
        Uri.parse(rankUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _myRank = data['myrank'] ?? 0;
          _crewRank = data['crewrank'] ?? 0;
        });
      } else {
        print('Failed to load rankings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rankings: $e');
    }
  }
  void _navigateToNotice() {
    // 공지사항 페이지로 이동하는 로직
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => NoticePage()),
    // );
  }

  void _navigateToStore() {
    // 상점 페이지로 이동하는 로직
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StorePage()),
    );
  }
  Future<void> _uploadProfileImage(String imagePath) async {
    final url = 'http://43.203.107.133:8000/user';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll({

    });

    request.fields['userId'] = _userId;
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _profileImageUrl = responseData['image_url'] ?? '';
        });
        print('Profile image uploaded successfully');
      } else {
        print('Failed to upload profile image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        await _uploadProfileImage(pickedFile.path);
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'My Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : AssetImage('assets/profile.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _userName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('내 정보 수정', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRankingButton('나의 순위는 ${_myRank}위'),
                SizedBox(width: 10),
                _buildRankingButton('크루 순위는 ${_crewRank}위'),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('적립금', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  Row(
                    children: [
                      Text('$_points', style: TextStyle(color: Colors.white, fontSize: 18)),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('목표', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Month', style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text(
                        '${_total_distance.toStringAsFixed(1)} / ${_monthlyGoal.toStringAsFixed(1)} km',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: _total_distance / _monthlyGoal,
                      backgroundColor: Colors.grey,
                      color: Colors.greenAccent,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // 하단 아이콘 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _navigateToStore,
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white, size: 30),
                      Text('상점', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                SizedBox(width: 40),
                GestureDetector(
                  onTap: _navigateToNotice,
                  child: Column(
                    children: [
                      Icon(Icons.announcement, color: Colors.white, size: 30),
                      Text('공지사항', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingButton(String title) {
    return GestureDetector(
      onTap: () {
        print('$title 클릭됨');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
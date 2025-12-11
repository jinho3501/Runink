import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:RunInk/RunInk/MyPage/MyPage_setting.dart';
import 'package:RunInk/Run/Run_Result.dart'; // RunningResultPage 임포트

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final List<String> mapImages = [
    'assets/Recent/recent01.jpeg',
    'assets/collection/nike.png',
    'assets/collection/heart.png',
    'assets/collection/korea.png',


  ];

  int _selectedIndex = 0;

  // 그래프에 사용할 데이터 및 색상 설정
  List<Color> gradientColors = [
    Color(0xff23b6e6),
    Color(0xff02d39a),
  ];

  final List<Map<String, double>> dayRecords = [
    {'2024.10.27': 8.5},
    {'2024.10.26': 9.2},
    {'2024.10.25': 10.0},
    {'2024.10.24': 7.8},
  ];

  final List<Map<String, double>> monthRecords = [
    {'2024.09': 250.5},
    {'2024.08': 235.2},
  ];

  final List<Map<String, double>> totalRecords = [
    {'2024.10': 900.3},
    {'2024.09': 850.1},
  ];

  // 유저 데이터 변수
  String userName = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 유저 데이터 API로부터 가져오기
  Future<void> fetchUserData() async {
    final response = await http.get(Uri.parse('http://43.203.107.133:8000/login'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userName = data['name'];
        profileImageUrl = data['profile_image'];
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  List<Map<String, double>> get selectedRecords {
    if (_selectedIndex == 0) return dayRecords;
    if (_selectedIndex == 1) return monthRecords;
    return totalRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'MyPage',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MypageSetting()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 섹션
            Center(
              child: Column(
                children: [
                  if (profileImageUrl.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      radius: 40,
                    ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // 그래프 섹션
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ToggleButtons(
                  borderColor: Colors.transparent,
                  selectedBorderColor: Colors.transparent,
                  fillColor: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  selectedColor: Colors.white,
                  constraints: BoxConstraints(minHeight: 40, minWidth: 80),
                  children: [Text('Day'), Text('Month'), Text('Total')],
                  isSelected: [
                    _selectedIndex == 0,
                    _selectedIndex == 1,
                    _selectedIndex == 2,
                  ],
                  onPressed: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _selectedIndex == 0 ? 'Day 기록' : _selectedIndex == 1 ? 'Month 기록' : 'Total 기록',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                mainData(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'RECENT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedRecords.length,
                itemBuilder: (context, index) {
                  String date = selectedRecords[index].keys.first;
                  double km = selectedRecords[index].values.first;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RunningResultPage(
                              date: date,
                              distance: km,
                              pace: '5:51/km',  // 실제 페이스 데이터로 교체
                              duration: '1h 0m',  // 실제 시간 데이터로 교체
                              imagePath: mapImages[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage(mapImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    date,
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${km.toStringAsFixed(1)} km    5:51/km    1h 0m',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  index == 0 ? Icons.emoji_events : Icons.emoji_events_outlined,
                                  color: Colors.yellow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 0.5),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              String label;

              if (_selectedIndex == 0) { // Day view
                const weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                label = weekDays[index % 7];
              } else if (_selectedIndex == 1) { // Month view
                label = "${index + 1}월";
              } else { // Total view
                const years = ["2023", "2024"];
                label = years[index % 2];
              }

              return Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text('${value.toInt()} km', style: TextStyle(color: Colors.white, fontSize: 10)),
            interval: 50,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: selectedRecords.asMap().entries.map((entry) {
            int index = entry.key;
            double km = entry.value.values.first;
            return FlSpot(index.toDouble(), km);
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
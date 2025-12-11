import 'package:flutter/material.dart';

class CrewPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Byte-King',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900], // 배경색 설정
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  color: Colors.grey[700],
                ),
                Positioned(
                  top: 100,
                  left: 20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/crew.png'), // 이미지 경로 수정 필요
                  ),
                ),
                Positioned(
                  top: 150,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text("FOLLOW"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Byte-King',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 폰트 색깔
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '안녕하세요! 한입에 씹어먹어버리자! 러닝에 진심인 크루, Byte-King입니다. 속도와 도전을 즐기는 러너들, 함께 달리며 한계를 넘어서 봅시다!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white, thickness: 1), // 구분선 추가
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('멤버', '5'),
                      VerticalDivider(
                        color: Colors.white,
                        thickness: 1,
                        width: 20,
                      ),
                      _buildInfoColumn('팔로잉', '5'),
                      VerticalDivider(
                        color: Colors.white,
                        thickness: 1,
                        width: 20,
                      ),
                      _buildInfoColumn('팔로워', '5'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Divider(color: Colors.white, thickness: 1), // 구분선 추가
                  const SizedBox(height: 20),
                  Text(
                    '최근활동',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: 4, // MyPage와 동일한 데이터 개수
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '지도',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '2024.10.${27 - index}', // 임시 날짜
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${8.5 + index} km   5:51/km   1h 0m', // 임시 데이터
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 폰트 색깔
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
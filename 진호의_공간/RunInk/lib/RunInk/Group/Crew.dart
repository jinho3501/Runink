import 'package:flutter/material.dart';

class CrewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Color(0xFF292B69), // 배경 색상 설정
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 상단 배경 색
                Container(
                  color: Color(0xFF292B69), // 배경 색상 설정
                  height: 150,
                  width: double.infinity,
                ),
                // 프로필 이미지
                Positioned(
                  top: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // 둥근 모서리
                    child: Image.asset(
                      'assets/images/Crew.png',
                      width: 200,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // 이미지와 텍스트 간격 조정
            // 텍스트 내용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Byte-King',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '안녕하세요! 한입에 씹어먹어버리자! 러닝에 진심인 크루, Byte-King입니다. 속도와 도전을 즐기는 러너들, 함께 달리며 한계를 넘어서 봅시다!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // 텍스트 색상 설정
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // FOLLOW 버튼
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("FOLLOW",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(height: 30),
                  // 최근활동
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '최근활동',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 최근활동 리스트뷰
                  Container(
                    height: 250,
                    child: ListView.builder(
                      itemCount: 10, // 예시 데이터 개수 (더 많은 활동이 있다고 가정)
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                // 경로 이미지
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/path_image.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '하트 모양 길',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Easy   8km   0h30m',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '서울 관악구 남부순환로 1614',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
}
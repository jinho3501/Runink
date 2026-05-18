import 'package:flutter/material.dart';
import 'package:RunInk/RunInk/Group/Crew1.dart';
import 'package:RunInk/RunInk/Rank/Individual.dart';

class Rank extends StatefulWidget {
  const Rank({Key? key}) : super(key: key);

  @override
  State<Rank> createState() => _RankPageState();
}

class _RankPageState extends State<Rank> {
  bool isCrewSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: [
            // 타이틀과 정보 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Crew/Individual 탭 선택
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isCrewSelected = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isCrewSelected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'crew',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isCrewSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isCrewSelected = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isCrewSelected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'individual',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isCrewSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Crew 또는 Individual 랭킹 뷰 표시
            Expanded(
              child: isCrewSelected
                  ? CrewRankView()  // 여기서 const 제거
                  : IndividualRankView(),  // 여기서 const 제거
            ),
          ],
        ),
      ),
    );
  }
}

// Crew 랭킹 뷰
class CrewRankView extends StatelessWidget {
  final List<String> crewImages = [
    'assets/Crew/LG.jpeg',
    'assets/Crew/6.jpeg',
    'assets/Crew/oh.jpeg',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '우리 지역 1등 크루는?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildCrewCard(context, 'Byte-King', '1800 km', 'Byte-King 크루로 달리기 >', Colors.indigo, 1),
              const SizedBox(height: 12),
              _buildCrewCard(context, 'RunInk', '1780 km', 'RunInk 크루로 달리기 >', Colors.teal, 2),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Ranks near you',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 3,
            itemBuilder: (context, index) {
              final names = [
                'LG space',
                '육각수',
                'Oh 미소',
              ];
              // Get name based on index, use 'Runner' if index is beyond the names list
              String displayName = index < names.length ? names[index] : 'crew ${index + 1}';
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundImage: AssetImage(crewImages[index])),
                    const SizedBox(width: 12),
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    Icon(
                      index % 2 == 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCrewCard(BuildContext context, String name, String distance, String buttonText, Color color, int rank) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CrewPage1()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              distance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IndividualRankView extends StatelessWidget {
  final List<String> profileImages = [
    'assets/profile/jinho.jpeg',
    'assets/profile/sungil.png',
    'assets/profile/minji.jpeg',
    'assets/profile/choice.png',
    'assets/profile/dong.jpeg',
  ];
  Widget _buildTopRunner(String name, String distance, int rank, Color color, String imagePath) {
    final bool isFirst = rank == 1;
    final double avatarSize = isFirst ? 90.0 : 70.0;

    IconData getRankIcon(int rank) {
      switch (rank) {
        case 1:
          return Icons.emoji_events;
        case 2:
          return Icons.emoji_events;
        case 3:
          return Icons.emoji_events;
        default:
          return Icons.stars;
      }
    }

    Color getRankIconColor(int rank) {
      switch (rank) {
        case 1:
          return Colors.yellow;
        case 2:
          return Colors.grey[300]!;
        case 3:
          return Colors.orange[300]!;
        default:
          return Colors.white;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: getRankIconColor(rank),
                        width: isFirst ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isFirst ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    distance,
                    style: TextStyle(
                      fontSize: isFirst ? 12 : 10,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -10,
                child: Icon(
                  getRankIcon(rank),
                  color: getRankIconColor(rank),
                  size: isFirst ? 24 : 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        SizedBox(
          height: 250,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 180,
                        width: 100,
                        child: _buildTopRunner(
                            'Jinho Lim',
                            '320 km',
                            2,
                            Colors.pink[100]!,
                            'assets/profile/jinho.jpeg'
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        width: 90,
                        child: _buildTopRunner(
                            'Hyeram Lee',
                            '350 km',
                            1,
                            Colors.purple[200]!,
                            'assets/profile/Hyeram.jpeg'
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        width: 90,
                        child: _buildTopRunner(
                            'Kolleen Park',
                            '300 km',
                            3,
                            Colors.amber[200]!,
                            'assets/profile/sungil.png'
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 90,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ranks near you',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              // List of specific names
              final names = [
                'Jinho Lim',
                '성일연구소 박성일',
                'Minji Kim',
                '김선택',
                '권동현',
              ];
              // Get name based on index, use 'Runner' if index is beyond the names list
              String displayName = index < names.length ? names[index] : 'Runner ${index + 1}';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Individual()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFF2196F3).withOpacity(0.8)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [

                      CircleAvatar(radius: 20,
                        backgroundImage: AssetImage(profileImages[index]),),
                      const SizedBox(width: 12),
                      Text(
                        displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Icon(
                        index % 2 == 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: index % 2 == 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
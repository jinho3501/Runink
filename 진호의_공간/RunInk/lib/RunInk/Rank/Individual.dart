import 'package:flutter/material.dart';

class Individual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back,color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Collection',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
            backgroundColor: Colors.grey[900],
            floating: true,
          ),

          // Profile Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[900],
              child: Column(
                children: [
                  // Profile Image
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile/jinho.jpeg'),
                    ),
                  ),

                  // Name
                  Text(
                    'Jinho Lim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Stats Row
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('350', '게시물'),
                        _buildStatColumn('1,423', 'km'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image Grid
          // Image Grid 부분 수정
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final List<String> images = [
                  'assets/collection/route.png',
                  'assets/collection/bread.png',
                  'assets/collection/circle.png',
                  'assets/collection/flower.png',
                  'assets/collection/heart.png',
                  'assets/collection/nike.png',
                  'assets/collection/circle02.png',
                  'assets/collection/korea.png',
                  'assets/collection/tree.png',
                  'assets/collection/sink.png',
                  'assets/collection/x.png',
                  'assets/collection/r.png',
                ];

                return GestureDetector(
                  onTap: () {
                    if (index < images.length) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imagePath: images[index],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.grey[700],
                    child: index < images.length
                        ? Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    )
                        : Container(),
                  ),
                );
              },
              childCount: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imagePath,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
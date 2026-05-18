import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 0,
        title: Text('Search', style: TextStyle(color: Colors.white,fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode()); // Dismiss keyboard
              },
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for Groups',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Filter Tags
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip("초보자"),
                _buildFilterChip("여성회원"),
                _buildFilterChip("남성회원"),
                _buildFilterChip("중급자"),
                _buildFilterChip("상급자"),
                _buildFilterChip("서울"),
                _buildFilterChip("광주"),
                _buildFilterChip("제주도"),
              ],
            ),
          ),

          // Group List
          Expanded(
            child: ListView.builder(
              itemCount: 6, // Number of groups
              itemBuilder: (context, index) {
                return _buildGroupItem(index); // Group items
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(label, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black54,
      ),
    );
  }

  Widget _buildGroupItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        tileColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/group$index.png'), // Set group image
          radius: 25,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Group Name $index', style: TextStyle(color: Colors.white)),
            Chip(
              label: Text(index % 2 == 0 ? "Crew" : "One-Day"),
              backgroundColor: index % 2 == 0 ? Colors.pink[100] : Colors.yellow[200],
            ),
          ],
        ),
        subtitle: Text('Location info here', style: TextStyle(color: Colors.white60)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54),
      ),
    );
  }
}
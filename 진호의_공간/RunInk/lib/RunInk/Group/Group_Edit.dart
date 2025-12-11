import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WritePage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _textController = TextEditingController();
  XFile? _imageFile;  // 이미지 파일을 저장할 변수

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  // 게시글 작성 버튼 클릭 시 처리
  void _submitPost() {
    String content = _textController.text;
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('내용을 입력해주세요.')));
    } else {
      // 게시글을 제출하는 로직을 여기에 추가
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('게시글이 제출되었습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('글쓰기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 선택 버튼
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image, color: Colors.white),
              label: Text('이미지 첨부', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700], // 회색 계열
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 5, // 버튼에 그림자 추가
              ),
            ),
            SizedBox(height: 20),

            // 선택된 이미지 표시
            _imageFile == null
                ? Text('선택된 이미지가 없습니다.', style: TextStyle(color: Colors.white))
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_imageFile!.path),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Expanded로 글쓰기 영역을 하단으로
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 글 내용 입력
                  TextField(
                    controller: _textController,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: '내용을 입력하세요',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    maxLines: 6,
                  ),
                ],
              ),
            ),

            // 게시글 작성 버튼
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('게시글 작성',style: TextStyle(color: Colors.white12),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], // 버튼 색상
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(double.infinity, 50), // 버튼 길쭉하게 만들기
                elevation: 5, // 버튼에 그림자 추가
              ),
            ),
          ],
        ),
      ),
    );
  }
}
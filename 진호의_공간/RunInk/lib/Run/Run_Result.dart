import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:RunInk/Run/Image_Edit.dart';

class RunningResultPage extends StatefulWidget {
  final String date;
  final double distance;
  final String pace;
  final String duration;
  final String imagePath;

  RunningResultPage({
    required this.date,
    required this.distance,
    required this.pace,
    required this.duration,
    required this.imagePath,
  });

  @override
  _RunningResultPageState createState() => _RunningResultPageState();
}

class _RunningResultPageState extends State<RunningResultPage> {
  String runningTitle = '일요일 야간 러닝';
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _captureAndShareImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/running_result.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: '러닝 결과',
            subject: runningTitle,
          );
        }
      }
    } catch (e) {
      print('Error sharing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 공유 중 오류가 발생했습니다.')),
      );
    }
  }

  void _editTitle() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: runningTitle);
        return AlertDialog(
          title: Text("제목 편집"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "러닝 제목 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  runningTitle = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("저장"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptions(context);
            },
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.date,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    runningTitle,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey[400], size: 20),
                    onPressed: _editTitle,
                  ),
                ],
              ),
              Divider(color: Colors.grey[400]),
              Row(
                children: [
                  Text(
                    widget.distance.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 53,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' km',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                '시간    ${widget.duration}               칼로리   120kcal\n\n페이스   ${widget.pace}',
                style: TextStyle(color: Colors.grey[200], fontSize: 17),
              ),
              SizedBox(height: 30),
              Stack(
                children: [
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      image: DecorationImage(
                        image: AssetImage(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '서울특별시 성동구 금호1가동',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('이미지 편집'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageEditingPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('공유하기'),
              onTap: () {
                Navigator.pop(context);
                _captureAndShareImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('삭제'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
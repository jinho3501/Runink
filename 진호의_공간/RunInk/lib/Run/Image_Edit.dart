import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageEditingPage extends StatefulWidget {
  @override
  _ImageEditingPageState createState() => _ImageEditingPageState();
}

class _ImageEditingPageState extends State<ImageEditingPage> {
  bool isMyDataSelected = true;
  int? selectedItemIndex;
  final GlobalKey _globalKey = GlobalKey();

  final List<String> myDataItems = List.generate(12, (index) => 'My Data $index');
  final List<String> stickerItems = List.generate(12, (index) => 'Sticker $index');

  Future<void> _captureAndShareImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/shared_image.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: '이미지 편집',
            subject: '공유된 이미지',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
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
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _captureAndShareImage,
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Container(
                height: 400,
                color: Colors.grey[700],
                child: Center(
                  child: Text(
                    '지도 이미지',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isMyDataSelected = true;
                          selectedItemIndex = null;
                        });
                      },
                      child: Container(
                        color:
                        isMyDataSelected ? Colors.white : Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            'My Data',
                            style: TextStyle(
                              color: isMyDataSelected ? Colors.black : Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isMyDataSelected = false;
                          selectedItemIndex = null;
                        });
                      },
                      child: Container(
                        color:
                        !isMyDataSelected ? Colors.white : Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            '스티커',
                            style: TextStyle(
                              color: !isMyDataSelected ? Colors.black : Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,  // 수정된 부분
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount:
                  isMyDataSelected ? myDataItems.length : stickerItems.length,
                  itemBuilder: (context, index) {
                    final isXIcon = index == 0;
                    final item = isMyDataSelected
                        ? myDataItems[index]
                        : stickerItems[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedItemIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          border: selectedItemIndex == index
                              ? Border.all(color: Colors.yellow, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: isXIcon
                              ? Icon(Icons.close, color: Colors.red)
                              : Text(
                            item,
                            style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
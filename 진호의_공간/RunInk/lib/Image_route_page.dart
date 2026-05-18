import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:RunInk/RunInk/selected_route_page.dart';
import 'package:numberpicker/numberpicker.dart';

class ImageRoutePage extends StatefulWidget {
  final File image;
  final Function(Map<String, dynamic>) onRouteCreated;

  const ImageRoutePage({
    super.key,
    required this.image,
    required this.onRouteCreated,
  });

  @override
  State<ImageRoutePage> createState() => _ImageRoutePageState();
}

class _ImageRoutePageState extends State<ImageRoutePage> {
  bool _isUploading = false;
  int _selectedDistance = 5; // 기본값 5km로 설정

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://43.203.107.133:8000/upload_image'),
      );

      // 이미지 파일 추가
      var imageStream = http.ByteStream(widget.image.openRead());
      var length = await widget.image.length();
      var multipartFile = http.MultipartFile(
        'file',
        imageStream,
        length,
        filename: 'image.jpg',
      );
      request.files.add(multipartFile);

      // Form 데이터 추가
      request.fields['content'] = "test_content";  // 테스트용 컨텐츠
      request.fields['lat'] = "37.491914";  // 기본 위치값 또는 현재 위치
      request.fields['lng'] = "127.026912"; // 기본 위치값 또는 현재 위치

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        Map<String, dynamic> routeData = {
          'points': jsonResponse['route']['routes'][0]
              .map<LatLng>((point) => LatLng(point['lat'], point['lng']))
              .toList(),
          'distance': jsonResponse['distance']['route_distance'],
        };

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedRoutePage(
              selectedRoute: routeData,
            ),
          ),
        );
      } else {
        throw Exception(jsonResponse['detail'] ?? '알 수 없는 에러가 발생했습니다.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("오류"),
            content: Text("경로 생성 중 오류가 발생했습니다: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Text(
              "아래 이미지로 경로를 생성하겠습니까?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child: Image.file(
                widget.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // NumberPicker 추가
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '목표 거리 설정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NumberPicker(
                      value: _selectedDistance,
                      minValue: 1,
                      maxValue: 42,
                      onChanged: (value) => setState(() => _selectedDistance = value),
                      textStyle: TextStyle(color: Colors.grey),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shadowColor: Colors.indigoAccent,
              ),
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                "경로 생성",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
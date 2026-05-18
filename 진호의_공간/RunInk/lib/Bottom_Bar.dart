import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'RunInk/Event/Event.dart';
import 'RunInk/Rank/Rank.dart';
import 'RunInk/Group/Group.dart';
import 'RunInk/MyPage/MyPage.dart';
import 'RunInk/CenterPage/CenterPage.dart';

void main() => runApp(BottomBarApp());

class BottomBarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (_) => HelloConvexAppBar(),
        "/Rank": (_) => Rank(),
        "/event": (_) => Event(),
        "/center": (_) => CenterPage(),
        "/group": (_) => GroupPage(),
        "/My": (_) => MyPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HelloConvexAppBar extends StatefulWidget {
  @override
  State<HelloConvexAppBar> createState() => _HelloConvexAppBarState();
}

class _HelloConvexAppBarState extends State<HelloConvexAppBar> {
  int _selectedIndex = 2;
  final List<Widget> _pages = [
    Rank(),
    Event(),
    CenterPage(),
    GroupPage(),
    MyPage(),
  ];

  Location _locationController = Location();
  LatLng? _currentP;
  bool _isLocationInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) {
          print('위치 서비스가 비활성화되어 있습니다.');
          return;
        }
      }

      // 위치 권한 확인
      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      // 위치 정확도 설정
      await _locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,  // 1초마다 업데이트
        distanceFilter: 0, // 거리 필터 비활성화
      );
      print('위치 설정 변경됨');


      // 초기 위치 가져오기
      LocationData currentLocation = await _locationController.getLocation();
      print('초기 위치 - 위도: ${currentLocation.latitude}, 경도: ${currentLocation.longitude}');

      setState(() {
        _currentP = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _isLocationInitialized = true;
      });

      // 위치 업데이트 리스너 설정
      _locationController.onLocationChanged.listen((LocationData location) {
        if (mounted && location.latitude != null && location.longitude != null) {
          setState(() {
            _currentP = LatLng(location.latitude!, location.longitude!);
          });
          print('위치 업데이트 - 위도: ${location.latitude}, 경도: ${location.longitude}');
        }
      });
    } catch (e) {
      print('위치 초기화 오류: $e');
    }
  }

  Future<void> _sendLocation() async {
    if (!_isLocationInitialized || _currentP == null) {
      // 위치 정보 재시도
      try {
        LocationData location = await _locationController.getLocation();
        setState(() {
          _currentP = LatLng(location.latitude!, location.longitude!);
          _isLocationInitialized = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 정보를 가져올 수 없습니다. 위치 서비스를 확인해주세요.')),
        );
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('http://43.203.107.133:8000/center'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': "test",
          'location': {
            'latitude': _currentP!.latitude,
            'longitude': _currentP!.longitude
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 정보가 성공적으로 전송되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 응답 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: Colors.black,
        height: 70,
        curveSize: 100,
        items: [
          TabItem(icon: Icons.thumb_up, title: 'Rank'),
          TabItem(icon: Icons.color_lens_outlined, title: 'Ink'),
          TabItem(icon: Icons.directions_run, title: 'CenterPage'),
          TabItem(icon: Icons.group, title: 'Group'),
          TabItem(icon: Icons.settings, title: 'My'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int i) async {
          setState(() {
            _selectedIndex = i;
          });

          if (i == 2) {
            await _sendLocation();
          }
        },
        activeColor: _selectedIndex == 2 ? Color(0xFF00FF15) : Colors.white,
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:RunInk/RunInk/CenterPage/RunningTracker.dart';
import 'package:RunInk/Image_route_page.dart';
import 'package:RunInk/RunInk/selected_route_page.dart';

class CenterPage extends StatefulWidget {
  const CenterPage({super.key});

  @override
  State<CenterPage> createState() => _CenterPageState();
}

class _CenterPageState extends State<CenterPage> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  // 서울 위치를 백업용으로 유지
  static const LatLng _seoulPosition = LatLng(37.484299, 126.970438);
  LatLng? _currentP;
  List<LatLng> _path = [];
  File? _selectedImage;

  double _distance = 5.00;
  String _time = "00:30";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
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
      PermissionStatus permission = await _locationController.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _locationController.requestPermission();
        if (permission != PermissionStatus.granted) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      // 위치 설정
      await _locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000, // 5초마다 업데이트
        distanceFilter: 5, // 5미터 이상 이동시 업데이트
      );

      // 초기 위치 가져오기
      LocationData locationData = await _locationController.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        print('초기 위치: ${locationData.latitude}, ${locationData.longitude}');

        // 기본값이 아닌지 확인
        if (locationData.latitude != 37.785834 && locationData.longitude != -122.406417) {
          setState(() {
            _currentP = LatLng(locationData.latitude!, locationData.longitude!);
            _isLoading = false;
          });

          // 지도 이동
          _moveToCurrentLocation(locationData.latitude!, locationData.longitude!);
        } else {
          print('기본값 위치가 감지되었습니다. 실제 위치를 기다립니다.');
        }
      }

      // 위치 업데이트 리스너
      _locationController.onLocationChanged.listen(
            (LocationData currentLocation) {
          if (currentLocation.latitude != null &&
              currentLocation.longitude != null &&
              currentLocation.latitude != 37.785834 &&
              currentLocation.longitude != -122.406417) {

            print('새로운 위치: ${currentLocation.latitude}, ${currentLocation.longitude}');

            setState(() {
              _currentP = LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
              _path.add(_currentP!);
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('위치 업데이트 오류: $error');
        },
      );
    } catch (e) {
      print('위치 서비스 초기화 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _moveToCurrentLocation(double latitude, double longitude) async {
    try {
      final GoogleMapController controller = await _mapController.future;
      final CameraPosition newPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15,
      );
      await controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    } catch (e) {
      print('카메라 이동 오류: $e');
    }
  }

  // 이미지 선택 동작
  // CenterPage 클래스에서
  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // 이미지 선택 후 경로 생성 페이지로 이동
      final routeData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageRoutePage(
            image: _selectedImage!,
            onRouteCreated: (routeData) {
              // 경로가 생성되면 SelectedRoutePage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectedRoutePage(
                    selectedRoute: routeData,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }


  void _showPlaysheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RunningTracker(),
                  ),
                );
              },
              child: Container(
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_run, color: Colors.white, size: 40),
                      SizedBox(height: 10),
                      Text(
                        '바로 달리기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _setDistance();
                },
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_road, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text(
                          '거리',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _setTime();
                },
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text(
                          '시간',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 거리 설정 동작
  void _setDistance() {
    double _tempDistance = _distance;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("거리 설정"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "현재 거리: ${_tempDistance.toStringAsFixed(2)} km",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Slider(
                    value: _tempDistance,
                    min: 1.0,
                    max: 42.0,
                    divisions: 41,
                    label: "${_tempDistance.toStringAsFixed(2)} km",
                    onChanged: (value) {
                      setState(() {
                        _tempDistance = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _distance = _tempDistance;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // CenterPage 클래스의 _setTime 메서드 수정
  void _setTime() {
    int _tempMinutes = int.parse(_time.split(':')[0]) * 60 + int.parse(_time.split(':')[1]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("시간 설정"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "현재 시간: ${(_tempMinutes ~/ 60).toString().padLeft(2, '0')}:${(_tempMinutes % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Slider(
                    value: _tempMinutes.toDouble(),
                    min: 1.0,
                    max: 240.0,
                    divisions: 239,
                    label: "${(_tempMinutes ~/ 60).toString().padLeft(2, '0')}시간 ${(_tempMinutes % 60).toString()}분",
                    onChanged: (value) {
                      setState(() {
                        _tempMinutes = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _time = "${(_tempMinutes ~/ 60).toString().padLeft(2, '0')}:${(_tempMinutes % 60).toString().padLeft(2, '0')}";
                    });
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RunningTracker(
                          targetTimeInSeconds: _tempMinutes * 60,
                        ),
                      ),
                    );
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentP ?? _seoulPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
            ),
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton(
              onPressed: () => _addImage(),
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 5,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 10,
            child: FloatingActionButton(
              onPressed: () => _showPlaysheet(context),
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 5,
              child: const Icon(
                Icons.play_arrow,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


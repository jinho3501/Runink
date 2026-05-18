import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:RunInk/RunInk/workout_result_page.dart';

class RunningTracker extends StatefulWidget {
  final int? targetTimeInSeconds; // 목표 시간 (초)

  const RunningTracker({Key? key, this.targetTimeInSeconds}) : super(key: key);

  @override
  State<RunningTracker> createState() => _RunningTrackerState();
}

class _RunningTrackerState extends State<RunningTracker> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  bool _hideTargetTime = false;
  bool _isRecording = false;
  bool _isPaused = false;
  Timer? _timer;
  Timer? _targetTimer;
  Duration _recordDuration = Duration.zero;
  Duration _targetDuration = Duration.zero;
  List<LatLng> _recordedRoute = [];
  LocationData? _currentLocation;
  Map<PolylineId, Polyline> _polylines = {};
  bool _isTargetTimeComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.targetTimeInSeconds != null) {
      _targetDuration = Duration(seconds: widget.targetTimeInSeconds!);
    }
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationTracking() async {
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      await _locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 5,
      );

      _locationController.onLocationChanged.listen((LocationData location) {
        setState(() {
          _currentLocation = location;
          if (_isRecording && !_isPaused && location.latitude != null && location.longitude != null) {
            _recordedRoute.add(LatLng(location.latitude!, location.longitude!));
            _updateRecordedRoutePolyline();
          }
        });
        _moveCamera(LatLng(location.latitude!, location.longitude!));
      });
    } catch (e) {
      print('Location tracking initialization error: $e');
    }
  }

  void _updateRecordedRoutePolyline() {
    if (_recordedRoute.isNotEmpty) {
      PolylineId id = PolylineId('recorded_route');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: _recordedRoute,
        width: 5,
      );
      setState(() {
        _polylines[id] = polyline;
      });
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    try {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    } catch (e) {
      print('Camera move error: $e');
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
      _recordedRoute = [];
      if (_currentLocation != null) {
        _recordedRoute.add(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));
      }
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration += const Duration(seconds: 1);
      });
    });

    if (widget.targetTimeInSeconds != null) {
      _targetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_targetDuration.inSeconds > 0) {
            _targetDuration -= const Duration(seconds: 1);
          } else {
            _targetTimer?.cancel();
            _isPaused = true;
            _timer?.cancel();
            _isTargetTimeComplete = true;
          }
        });
      });
    }
  }

  void _continueRunning() {
    setState(() {
      _isPaused = false;
      _isTargetTimeComplete = false;
      _hideTargetTime = true;  // 추가
    });
    // 타이머만 다시 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration += const Duration(seconds: 1);
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
        _targetTimer?.cancel();
      } else {
        if (_isTargetTimeComplete) {
          // 목표 시간이 완료된 상태에서 재생을 누르면
          _isTargetTimeComplete = false;
          _hideTargetTime = true;  // 추가
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _recordDuration += const Duration(seconds: 1);
            });
          });
        } else {
          // 일반적인 일시정지 해제
          _startTimer();
        }
      }
    });
  }

  void _stopAndShowResult() {
    _timer?.cancel();
    _targetTimer?.cancel();

    if (_recordedRoute.isEmpty && _currentLocation != null) {
      _recordedRoute.add(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));
    }

    double actualDistance = 0;
    for (int i = 0; i < _recordedRoute.length - 1; i++) {
      actualDistance += _calculateDistance(_recordedRoute[i], _recordedRoute[i + 1]);
    }
    actualDistance = actualDistance / 1000; // 미터를 킬로미터로 변환

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutResultPage(
          duration: _recordDuration,
          recordedRoute: _recordedRoute,
          distance: actualDistance,
        ),
      ),
    );
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((point2.latitude - point1.latitude) * p) / 2 +
        c(point1.latitude * p) * c(point2.latitude * p) *
            (1 - c((point2.longitude - point1.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController.complete(controller),
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                  : const LatLng(37.5665, 126.9780), // 서울 좌표
              zoom: 19,
              tilt: 45,
            ),
            polylines: Set<Polyline>.of(_polylines.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '운동 시간: ${_formatDuration(_recordDuration)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.targetTimeInSeconds != null && !_isTargetTimeComplete && !_isPaused && !_hideTargetTime)  // 조건 수정
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '목표 시간: ${_formatDuration(_targetDuration)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_isTargetTimeComplete && _isPaused)
                  ElevatedButton(
                    onPressed: _continueRunning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('계속하기'),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isRecording)
                  ElevatedButton(
                    onPressed: _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        '운동 시작',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: _togglePause,
                        backgroundColor: _isPaused ? Colors.blue : Colors.orange,
                        child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: () => _stopAndShowResult(),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.stop),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
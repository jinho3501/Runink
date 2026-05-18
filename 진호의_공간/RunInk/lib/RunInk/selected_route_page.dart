import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'workout_result_page.dart';

class SelectedRoutePage extends StatefulWidget {
  final Map<String, dynamic> selectedRoute;

  const SelectedRoutePage({
    Key? key,
    required this.selectedRoute,
  }) : super(key: key);

  @override
  State<SelectedRoutePage> createState() => _SelectedRoutePageState();
}

class _SelectedRoutePageState extends State<SelectedRoutePage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  bool _isRecording = false;
  bool _isPaused = false;
  Map<PolylineId, Polyline> _polylines = {};
  Timer? _timer;
  Duration _recordDuration = Duration.zero;

  LocationData? _currentLocation;
  int _currentRouteIndex = 0;
  double _remainingDistance = 0.0;
  String _navigationInstruction = '';
  double _toleranceDistance = 20.0;
  bool _isNavigating = false;
  List<LatLng> _recordedRoute = [];
  LatLngBounds? _routeBounds;

  @override
  void initState() {
    super.initState();
    _initializeRoute();
    _initializeLocationTracking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEntireRoute();
    });
  }

  void _showEntireRoute() async {
    if (_mapController.isCompleted) {
      final GoogleMapController controller = await _mapController.future;
      List<LatLng> points = widget.selectedRoute['points'];
      if (points.isNotEmpty) {
        double minLat = points[0].latitude;
        double maxLat = points[0].latitude;
        double minLng = points[0].longitude;
        double maxLng = points[0].longitude;

        for (LatLng point in points) {
          minLat = math.min(minLat, point.latitude);
          maxLat = math.max(maxLat, point.latitude);
          minLng = math.min(minLng, point.longitude);
          maxLng = math.max(maxLng, point.longitude);
        }

        _routeBounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );

        controller.animateCamera(
          CameraUpdate.newLatLngBounds(_routeBounds!, 100),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeRoute() {
    PolylineId id = PolylineId('selected_route');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: widget.selectedRoute['points'],
      width: 5,
    );
    setState(() {
      _polylines[id] = polyline;
    });
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
            if (_isRecording && !_isPaused) {
              _moveCamera(LatLng(location.latitude!, location.longitude!));
            }
          }

          if (_isNavigating) {
            _updateNavigation();
          }
        });
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
            bearing: _calculateBearing(position, _getNextNavigationPoint(position)),
          ),
        ),
      );
    } catch (e) {
      print('Camera move error: $e');
    }
  }

  LatLng _getNextNavigationPoint(LatLng currentPosition) {
    List<LatLng> routePoints = widget.selectedRoute['points'];
    if (_currentRouteIndex < routePoints.length - 1) {
      return routePoints[_currentRouteIndex + 1];
    }
    return routePoints.last;
  }

  void _updateNavigation() {
    if (_currentLocation == null || widget.selectedRoute['points'].isEmpty) return;

    List<LatLng> routePoints = widget.selectedRoute['points'];
    LatLng currentLatLng = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    double minDistance = double.infinity;
    int nearestPointIndex = _currentRouteIndex;

    int searchRange = 5;
    int startIndex = math.max(0, _currentRouteIndex - searchRange);
    int endIndex = math.min(routePoints.length - 1, _currentRouteIndex + searchRange);

    for (int i = startIndex; i <= endIndex; i++) {
      double distance = _calculateDistance(currentLatLng, routePoints[i]);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPointIndex = i;
      }
    }

    if (minDistance > _toleranceDistance) {
      setState(() {
        _navigationInstruction = '경로를 이탈했습니다. 경로로 돌아와주세요.';
        _remainingDistance = minDistance;
      });
      return;
    }

    _currentRouteIndex = nearestPointIndex;

    if (_currentRouteIndex < routePoints.length - 1) {
      LatLng nextPoint = routePoints[_currentRouteIndex + 1];
      double bearing = _calculateBearing(currentLatLng, nextPoint);
      _remainingDistance = _calculateDistance(currentLatLng, nextPoint);

      setState(() {
        _navigationInstruction = _getNavigationInstruction(bearing);

        if (_remainingDistance < 30) {
          if (bearing > 30) {
            _navigationInstruction = '잠시 후 우회전';
          } else if (bearing < -30) {
            _navigationInstruction = '잠시 후 좌회전';
          }
        }
      });
    } else {
      setState(() {
        _navigationInstruction = '목적지에 도착했습니다!';
        _isNavigating = false;
      });
    }
  }

  String _getNavigationInstruction(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return '북쪽으로 이동';
    if (bearing >= 22.5 && bearing < 67.5) return '북동쪽으로 이동';
    if (bearing >= 67.5 && bearing < 112.5) return '동쪽으로 이동';
    if (bearing >= 112.5 && bearing < 157.5) return '남동쪽으로 이동';
    if (bearing >= 157.5 && bearing < 202.5) return '남쪽으로 이동';
    if (bearing >= 202.5 && bearing < 247.5) return '남서쪽으로 이동';
    if (bearing >= 247.5 && bearing < 292.5) return '서쪽으로 이동';
    return '북서쪽으로 이동';
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((point2.latitude - point1.latitude) * p) / 2 +
        c(point1.latitude * p) * c(point2.latitude * p) *
            (1 - c((point2.longitude - point1.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * math.pi / 180;
    double lon1 = start.longitude * math.pi / 180;
    double lat2 = end.latitude * math.pi / 180;
    double lon2 = end.longitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }
  void _startRecording() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '회원님께서 만드신 경로는',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Warn/bell.png',
                      width: 200,
                      height: 200,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Warn/Crossing.png',
                              width: 24,
                              height: 24,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '인구 밀집지역',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Warn/Crosswalk.png',
                              width: 24,
                              height: 24,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '횡단 보도',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Warn/Crossroad.png',
                              width: 24,
                              height: 24,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '골목길 교차로',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Warn/Uphill.png',
                              width: 24,
                              height: 24,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '경사로',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  '주의',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '해주시기 바랍니다.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (_currentLocation != null) {
                        final GoogleMapController controller = await _mapController.future;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                _currentLocation!.latitude!,
                                _currentLocation!.longitude!,
                              ),
                              zoom: 19,
                              tilt: 45,
                            ),
                          ),
                        );
                      }
                      setState(() {
                        _isRecording = true;
                        _isNavigating = true;
                        _recordDuration = Duration.zero;
                        _recordedRoute = [];
                        if (_currentLocation != null) {
                          _recordedRoute.add(
                              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                          );
                        }
                      });
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDEDE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration += const Duration(seconds: 1);
      });
    });
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 종료'),
        content: const Text('운동을 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stopAndShowResult();
            },
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  void _stopAndShowResult() {
    _timer?.cancel();

    if (_recordedRoute.isEmpty && _currentLocation != null) {
      _recordedRoute.add(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
      );
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
            onMapCreated: (controller) {
              _mapController.complete(controller);
              _showEntireRoute();
            },
            initialCameraPosition: CameraPosition(
              target: widget.selectedRoute['points'][0],
              zoom: 15,
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
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          if (_isRecording)
            Positioned(
              top: 180,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  _formatDuration(_recordDuration),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (_isNavigating)
            Positioned(
              top: 50,
              left: 80,
              right: 70,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _navigationInstruction,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_remainingDistance > 0)
                      Text(
                        '다음 지점까지 ${_remainingDistance.toStringAsFixed(0)}m',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
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
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '예상 거리',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${widget.selectedRoute['distance'].toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                        onPressed: _showStopConfirmation,
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

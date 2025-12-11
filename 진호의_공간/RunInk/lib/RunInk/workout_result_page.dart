import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class WorkoutResultPage extends StatefulWidget {
  final Duration duration;
  final List<LatLng> recordedRoute;
  final double distance;

  const WorkoutResultPage({
    Key? key,
    required this.duration,
    required this.recordedRoute,
    required this.distance,
  }) : super(key: key);

  @override
  State<WorkoutResultPage> createState() => _WorkoutResultPageState();
}

class _WorkoutResultPageState extends State<WorkoutResultPage> {
  final GlobalKey _globalKey = GlobalKey();
  String runningTitle = '러닝';

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
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

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

        await Share.shareXFiles(
          [XFile(file.path)],
          text: '러닝 결과',
          subject: runningTitle,
        );
      }
    } catch (e) {
      print('Error sharing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 공유 중 오류가 발생했습니다.')),
      );
    }
  }

  String _calculateCalories() {
    return (widget.distance * 60).toStringAsFixed(0);
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

  LatLng _calculateCenter(List<LatLng> route) {
    if (route.isEmpty) return const LatLng(37.504444, 127.027680);

    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (var point in route) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
  }

  double _calculateZoomLevel(List<LatLng> route) {
    if (route.isEmpty) return 14;

    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (var point in route) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = math.max(latDiff, lngDiff);

    if (maxDiff <= 0.001) return 18;
    if (maxDiff <= 0.005) return 16;
    if (maxDiff <= 0.01) return 15;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('M/d/yyyy').format(DateTime.now());
    String pace = _calculatePace();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptions(context),
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
                formattedDate,
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
                    widget.distance.toStringAsFixed(2),
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
                '시간    ${_formatDuration(widget.duration)}'
                    '               칼로리   ${_calculateCalories()}\n\n'
                    '페이스   $pace',
                style: TextStyle(color: Colors.grey[200], fontSize: 17),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: widget.recordedRoute.isNotEmpty
                                ? _calculateCenter(widget.recordedRoute)
                                : const LatLng(37.504444, 127.027680),
                            zoom: _calculateZoomLevel(widget.recordedRoute),
                          ),
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId('recorded_route'),
                              points: widget.recordedRoute,
                              color: Colors.blue,
                              width: 5,
                            ),
                          },
                          myLocationEnabled: false,
                          zoomControlsEnabled: false,
                          mapType: MapType.normal,
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
                          '서울특별시',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String _calculatePace() {
    if (widget.distance <= 0) return "0'00\"";
    double timeInMinutes = widget.duration.inSeconds / 60;
    double paceMinutes = timeInMinutes / widget.distance;
    int paceMin = paceMinutes.floor();
    int paceSec = ((paceMinutes - paceMin) * 60).round();
    return "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";
  }

  double _calculateTotalDistance() {
    if (widget.recordedRoute.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 0; i < widget.recordedRoute.length - 1; i++) {
      totalDistance += _calculateDistance(
        widget.recordedRoute[i],
        widget.recordedRoute[i + 1],
      );
    }
    return totalDistance / 1000; // 미터를 킬로미터로 변환
  }

  double _calculateDistance(LatLng start, LatLng end) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((end.latitude - start.latitude) * p) / 2 +
        c(start.latitude * p) * c(end.latitude * p) *
            (1 - c((end.longitude - start.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)) * 1000; // 미터 단위로 반환
  }

  Widget _buildSummaryCard(String title, String value, {String? unit}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.recordedRoute.isNotEmpty
                ? _calculateCenter(widget.recordedRoute)
                : const LatLng(37.504444, 127.027680),
            zoom: _calculateZoomLevel(widget.recordedRoute),
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId('recorded_route'),
              points: widget.recordedRoute,
              color: Colors.blue,
              width: 5,
            ),
          },
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            controller.setMapStyle(_mapStyle);
          },
        ),
      ),
    );
  }

  // 다크 모드 맵 스타일
  static const String _mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#242f3e"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#746855"
          }
        ]
      }
    ]
  ''';

  // 운동 데이터 저장 메서드 (로컬 저장소나 데이터베이스에 저장할 수 있음)
  Future<void> _saveWorkoutData() async {
    // 예시: SharedPreferences를 사용한 저장
    // final prefs = await SharedPreferences.getInstance();
    // final workoutData = {
    //   'date': DateTime.now().toIso8601String(),
    //   'title': runningTitle,
    //   'distance': widget.distance,
    //   'duration': widget.duration.inSeconds,
    //   'route': widget.recordedRoute.map((point) =>
    //     {'lat': point.latitude, 'lng': point.longitude}).toList(),
    // };
    // await prefs.setString('lastWorkout', json.encode(workoutData));
  }
}
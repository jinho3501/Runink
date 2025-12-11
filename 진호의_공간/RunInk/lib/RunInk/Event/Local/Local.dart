import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:RunInk/RunInk/selected_route_page.dart';

class Local extends StatefulWidget {
  const Local({Key? key}) : super(key: key);

  @override
  State<Local> createState() => _MapPageState();
}

class _MapPageState extends State<Local> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final PageController _pageController = PageController();

  LatLng? _currentPosition;
  List<Map<String, dynamic>> _routes = [];
  Map<PolylineId, Polyline> _polylines = {};
  bool _isLoading = false;

  final String _apiUrl = 'http://43.203.107.133:8000/local';
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocationService();
  }

  Future<void> _moveToRoute(List<LatLng> points) async {
    if (points.isEmpty) return;

    try {
      final GoogleMapController controller = await _mapController.future;

      // 루트의 모든 좌표를 포함하는 경계 상자 계산
      double minLat = points[0].latitude;
      double maxLat = points[0].latitude;
      double minLng = points[0].longitude;
      double maxLng = points[0].longitude;

      for (LatLng point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      // 경계 상자로부터 LatLngBounds 생성
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      // 패딩을 포함하여 카메라 이동
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    } catch (e) {
      print('루트로 카메라 이동 오류: $e');
    }
  }

  Future<void> _initializeLocationService() async {
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) {
          print('위치 서비스가 비활성화되어 있습니다.');
          return;
        }
      }

      PermissionStatus permission = await _locationController.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _locationController.requestPermission();
        if (permission != PermissionStatus.granted) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      await _locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 5,
      );

      LocationData locationData = await _locationController.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        print('초기 위치: ${locationData.latitude}, ${locationData.longitude}');

        setState(() {
          _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        });

        _moveToCurrentLocation(locationData.latitude!, locationData.longitude!);
        await _fetchRouteFromApi(locationData.latitude!, locationData.longitude!);
      }

      _locationController.onLocationChanged.listen(
            (LocationData currentLocation) {
          print('위치 업데이트: ${currentLocation.latitude}, ${currentLocation.longitude}');
          if (currentLocation.latitude != null && currentLocation.longitude != null) {
            setState(() {
              _currentPosition = LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
            });
          }
        },
        onError: (error) {
          print('위치 업데이트 오류: $error');
        },
      );
    } catch (e) {
      print('위치 서비스 초기화 오류: $e');
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

  Future<void> _fetchRouteFromApi(double lat, double lng) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': "test",
          'location': {'latitude': lat, 'longitude': lng}
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          List<Map<String, dynamic>> routes = [];

          if (jsonData['sungsu_route']['sungsu_routes'] != null) {
            for (var route in jsonData['sungsu_route']['sungsu_routes']) {
              routes.add({
                'points': route.map<LatLng>((point) =>
                    LatLng(point['lat'].toDouble(), point['lng'].toDouble())
                ).toList(),
                'distance': jsonData['distance']['sungsu_distance'],
                'local': 'sungsu'
              });
            }
          }

          if (jsonData['snu_route']['snu_routes'] != null) {
            for (var route in jsonData['snu_route']['snu_routes']) {
              routes.add({
                'points': route.map<LatLng>((point) =>
                    LatLng(point['lat'].toDouble(), point['lng'].toDouble())
                ).toList(),
                'distance': jsonData['distance']['snu_distance'],
                'local': 'snu'
              });
            }
          }
          if (jsonData['my_route']['my_routes'] != null) {
            for (var route in jsonData['my_route']['my_routes']) {
              routes.add({
                'points': route.map<LatLng>((point) =>
                    LatLng(point['lat'].toDouble(), point['lng'].toDouble())
                ).toList(),
                'distance': jsonData['distance']['my_distance'],
                'local': 'my'
              });
            }
          }

          setState(() {
            _routes = routes;
            _renderPolylines();
          });

          // 첫 번째 루트로 카메라 이동
          if (routes.isNotEmpty) {
            _moveToRoute(routes[0]['points']);
          }
        }
      } else {
        print('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API call: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _renderPolylines() {
    _polylines.clear();
    for (int i = 0; i < _routes.length; i++) {
      if (i != _selectedPageIndex) {
        PolylineId id = PolylineId('route_$i');
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.grey[400]!,
          points: _routes[i]['points'],
          width: 3,
          zIndex: 1,
        );
        _polylines[id] = polyline;
      }
    }

    if (_selectedPageIndex < _routes.length) {
      PolylineId selectedId = PolylineId('route_$_selectedPageIndex');
      Polyline selectedPolyline = Polyline(
        polylineId: selectedId,
        color: Colors.black,
        points: _routes[_selectedPageIndex]['points'],
        width: 5,
        zIndex: 2,
      );
      _polylines[selectedId] = selectedPolyline;
    }
  }

  Widget _buildRouteCard(String title, double distance, String duration, String address, int index) {
    final route = _routes[index];
    final String local = route['local'];
    String imagePath;
    String displayText;

    if (local == 'sungsu') {
      imagePath = 'assets/Local/sakura.jpeg';
      displayText = '성수 벚꽃런';
    } else if (local == 'snu'){
      imagePath = 'assets/Local/snu.jpeg';
      displayText = '서울대 샤런';
    } else {
    imagePath = 'assets/Local/my.jpeg';
    displayText = '명동 십자가런';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedRoutePage(
              selectedRoute: _routes[index],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _selectedPageIndex == index ? Colors.black.withAlpha(160) : Colors.grey[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(width: 15),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.map, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayText,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('Easy',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Text('${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(width: 8),
                        Text('$duration m',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(address,
                        style: const TextStyle(color: Colors.white54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_currentPosition == null)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              onMapCreated: (controller) => _mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              polylines: Set<Polyline>.of(_polylines.values),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: true,
            ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _routes.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedPageIndex = index;
                    _renderPolylines();
                  });
                  _moveToRoute(_routes[index]['points']);
                },
                itemBuilder: (context, index) {
                  final route = _routes[index];
                  return _buildRouteCard(
                    'Route ${index + 1}',
                    route['distance'].toDouble(),
                    '30',
                    'Seoul, Korea',
                    index,
                  );
                },
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
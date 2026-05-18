import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:RunInk/RunInk/selected_route_page.dart';
import 'dart:io';
import 'package:RunInk/Image_route_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final PageController _pageController = PageController();

  LatLng? _currentPosition;
  List<Map<String, dynamic>> _routes = [];
  Map<PolylineId, Polyline> _polylines = {};

  final String _apiUrl = 'http://43.203.107.133:8000/message';
  int _selectedPageIndex = 0;

  bool _isLoading = false;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _moveToRoute(List<LatLng> points) async {
    if (points.isEmpty) return;

    try {
      final GoogleMapController controller = await _mapController.future;

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

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    } catch (e) {
      print('루트로 카메라 이동 오류: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) {
          print('위치 서비스가 비활성화되어 있습니다.');
          return;
        }
      }

      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      await _locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000,
      );

      final locationData = await _locationController.getLocation();
      print('실제 위치 받아옴 - 위도: ${locationData.latitude}, 경도: ${locationData.longitude}');

      if (locationData.latitude == null || locationData.longitude == null) {
        print('위치 정보를 가져올 수 없습니다.');
        return;
      }

      setState(() {
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });

      if (_currentPosition != null) {
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 14,
            ),
          ),
        );

        await _fetchRouteFromApi(_currentPosition!.latitude, _currentPosition!.longitude);
      }

      _locationController.onLocationChanged.listen(
            (LocationData currentLocation) {
          print('위치 업데이트 - 위도: ${currentLocation.latitude}, 경도: ${currentLocation.longitude}');
          if (currentLocation.latitude != null &&
              currentLocation.longitude != null &&
              (currentLocation.latitude != 37.785834 ||
                  currentLocation.longitude != -122.406417)) {
            setState(() {
              _currentPosition = LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
            });
          }
        },
        onError: (err) {
          print('위치 업데이트 에러: $err');
        },
      );
    } catch (e) {
      print('위치 가져오기 에러: $e');
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

          // Heart routes
          for (var route in jsonData['heart_route']['heart_routes']) {
            routes.add({
              'points': route
                  .map<LatLng>((point) => LatLng(point['lat'], point['lng']))
                  .toList(),
              'distance': double.tryParse(
                  jsonData['distance']['heart_distance'].toString()) ??
                  0.0,
            });
          }

          // Square routes
          for (var route in jsonData['square_route']['square_routes']) {
            routes.add({
              'points': route
                  .map<LatLng>((point) => LatLng(point['lat'], point['lng']))
                  .toList(),
              'distance': double.tryParse(
                  jsonData['distance']['square_distance'].toString()) ??
                  0.0,
            });
          }

          // Star routes
          for (var route in jsonData['star_route']['star_routes']) {
            routes.add({
              'points': route
                  .map<LatLng>((point) => LatLng(point['lat'], point['lng']))
                  .toList(),
              'distance': double.tryParse(
                  jsonData['distance']['star_distance'].toString()) ??
                  0.0,
            });
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

  void addNewRoute(Map<String, dynamic> routeData) {
    setState(() {
      List<LatLng> points = [];

      var routePoints = routeData['route']['routes'][0];
      for (var point in routePoints) {
        points.add(LatLng(
            point['lat'],
            point['lng']
        ));
      }

      Map<String, dynamic> newRoute = {
        'points': points,
        'distance': routeData['distance']['route_distance'],
        'url': routeData['url'],
      };

      _routes.add(newRoute);
      _renderPolylines();

      _pageController.animateToPage(
        _routes.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (points.isNotEmpty) {
        _moveToRoute(points);
      }
    });
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
          width: 5,
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
    String routeTitle;
    String imagePath;
    if (index % 3 == 0) {
      routeTitle = 'Heart';
      imagePath = 'assets/Ink/Heart.png';
    } else if (index % 3 == 1) {
      routeTitle = 'Square';
      imagePath = 'assets/Ink/Square.jpeg';
    } else {
      routeTitle = 'Star';
      imagePath = 'assets/Ink/Star.jpeg';
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
          color: _selectedPageIndex == index
              ? Colors.black.withAlpha(160)
              : Colors.grey[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(width: 15),
            ClipRRect(
              borderRadius: const BorderRadius.all(
                  Radius.circular(20)),
              child: Container(
                width: 100,
                height: 100,
                child: _routes[index]['url'] != null
                    ? Image.network(
                  _routes[index]['url'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.map, color: Colors.grey),
                )
                    : Image.asset(
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
                    Text(routeTitle,
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageRoutePage(
            image: _imageFile!,
            onRouteCreated: addNewRoute,
          ),
        ),
      );
    }
  }

  void _showOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.image),
                        title: Text('이미지로 경로 추가'),
                        onTap: () {
                          _pickImage();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('목표지점 설정'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                zoom: 14,
              ),
              polylines: Set<Polyline>.of(_polylines.values),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
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
                itemBuilder: (context, index) => _buildRouteCard(
                  '',
                  _routes[index]['distance'],
                  '30',
                  'Seoul, Korea',
                  index,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 230,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showOverlay,
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.grey[700],
              shape: CircleBorder(),
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
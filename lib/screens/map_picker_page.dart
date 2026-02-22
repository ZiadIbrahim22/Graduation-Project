import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/custom_button.dart';
import '../services/localization_service.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage>
    with SingleTickerProviderStateMixin {
  // إحداثيات افتراضية (القاهرة)
  LatLng _currentPosition = const LatLng(30.0444, 31.2357);
  final MapController _mapController = MapController();
  String _currentAddress = "Loading address...";
  LatLng? _markerPosition;
  bool _isLoading = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _determinePosition();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setInitialPosition(_currentPosition);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setInitialPosition(_currentPosition);
        return;
      }
    }

    // جلب الإحداثيات الحقيقية
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 10),
    );
    LatLng userLatLng = LatLng(position.latitude, position.longitude);

    _setInitialPosition(userLatLng);
  }

  void _setInitialPosition(LatLng pos) {
    if (mounted) {
      setState(() {
        _currentPosition = pos;
        _markerPosition = pos;
        _isLoading = false;
      });
      _mapController.move(pos, 14.0);
      _updateAddress(pos);
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    if (!mounted) return;
    setState(() => _currentAddress = "loading_address".tr);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
          setState(() {
            _currentAddress = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
            .replaceAll(", ,", ",") // تنظيف الفواصل الزائدة
            .trim();
            if (_currentAddress.startsWith(",")) _currentAddress = _currentAddress.substring(1).trim();
          });
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = "unknown_location".tr);
      print("Error getting address: $e");
    }
  }

  void _onTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _markerPosition = position;
    });
    _updateAddress(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('select_location'.tr,
              style: const TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition,
                    initialZoom: 14.0,
                    onTap: _onTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.project_08',
                    ),
                    if (_markerPosition != null)
                      MarkerLayer(
                        markers: _markerPosition == null ? [] : [
                          Marker(
                            point: _markerPosition!,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    child:
                        const Icon(Icons.my_location, color: Color(0xFF1e3a8a)),
                    onPressed: () => _determinePosition(),
                  ),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF1e3a8a)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_currentAddress,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'confirm_location'.tr,
                          onPressed: (_markerPosition == null || _currentAddress.contains("Loading")) ? null : () {
                            Navigator.pop(context, {
                              'address': _currentAddress,
                              'lat': _markerPosition?.latitude,
                              'lng': _markerPosition?.longitude,
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

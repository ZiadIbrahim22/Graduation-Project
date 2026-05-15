import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with TickerProviderStateMixin {
  LatLng _currentPosition = const LatLng(30.0444, 31.2357);
  final MapController _mapController = MapController();

  String _currentAddress = "";

  bool _isLoadingLocation = true;
  bool _isLoadingAddress = false;
  bool _mapReady = false;

  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // ✅ Pulse animation للـ Marker الثابت
  late AnimationController _pulseController;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _determinePosition();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pulseController.dispose();
    _animController.dispose();
    super.dispose();
  }







  void _showLocationDialog({required bool openAppSettings}) {
      if (!mounted) return;

      showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── أيقونة ──
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1e3a8a).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  size: 36,
                  color: const Color(0xFF1e3a8a),
                ),
              ),
              const SizedBox(height: 16),

              // ── العنوان ──
              Text(
                openAppSettings
                    ? 'location_permission_denied'.tr
                    : 'location_services_disabled'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // ── الرسالة ──
              Text(
                openAppSettings
                    ? 'location_permission_denied_desc'.tr
                    : 'location_services_disabled_desc'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // ── الأزرار ──
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Open Settings
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (openAppSettings) {
                          await Geolocator.openAppSettings();
                        } else {
                          await Geolocator.openLocationSettings();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1e3a8a),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'open_settings'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _determinePosition() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showLocationDialog(openAppSettings: false);
          _setInitialPosition(_currentPosition);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showLocationDialog(
            openAppSettings: permission == LocationPermission.deniedForever,
          );
          _setInitialPosition(_currentPosition);
        }
        return;
      }

      // ✅ جرب last known position أولاً كـ fallback سريع
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && mounted) {
          _setInitialPosition(LatLng(lastKnown.latitude, lastKnown.longitude));
        }
      } catch (_) {}

      // ✅ Fix: استخدم Platform-specific settings بدل LocationSettings
      final locationSettings = Platform.isAndroid
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 15),
            )
          : AppleSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (mounted) {
        _setInitialPosition(LatLng(position.latitude, position.longitude));
      }
    } on TimeoutException {
      if (mounted) {
        _setInitialPosition(_currentPosition);
      }
    } on PermissionDefinitionsNotFoundException catch (e) {
      // ✅ Fix: بيمسك لو الـ permissions مش موجودة في AndroidManifest
      debugPrint("Permission not defined in manifest: $e");
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission not configured.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on PlatformException catch (e) {
      // ✅ Fix: بيمسك أي PlatformException من الـ native code
      debugPrint("Platform location error: $e");
      if (mounted) {
        _setInitialPosition(_currentPosition);
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        _setInitialPosition(_currentPosition);
      }
    }
  }








  void _setInitialPosition(LatLng pos) {
    if (!mounted) return;
    setState(() {
      _currentPosition = pos;
      _isLoadingLocation = false;
    });

    if (_mapReady) {
      _mapController.move(pos, 16.0);
    }
    _updateAddress(pos);
  }

  Future<void> _updateAddress(LatLng position) async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 8));

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.country,
        ].where((p) => p != null && p.isNotEmpty).toList();

        setState(() {
          _currentAddress = parts.join(', ');
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "unknown_location".tr;
          _isLoadingAddress = false;
        });
      }
    }
  }

  // ✅ لما الخريطة تتوقف عن التحريك — نجيب العنوان الجديد
  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      final center = _mapController.camera.center;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _updateAddress(center);
      });
    }
  }

  bool get _canConfirm =>
      !_isLoadingAddress &&
      _currentAddress.isNotEmpty &&
      !_currentAddress.contains("unknown");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'select_location'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Stack(
            children: [
              // ── الخريطة بتتحرك بحرية ──
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 16.0,
                  onMapReady: () {
                    setState(() => _mapReady = true);
                    _mapController.move(_currentPosition, 16.0);
                  },
                  // ✅ بنسمع لما الخريطة تخلص التحريك
                  onMapEvent: _onMapEvent,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.project_08',
                  ),
                ],
              ),

              // ── الماركر ثابت في نص الشاشة ──
              IgnorePointer(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // الـ Pin نفسه
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF1e3a8a),
                            size: 50,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // ── زرار My Location ──
              Positioned(
                top: 20,
                right: 20,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _isLoadingLocation ? null : _determinePosition,
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.my_location,
                          color: Color(0xFF1e3a8a),
                        ),
                ),
              ),

              // ── Loading overlay ──
              if (_isLoadingLocation)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),

              // ── Bottom Sheet ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1e3a8a)
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: const Color(0xFF1e3a8a),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _isLoadingAddress
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                    Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'loading_address'.tr,
                                                style: TextStyle(
                                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'selected_location'.tr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _currentAddress.isEmpty
                                                    ? 'select_location_on_map'
                                                        .tr
                                                    : _currentAddress,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: _currentAddress.isEmpty
                                                      ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey
                                                      : Colors.black87,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'confirm_location'.tr,
                                onPressed: _canConfirm
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        final center =
                                            _mapController.camera.center;
                                        Navigator.pop(context, {
                                          'address': _currentAddress,
                                          'lat': center.latitude,
                                          'lng': center.longitude,
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import '../widgets/custom_button.dart';
// import '../services/localization_service.dart';

// class MapPickerPage extends StatefulWidget {
//   const MapPickerPage({super.key});

//   @override
//   State<MapPickerPage> createState() => _MapPickerPageState();
// }

// class _MapPickerPageState extends State<MapPickerPage>
//     with TickerProviderStateMixin {
//   LatLng _currentPosition = const LatLng(30.0444, 31.2357);
//   final MapController _mapController = MapController();

//   String _currentAddress = "";
//   LatLng? _markerPosition;

//   bool _isLoadingLocation = true;
//   bool _isLoadingAddress = false;
//   bool _mapReady = false;

//   late AnimationController _animController;
//   late Animation<double> _fade;
//   late Animation<Offset> _slide;

//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   late AnimationController _bounceController;
//   late Animation<double> _bounceAnimation;

//   Timer? _debounceTimer;

//   @override
//   void initState() {
//     super.initState();

//     _animController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 600));
//     _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
//     _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();

//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _bounceController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
//     );

//     _determinePosition();
//   }

//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     _pulseController.dispose();
//     _bounceController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   Future<void> _determinePosition() async {
//     if (!mounted) return;
//     setState(() => _isLoadingLocation = true);

//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         if (mounted) {
//           _showLocationError('location_services_disabled'.tr);
//           _setInitialPosition(_currentPosition);
//         }
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           _showLocationError('location_permission_denied'.tr);
//           _setInitialPosition(_currentPosition);
//         }
//         return;
//       }

//       try {
//         final lastKnown = await Geolocator.getLastKnownPosition();
//         if (lastKnown != null && mounted) {
//           final quickPos = LatLng(lastKnown.latitude, lastKnown.longitude);
//           _setInitialPosition(quickPos);
//         }
//       } catch (_) {}

//       final position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           timeLimit: Duration(seconds: 15),
//         ),
//       );

//       if (mounted) {
//         _setInitialPosition(LatLng(position.latitude, position.longitude));
//       }
//     } on TimeoutException {
//       if (mounted && _markerPosition == null) {
//         _setInitialPosition(_currentPosition);
//         _showLocationError('location_timeout'.tr);
//       }
//     } catch (e) {
//       debugPrint("Location error: $e");
//       if (mounted && _markerPosition == null) {
//         _setInitialPosition(_currentPosition);
//       }
//     }
//   }

//   void _setInitialPosition(LatLng pos) {
//     if (!mounted) return;
//     setState(() {
//       _currentPosition = pos;
//       _markerPosition = pos;
//       _isLoadingLocation = false;
//     });

//     if (_mapReady) {
//       _mapController.move(pos, 15.0);
//     }
//     _updateAddress(pos);
//     _bounceController.forward(from: 0);
//   }

//   Future<void> _updateAddress(LatLng position) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoadingAddress = true;
//       _currentAddress = "";
//     });

//     try {
//       final placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       ).timeout(const Duration(seconds: 8));

//       if (placemarks.isNotEmpty && mounted) {
//         final place = placemarks.first;
//         final parts = [
//           place.street,
//           place.subLocality,
//           place.locality,
//           place.country,
//         ].where((p) => p != null && p.isNotEmpty).toList();

//         setState(() {
//           _currentAddress = parts.join(', ');
//           _isLoadingAddress = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _currentAddress = "unknown_location".tr;
//           _isLoadingAddress = false;
//         });
//       }
//     }
//   }

//   void _onMapTap(TapPosition tapPosition, LatLng position) {
//     HapticFeedback.mediumImpact();

//     setState(() => _markerPosition = position);

//     if (_mapReady) {
//       _mapController.move(position, 15.0);
//     }

//     _bounceController.forward(from: 0);

//     _debounceTimer?.cancel();
//     setState(() => _isLoadingAddress = true);
//     _debounceTimer = Timer(const Duration(milliseconds: 400), () {
//       _updateAddress(position);
//     });
//   }

//   void _showLocationError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.orange,
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   bool get _canConfirm =>
//       _markerPosition != null &&
//       !_isLoadingAddress &&
//       _currentAddress.isNotEmpty &&
//       !_currentAddress.contains("unknown");

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'select_location'.tr,
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: FadeTransition(
//         opacity: _fade,
//         child: SlideTransition(
//           position: _slide,
//           child: Stack(
//             children: [
//               // ── الخريطة ──
//               FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   initialCenter: _currentPosition,
//                   initialZoom: 15.0,
//                   onTap: _onMapTap,
//                   onMapReady: () {
//                     setState(() => _mapReady = true);
//                     if (_markerPosition != null) {
//                       _mapController.move(_markerPosition!, 15.0);
//                     }
//                   },
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     userAgentPackageName: 'com.example.project_08',
//                   ),
//                   // ✅ MarkerLayer محسّن بدون Overflow
//                   if (_markerPosition != null)
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           point: _markerPosition!,
//                           width: 70,
//                           height: 110,
//                           alignment: Alignment.topCenter,
//                           child: AnimatedBuilder(
//                             animation: Listenable.merge([
//                               _pulseController,
//                               _bounceController,
//                             ]),
//                             builder: (context, child) {
//                               final bounce = _bounceAnimation.value;
//                               final pulse = _pulseAnimation.value;

//                               return Transform.translate(
//                                 offset: Offset(0, -30 * (1 - bounce)),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     // Pulse ring
//                                     Container(
//                                       width: 32 * pulse,
//                                       height: 32 * pulse,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: const Color(0xFF1e3a8a)
//                                             .withOpacity(0.12 * (2 - pulse)),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     // الـ Pin
//                                     Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF1e3a8a),
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: Colors.white,
//                                           width: 3,
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: const Color(0xFF1e3a8a)
//                                                 .withOpacity(0.35),
//                                             blurRadius: 10,
//                                             spreadRadius: 1,
//                                           ),
//                                         ],
//                                       ),
//                                       child: const Icon(
//                                         Icons.location_on,
//                                         color: Colors.white,
//                                         size: 22,
//                                       ),
//                                     ),
//                                     // الظل
//                                     Container(
//                                       width: 12,
//                                       height: 3,
//                                       margin: const EdgeInsets.only(top: 3),
//                                       decoration: BoxDecoration(
//                                         color: Colors.black.withOpacity(0.18),
//                                         borderRadius: BorderRadius.circular(2),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),

//               // ── زرار My Location ──
//               Positioned(
//                 top: 20,
//                 right: 20,
//                 child: FloatingActionButton.small(
//                   backgroundColor: Colors.white,
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   onPressed: _isLoadingLocation ? null : _determinePosition,
//                   child: _isLoadingLocation
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(
//                           Icons.my_location,
//                           color: Color(0xFF1e3a8a),
//                         ),
//                 ),
//               ),

//               // ── Loading overlay ──
//               if (_isLoadingLocation && _markerPosition == null)
//                 Container(
//                   color: Colors.black.withOpacity(0.3),
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation(Colors.white),
//                     ),
//                   ),
//                 ),

//               // ── Bottom Sheet ──
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(24)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.12),
//                         blurRadius: 24,
//                         offset: const Offset(0, -4),
//                       ),
//                     ],
//                   ),
//                   child: SafeArea(
//                     top: false,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Handle bar
//                         Container(
//                           margin: const EdgeInsets.only(top: 12, bottom: 8),
//                           width: 40,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF1e3a8a)
//                                           .withOpacity(0.1),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.location_on,
//                                       color: Color(0xFF1e3a8a),
//                                       size: 20,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _isLoadingAddress
//                                         ? Row(
//                                             children: [
//                                               SizedBox(
//                                                 width: 16,
//                                                 height: 16,
//                                                 child: CircularProgressIndicator(
//                                                   strokeWidth: 2,
//                                                   valueColor:
//                                                       AlwaysStoppedAnimation(
//                                                     Colors.grey.shade600,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                               Text(
//                                                 'loading_address'.tr,
//                                                 style: TextStyle(
//                                                   color: Colors.grey.shade600,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                         : Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'selected_location'.tr,
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey.shade500,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 _currentAddress.isEmpty
//                                                     ? 'select_location_on_map'.tr
//                                                     : _currentAddress,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 15,
//                                                   color: _currentAddress.isEmpty
//                                                       ? Colors.grey
//                                                       : Colors.black87,
//                                                   height: 1.3,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               CustomButton(
//                                 text: 'confirm_location'.tr,
//                                 onPressed: _canConfirm
//                                     ? () {
//                                         HapticFeedback.mediumImpact();
//                                         Navigator.pop(context, {
//                                           'address': _currentAddress,
//                                           'lat': _markerPosition!.latitude,
//                                           'lng': _markerPosition!.longitude,
//                                         });
//                                       }
//                                     : null,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
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
  late Animation<double> _pulseAnimation;

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _determinePosition();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pulseController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showLocationError('location_services_disabled'.tr);
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
          _showLocationError('location_permission_denied'.tr);
          _setInitialPosition(_currentPosition);
        }
        return;
      }

      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && mounted) {
          final quickPos = LatLng(lastKnown.latitude, lastKnown.longitude);
          _setInitialPosition(quickPos);
        }
      } catch (_) {}

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (mounted) {
        _setInitialPosition(LatLng(position.latitude, position.longitude));
      }
    } on TimeoutException {
      if (mounted) {
        _setInitialPosition(_currentPosition);
        _showLocationError('location_timeout'.tr);
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

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
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
                      final pulse = _pulseAnimation.value;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // الـ Pin نفسه
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFFdc2626),
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
                  color: Colors.black.withOpacity(0.3),
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
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
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
                            color: Colors.grey.shade300,
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
                                      color: const Color(0xFFdc2626)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFdc2626),
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
                                                    Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'loading_address'.tr,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
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
                                                  color: Colors.grey.shade500,
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
                                                      ? Colors.grey
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

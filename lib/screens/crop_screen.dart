import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:reporting_system/services/localization_service.dart';

class CropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const CropScreen({super.key, required this.imageBytes});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen>
    with SingleTickerProviderStateMixin {
  final _controller = CropController();
  bool _isCropping = false;

  // ── Animation controllers ──
  late AnimationController _successController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  /// يعرض الـ overlay الجميل ثم يرجع البيانات للصفحة السابقة
  Future<void> _showSuccessAndPop(Uint8List croppedImage) async {
    setState(() => _isCropping = false);

    // شغّل الـ animation
    await _successController.forward();

    // استنى لحظة عشان المستخدم يشوف الـ overlay
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) Navigator.pop(context, croppedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e3a8a),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          'crop_image'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          _isCropping
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    setState(() => _isCropping = true);
                    _controller.crop();
                  },
                  child: Text(
                    'done'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
      body: Stack(
        children: [
          // ── Crop widget ──
          Crop(
            image: widget.imageBytes,
            controller: _controller,
            aspectRatio: 1,
            withCircleUi: true,
            onCropped: (result) {
              if (result is CropSuccess) {
                _showSuccessAndPop(result.croppedImage);
              } else {
                Navigator.pop(context, null);
              }
            },
          ),

          // ── Success Overlay ──
          AnimatedBuilder(
            animation: _successController,
            builder: (context, _) {
              if (_successController.value == 0) return const SizedBox.shrink();
              return FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Animated Check Icon ──
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Updated_successfully'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1e3a8a),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Image_cropped_successfully'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


// import 'dart:typed_data';
// import 'package:crop_your_image/crop_your_image.dart';
// import 'package:flutter/material.dart';
// import 'package:reporting_system/services/localization_service.dart';

// class CropScreen extends StatefulWidget {
//   final Uint8List imageBytes;
//   const CropScreen({super.key, required this.imageBytes});

//   @override
//   State<CropScreen> createState() => _CropScreenState();
// }

// class _CropScreenState extends State<CropScreen> {
//   final _controller = CropController();
//   bool _isCropping = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1e3a8a),
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context, null),
//         ),
//         title: Text(
//           'crop_image'.tr,
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           _isCropping
//               ? const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   ),
//                 )
//               : TextButton(
//                   onPressed: () {
//                     setState(() => _isCropping = true);
//                     _controller.crop();
//                   },
//                   child: Text(
//                     'done'.tr,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//       body: Crop(
//         image: widget.imageBytes,
//         controller: _controller,
//         aspectRatio: 1,
//         withCircleUi: true, // ✅ شكل دايري زي الـ avatar
//         onCropped: (result) {
//           if (result is CropSuccess) {
//             Navigator.pop(context, result.croppedImage);
//           } else {
//             Navigator.pop(context, null);
//           }
//         },
//       ),
//     );
//   }
// }
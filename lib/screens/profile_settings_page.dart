// import 'dart:io';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:reporting_system/config/api_config.dart';
// import 'package:reporting_system/services/api_service.dart';
// import 'package:reporting_system/services/theme_service.dart';
// import 'change_email_page.dart';
// import 'change_password_page.dart';
// import '../services/localization_service.dart';
// import '../services/user_service.dart';
// import '../models/user_model.dart';
// import 'package:path_provider/path_provider.dart';
// import 'crop_screen.dart';
// import 'dart:typed_data';

// // ── Zoomable image dialog ──────────────────────────────────────────────────
// class _ZoomableImageDialog extends StatefulWidget {
//   final File? image;
//   final String? imageUrl;

//   const _ZoomableImageDialog({this.image, this.imageUrl});

//   @override
//   State<_ZoomableImageDialog> createState() => _ZoomableImageDialogState();
// }

// class _ZoomableImageDialogState extends State<_ZoomableImageDialog>
//     with SingleTickerProviderStateMixin {
//   final TransformationController _transformController =
//       TransformationController();
//   late AnimationController _animController;
//   Animation<Matrix4>? _animation;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     )..addListener(() {
//         if (_animation != null) {
//           _transformController.value = _animation!.value;
//         }
//       });
//   }

//   @override
//   void dispose() {
//     _transformController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   void _resetZoom() {
//     _animation = Matrix4Tween(
//       begin: _transformController.value,
//       end: Matrix4.identity(),
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward(from: 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final user = UserService().currentUser.value;
//     final initial = user?.fullName.isNotEmpty == true
//         ? user!.fullName[0].toUpperCase()
//         : '?';

//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.zero,
//       child: InteractiveViewer(
//         transformationController: _transformController,
//         minScale: 1.0,
//         maxScale: 3.0,
//         onInteractionEnd: (_) => _resetZoom(),
//         child: Hero(
//           tag: 'profile_image',
//           transitionOnUserGestures: true,
//           child: Container(
//             width: 300,
//             height: 300,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: widget.image != null
//                 ? Image.file(
//                     widget.image!,
//                     fit: BoxFit.cover,
//                   )
//                 : Image.network(
//                     widget.imageUrl!,
//                     fit: BoxFit.cover,
//                     // ✅ FIX: لو فشل التحميل، نظهر placeholder دايرة
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 300,
//                         height: 300,
//                         decoration: BoxDecoration(
//                           gradient: isDark
//                               ? const LinearGradient(
//                                   colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 )
//                               : const LinearGradient(
//                                   colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 ),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             initial,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 120,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: -2,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Theme Toggle Widget ───────────────────────────────────────────────────
// class ThemeToggle extends StatelessWidget {
//   final bool isDark;
//   final VoidCallback onToggle;

//   const ThemeToggle({super.key, required this.isDark, required this.onToggle});

//   @override
//   Widget build(BuildContext context) {
//     final bool isRtl = Directionality.of(context) == TextDirection.rtl;

//     return GestureDetector(
//       onTap: onToggle,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (!isRtl) ...[
//             _lightLabel(),
//             const SizedBox(width: 12),
//             _toggleBody(),
//             const SizedBox(width: 12),
//             _darkLabel(),
//           ] else ...[
//             _darkLabel(),
//             const SizedBox(width: 12),
//             _toggleBody(),
//             const SizedBox(width: 12),
//             _lightLabel(),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _lightLabel() {
//     return AnimatedDefaultTextStyle(
//       duration: const Duration(milliseconds: 300),
//       style: TextStyle(
//         fontSize: 16,
//         fontWeight: !isDark ? FontWeight.bold : FontWeight.w600,
//         color: !isDark ? const Color(0xFF1a1a1a) : Colors.grey.shade500,
//       ),
//       child: Text('Light'.tr),
//     );
//   }

//   Widget _darkLabel() {
//     return AnimatedDefaultTextStyle(
//       duration: const Duration(milliseconds: 300),
//       style: TextStyle(
//         fontSize: 16,
//         fontWeight: isDark ? FontWeight.bold : FontWeight.w600,
//         color: isDark ? Colors.white : Colors.grey.shade500,
//       ),
//       child: Text('Dark'.tr),
//     );
//   }

//   Widget _toggleBody() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//       width: 100,
//       height: 44,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         color: isDark ? const Color(0xFF0f172a) : const Color(0xFF93c5fd),
//       ),
//       child: Stack(
//         children: [
//           if (!isDark) ...[
//             Positioned(right: 14, top: 10, child: _dot(5)),
//             Positioned(right: 22, top: 16, child: _dot(3)),
//             Positioned(right: 10, bottom: 10, child: _dot(4)),
//           ],
//           if (isDark) ...[
//             Positioned(left: 12, top: 8, child: _star(7)),
//             Positioned(left: 22, top: 16, child: _star(4)),
//             Positioned(left: 10, bottom: 10, child: _star(5)),
//             Positioned(left: 26, top: 8, child: _star(3)),
//           ],
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeInOut,
//             left: isDark ? 54 : 8,
//             top: 6,
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isDark ? const Color(0xFF0f172a) : Colors.white,
//               ),
//               child: isDark
//                   ? CustomPaint(
//                       size: const Size(32, 32),
//                       painter: _MoonPainter(),
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _dot(double size) => Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white.withOpacity(0.8),
//         ),
//       );

//   Widget _star(double size) => Container(
//         width: size,
//         height: size,
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//         ),
//       );
// }

// class _MoonPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.white;
//     canvas.drawCircle(
//       Offset(size.width * 0.4, size.height * 0.5),
//       size.width * 0.35,
//       paint,
//     );
//     final darkPaint = Paint()..color = const Color(0xFF0f172a);
//     canvas.drawCircle(
//       Offset(size.width * 0.62, size.height * 0.5),
//       size.width * 0.32,
//       darkPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // ── ProfileSettingsPage ───────────────────────────────────────────────────
// class ProfileSettingsPage extends StatefulWidget {
//   const ProfileSettingsPage({super.key});

//   @override
//   State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
// }

// class _ProfileSettingsPageState extends State<ProfileSettingsPage>
//     with TickerProviderStateMixin {
//   final ImagePicker _picker = ImagePicker();
//   File? _image;
//   bool _isUploadingImage = false;

//   late AnimationController _controller;
//   late Animation<double> _fade;
//   late Animation<Offset> _slide;

//   late AnimationController _successController;
//   late Animation<double> _scaleAnim;
//   late Animation<double> _fadeAnim;
//   bool _showSuccessOverlay = false;

//   @override
//   void initState() {
//     super.initState();
//     loadProfile();

//     _controller = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 600));
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//     _controller.forward();

//     _successController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _scaleAnim =
//         CurvedAnimation(parent: _successController, curve: Curves.elasticOut);
//     _fadeAnim =
//         CurvedAnimation(parent: _successController, curve: Curves.easeIn);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _successController.dispose();
//     super.dispose();
//   }

//   Future<void> _showUploadSuccess() async {
//     setState(() => _showSuccessOverlay = true);
//     _successController.reset();
//     await _successController.forward();
//     await Future.delayed(const Duration(milliseconds: 900));
//     if (mounted) {
//       setState(() => _showSuccessOverlay = false);
//       _successController.reset();
//     }
//   }

//   Future<void> loadProfile() async {
//     try {
//       final token = UserService().authToken;
//       if (token == null) return;

//       final data = await ApiService.fetchProfile(token);
//       if (!mounted) return;

//       final currentUser = UserService().currentUser.value;
//       if (currentUser != null) {
//         // ✅ FIX: دلوقتي بنجرب 'photoUrl' الأول وبعدين 'photo' كـ fallback
//         // عشان يكون متوافق مع كل الأماكن في التطبيق
//         String rawPhoto = data['photoUrl'] ?? data['photo'] ?? '';

//         String fullImageUrl = rawPhoto.isEmpty
//             ? ''
//             : (rawPhoto.startsWith('http')
//                 ? rawPhoto
//                 : '${ApiConfig.baseUrl}$rawPhoto');

//         final updatedUser = currentUser.copyWith(
//           fullName: data['fullName'] ?? currentUser.fullName,
//           email: data['email'] ?? currentUser.email,
//           profileImage:
//               fullImageUrl.isNotEmpty ? fullImageUrl : currentUser.profileImage,
//         );
//         await UserService().saveUser(updatedUser);

//         if (fullImageUrl.isNotEmpty && mounted) {
//           await precacheImage(NetworkImage(fullImageUrl), context);
//         }
//       }
//     } catch (_) {}
//   }

//   Future<File> _compressImage(File file, Directory tempDir) async {
//     final compressedBytes = await FlutterImageCompress.compressWithFile(
//       file.path,
//       quality: 60,
//     );
//     if (compressedBytes == null) return file;

//     final compressedFile = File(
//       '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
//     );
//     await compressedFile.writeAsBytes(compressedBytes);
//     return compressedFile;
//   }

//   Future<void> _pickImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile == null) return;

//     final imageBytes = await pickedFile.readAsBytes();
//     if (!mounted) return;

//     final Uint8List? croppedBytes = await Navigator.push<Uint8List>(
//       context,
//       MaterialPageRoute(builder: (_) => CropScreen(imageBytes: imageBytes)),
//     );
//     if (croppedBytes == null) return;

//     setState(() => _isUploadingImage = true);

//     try {
//       final tempDir = await getTemporaryDirectory();
//       File file = await File(
//         '${tempDir.path}/cropped_avatar.jpg',
//       ).writeAsBytes(croppedBytes);
//       file = await _compressImage(file, tempDir);

//       setState(() => _image = file);
//       await UserService().updateProfileImage(file);
//       await _showUploadSuccess();
//     } catch (_) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('upload_image_failed'.tr),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isUploadingImage = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'profile_settings'.tr,
//           style: const TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         backgroundColor: const Color(0xFF1e3a8a),
//         automaticallyImplyLeading: false,
//       ),
//       body: Stack(
//         children: [
//           RefreshIndicator(
//             onRefresh: loadProfile,
//             color: const Color(0xFF1e3a8a),
//             backgroundColor: Colors.white,
//             child: FadeTransition(
//               opacity: _fade,
//               child: SlideTransition(
//                 position: _slide,
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 30),

//                       // ── صورة البروفايل ──
//                       Center(
//                         child: ValueListenableBuilder<UserModel?>(
//                           valueListenable: UserService().currentUser,
//                           builder: (context, user, _) {
//                             if (user == null) return const SizedBox.shrink();
//                             final imageUrl = user.profileImage;
//                             return Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     if (_image == null &&
//                                         (imageUrl == null ||
//                                             imageUrl.isEmpty)) {
//                                       return;
//                                     }
//                                     showDialog(
//                                       context: context,
//                                       barrierColor: Colors.black87,
//                                       builder: (_) => _ZoomableImageDialog(
//                                         image: _image,
//                                         imageUrl: imageUrl,
//                                       ),
//                                     );
//                                   },
//                                   child: Hero(
//                                     tag: 'profile_image',
//                                     child: Container(
//                                       width: 100,
//                                       height: 100,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[800],
//                                         shape: BoxShape.circle,
//                                       ),
//                                       clipBehavior: Clip.antiAlias,
//                                       child: (imageUrl != null && imageUrl.isNotEmpty)
//                                           ? Image.network(
//                                               imageUrl,
//                                               fit: BoxFit.cover,
//                                               errorBuilder: (context, error, stackTrace) {
//                                                 return _buildPlaceholderAvatar(size: 100);
//                                               },
//                                             )
//                                           : _buildPlaceholderAvatar(size: 100),
//                                     ),
//                                   ),
//                                 ),
//                                 if (_isUploadingImage)
//                                   Container(
//                                     width: 100,
//                                     height: 100,
//                                     decoration: BoxDecoration(
//                                       color:
//                                           Colors.black.withValues(alpha: 0.4),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Center(
//                                       child: CircularProgressIndicator(
//                                           strokeWidth: 2),
//                                     ),
//                                   ),
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: GestureDetector(
//                                     onTap:
//                                         _isUploadingImage ? null : _pickImage,
//                                     child: Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: const BoxDecoration(
//                                         color: Color(0xFF1e3a8a),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(Icons.edit,
//                                           size: 20, color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // ── اسم المستخدم ──
//                       ValueListenableBuilder<UserModel?>(
//                         valueListenable: UserService().currentUser,
//                         builder: (context, user, _) {
//                           if (user == null) return const SizedBox.shrink();
//                           return Text(
//                             user.fullName,
//                             style: TextStyle(
//                               color: isDark
//                                   ? Colors.white
//                                   : const Color(0xFF1a1a1a),
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // ✅ FIX: ThemeToggle مستقل برا ValueListenableBuilder<UserModel?>
//                       // عشان يظهر حتى لو user كان null لأي سبب
//                       ValueListenableBuilder<ThemeMode>(
//                         valueListenable: ThemeService().themeMode,
//                         builder: (context, mode, _) {
//                           final dark = mode == ThemeMode.dark;
//                           return ThemeToggle(
//                             isDark: dark,
//                             onToggle: () => ThemeService().toggleTheme(),
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 30),

//                       // ── قائمة الإعدادات ──
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 20),
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).cardColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Column(
//                           children: [
//                             _buildListTile(Icons.person_outline, 'edit_email'),
//                             _buildDivider(),
//                             _buildListTile(
//                                 Icons.lock_outline, 'change_password'),
//                             _buildDivider(),
//                             _buildListTile(Icons.language, 'language'),
//                             const SizedBox(height: 50),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () => _showConfirmationDialog(
//                                   title: 'logout_confirm_title'.tr,
//                                   message: 'logout_confirm_msg'.tr,
//                                   onConfirm: () async =>
//                                       await UserService().logout(),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFff6b6b),
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 14),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'log_out'.tr,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 15),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // ── Success Overlay ──
//           if (_showSuccessOverlay)
//             AnimatedBuilder(
//               animation: _successController,
//               builder: (context, _) {
//                 return FadeTransition(
//                   opacity: _fadeAnim,
//                   child: Container(
//                     color: Colors.black.withValues(alpha: 0.6),
//                     alignment: Alignment.center,
//                     child: ScaleTransition(
//                       scale: _scaleAnim,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 36, vertical: 28),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.25),
//                               blurRadius: 20,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               width: 72,
//                               height: 72,
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     Color(0xFF1e3a8a),
//                                     Color(0xFF3b82f6)
//                                   ],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 ),
//                               ),
//                               child: const Icon(Icons.check_rounded,
//                                   color: Colors.white, size: 40),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'Updated_successfully'.tr,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1e3a8a),
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               'profile_updated_successfully'.tr,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceholderAvatar({required double size}) {
//     final user = UserService().currentUser.value;
//     final initial = user?.fullName.isNotEmpty == true
//         ? user!.fullName[0].toUpperCase()
//         : '?';
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         gradient: isDark
//             ? const LinearGradient(
//                 colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               )
//             : const LinearGradient(
//                 colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Text(
//           initial,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: size * 0.4,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showConfirmationDialog({
//     required String title,
//     required String message,
//     required Future<void> Function() onConfirm,
//   }) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('cancel'.tr),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await onConfirm();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFdc2626),
//               foregroundColor: Colors.white,
//             ),
//             child: Text('ok'.tr),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListTile(IconData icon, String titleKey) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Icon(icon, color: const Color(0xFF1e3a8a), size: 24),
//       title: Text(
//         titleKey.tr,
//         style: TextStyle(
//           color: isDark ? Colors.white : Colors.black,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       trailing:
//           const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//       onTap: () {
//         if (titleKey == 'edit_email') {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const ChangeEmailPage()));
//         } else if (titleKey == 'change_password') {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
//         } else if (titleKey == 'language') {
//           _showLanguageDialog();
//         }
//       },
//     );
//   }

//   void _showLanguageDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('change_language'.tr),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: const Text("English"),
//                 leading: Radio<String>(
//                   value: 'en',
//                   groupValue:
//                       LocalizationService.currentLocale.value.languageCode,
//                   onChanged: (value) {
//                     if (value != null) {
//                       LocalizationService().changeLocale(value);
//                       Navigator.pop(context);
//                     }
//                   },
//                 ),
//                 onTap: () {
//                   LocalizationService().changeLocale('en');
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text("العربية"),
//                 leading: Radio<String>(
//                   value: 'ar',
//                   groupValue:
//                       LocalizationService.currentLocale.value.languageCode,
//                   onChanged: (value) {
//                     if (value != null) {
//                       LocalizationService().changeLocale(value);
//                       Navigator.pop(context);
//                     }
//                   },
//                 ),
//                 onTap: () {
//                   LocalizationService().changeLocale('ar');
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDivider() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Divider(
//         height: 1,
//         color: isDark ? Colors.grey.shade700 : const Color(0xFFe5e7eb));
//   }
// }









































import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reporting_system/config/api_config.dart';
import 'package:reporting_system/services/api_service.dart';
import 'package:reporting_system/services/theme_service.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import '../services/localization_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'crop_screen.dart';
import 'dart:typed_data';

// ── Zoomable image dialog ──────────────────────────────────────────────────
class _ZoomableImageDialog extends StatefulWidget {
  final File? image;
  final String? imageUrl;

  const _ZoomableImageDialog({this.image, this.imageUrl});

  @override
  State<_ZoomableImageDialog> createState() => _ZoomableImageDialogState();
}

class _ZoomableImageDialogState extends State<_ZoomableImageDialog>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animation = Matrix4Tween(
      begin: _transformController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = UserService().currentUser.value;
    final initial = user?.fullName.isNotEmpty == true
        ? user!.fullName[0].toUpperCase()
        : '?';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 1.0,
        maxScale: 3.0,
        onInteractionEnd: (_) => _resetZoom(),
        child: Hero(
          tag: 'profile_image',
          transitionOnUserGestures: true,
          child: Container(
            width: 350,
            height: 350,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.image != null
                ? Image.file(
                    widget.image!,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 120,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Theme Toggle Widget ───────────────────────────────────────────────────
class ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeToggle({super.key, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isRtl) ...[
            _lightLabel(),
            const SizedBox(width: 12),
            _toggleBody(),
            const SizedBox(width: 12),
            _darkLabel(),
          ] else ...[
            _darkLabel(),
            const SizedBox(width: 12),
            _toggleBody(),
            const SizedBox(width: 12),
            _lightLabel(),
          ],
        ],
      ),
    );
  }

  Widget _lightLabel() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 16,
        fontWeight: !isDark ? FontWeight.bold : FontWeight.w600,
        color: !isDark ? const Color(0xFF1a1a1a) : Colors.grey.shade500,
      ),
      child: Text('Light'.tr),
    );
  }

  Widget _darkLabel() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 16,
        fontWeight: isDark ? FontWeight.bold : FontWeight.w600,
        color: isDark ? Colors.white : Colors.grey.shade500,
      ),
      child: Text('Dark'.tr),
    );
  }

  Widget _toggleBody() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 100,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF0f172a) : const Color(0xFF93c5fd),
      ),
      child: Stack(
        children: [
          if (!isDark) ...[
            Positioned(right: 14, top: 10, child: _dot(5)),
            Positioned(right: 22, top: 16, child: _dot(3)),
            Positioned(right: 10, bottom: 10, child: _dot(4)),
          ],
          if (isDark) ...[
            Positioned(left: 12, top: 8, child: _star(7)),
            Positioned(left: 22, top: 16, child: _star(4)),
            Positioned(left: 10, bottom: 10, child: _star(5)),
            Positioned(left: 26, top: 8, child: _star(3)),
          ],
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: isDark ? 54 : 8,
            top: 6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF0f172a) : Colors.white,
              ),
              child: isDark
                  ? CustomPaint(
                      size: const Size(32, 32),
                      painter: _MoonPainter(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
        ),
      );

  Widget _star(double size) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      );
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.5),
      size.width * 0.35,
      paint,
    );
    final darkPaint = Paint()..color = const Color(0xFF0f172a);
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.5),
      size.width * 0.32,
      darkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── ProfileSettingsPage ───────────────────────────────────────────────────
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isUploadingImage = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  late AnimationController _successController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();
    loadProfile();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim =
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut);
    _fadeAnim =
        CurvedAnimation(parent: _successController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _showUploadSuccess() async {
    setState(() => _showSuccessOverlay = true);
    _successController.reset();
    await _successController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _showSuccessOverlay = false);
      _successController.reset();
    }
  }

  Future<void> loadProfile() async {
    try {
      final token = UserService().authToken;
      if (token == null) return;

      final data = await ApiService.fetchProfile(token);
      if (!mounted) return;

      final currentUser = UserService().currentUser.value;
      if (currentUser != null) {
        String rawPhoto = data['photoUrl'] ?? data['photo'] ?? '';

        String fullImageUrl = rawPhoto.isEmpty
            ? ''
            : (rawPhoto.startsWith('http')
                ? rawPhoto
                : '${ApiConfig.baseUrl}$rawPhoto');

        final updatedUser = currentUser.copyWith(
          fullName: data['fullName'] ?? currentUser.fullName,
          email: data['email'] ?? currentUser.email,
          profileImage:
              fullImageUrl.isNotEmpty ? fullImageUrl : currentUser.profileImage,
        );
        await UserService().saveUser(updatedUser);

        if (fullImageUrl.isNotEmpty && mounted) {
          await precacheImage(NetworkImage(fullImageUrl), context);
        }
      }
    } catch (_) {}
  }

  Future<File> _compressImage(File file, Directory tempDir) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 60,
    );
    if (compressedBytes == null) return file;

    final compressedFile = File(
      '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await compressedFile.writeAsBytes(compressedBytes);
    return compressedFile;
  }

  // ✅ BottomSheet: Camera or Gallery
  Future<void> _showImagePickerSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Take Photo
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1e3a8a)),
                title: Text('take_photo'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.camera);
                },
              ),

              // Choose from Gallery
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1e3a8a)),
                title: Text('choose_from_gallery'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxHeight: 640,
      maxWidth: 640,
    );
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    final Uint8List? croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => CropScreen(imageBytes: imageBytes)),
    );
    if (croppedBytes == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final tempDir = await getTemporaryDirectory();
      File file = await File(
        '${tempDir.path}/cropped_avatar.jpg',
      ).writeAsBytes(croppedBytes);
      file = await _compressImage(file, tempDir);

      setState(() => _image = file);
      await UserService().updateProfileImage(file);
      await _showUploadSuccess();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('upload_image_failed'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'profile_settings'.tr,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: loadProfile,
            color: const Color(0xFF1e3a8a),
            backgroundColor: Colors.white,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // ── صورة البروفايل ──
                      Center(
                        child: ValueListenableBuilder<UserModel?>(
                          valueListenable: UserService().currentUser,
                          builder: (context, user, _) {
                            if (user == null) return const SizedBox.shrink();
                            final imageUrl = user.profileImage;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_image == null &&
                                        (imageUrl == null ||
                                            imageUrl.isEmpty)) {
                                      return;
                                    }
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black87,
                                      builder: (_) => _ZoomableImageDialog(
                                        image: _image,
                                        imageUrl: imageUrl,
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'profile_image',
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        shape: BoxShape.circle,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: (imageUrl != null && imageUrl.isNotEmpty)
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return _buildPlaceholderAvatar(size: 100);
                                              },
                                            )
                                          : _buildPlaceholderAvatar(size: 100),
                                    ),
                                  ),
                                ),
                                if (_isUploadingImage)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap:
                                        _isUploadingImage ? null : _showImagePickerSheet,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1e3a8a),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit,
                                          size: 20, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── اسم المستخدم ──
                      ValueListenableBuilder<UserModel?>(
                        valueListenable: UserService().currentUser,
                        builder: (context, user, _) {
                          if (user == null) return const SizedBox.shrink();
                          return Text(
                            user.fullName,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1a1a1a),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeService().themeMode,
                        builder: (context, mode, _) {
                          final dark = mode == ThemeMode.dark;
                          return ThemeToggle(
                            isDark: dark,
                            onToggle: () => ThemeService().toggleTheme(),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // ── قائمة الإعدادات ──
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildListTile(Icons.person_outline, 'edit_email'),
                            _buildDivider(),
                            _buildListTile(
                                Icons.lock_outline, 'change_password'),
                            _buildDivider(),
                            _buildListTile(Icons.language, 'language'),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showConfirmationDialog(
                                  title: 'logout_confirm_title'.tr,
                                  message: 'logout_confirm_msg'.tr,
                                  onConfirm: () async =>
                                      await UserService().logout(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFff6b6b),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'log_out'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Success Overlay ──
          if (_showSuccessOverlay)
            AnimatedBuilder(
              animation: _successController,
              builder: (context, _) {
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
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1e3a8a),
                                    Color(0xFF3b82f6)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Updated_successfully'.tr,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'profile_updated_successfully'.tr,
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

  Widget _buildPlaceholderAvatar({required double size}) {
    final user = UserService().currentUser.value;
    final initial = user?.fullName.isNotEmpty == true
        ? user!.fullName[0].toUpperCase()
        : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFdc2626),
              foregroundColor: Colors.white,
            ),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String titleKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF1e3a8a), size: 24),
      title: Text(
        titleKey.tr,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (titleKey == 'edit_email') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChangeEmailPage()));
        } else if (titleKey == 'change_password') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
        } else if (titleKey == 'language') {
          _showLanguageDialog();
        }
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('change_language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                leading: Radio<String>(
                  value: 'en',
                  groupValue:
                      LocalizationService.currentLocale.value.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      LocalizationService().changeLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  LocalizationService().changeLocale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("العربية"),
                leading: Radio<String>(
                  value: 'ar',
                  groupValue:
                      LocalizationService.currentLocale.value.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      LocalizationService().changeLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  LocalizationService().changeLocale('ar');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
        height: 1,
        color: isDark ? Colors.grey.shade700 : const Color(0xFFe5e7eb));
  }
}
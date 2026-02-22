import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reporting_system/config/api_config.dart';
import 'package:reporting_system/services/api_service.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import '../services/localization_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

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
  }

  Future<void> loadProfile() async {
    try {
      final token = UserService().authToken;
      if (token == null) return;

      final data = await ApiService.fetchProfile(token);

      final currentUser = UserService().currentUser.value;
      if (currentUser != null) {
        String rawPhoto = data['photo'] ?? ""; 
        String fullImageUrl = rawPhoto.isEmpty 
            ? "" 
            : (rawPhoto.startsWith('http') ? rawPhoto : '${ApiConfig.baseUrl}$rawPhoto');

        final updatedUser = currentUser.copyWith(
          fullName: data['fullName'] ?? currentUser.fullName,
          email: data['email'] ?? currentUser.email,
          profileImage: fullImageUrl, 
        );
        await UserService().saveUser(updatedUser);
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<File> _compressImage(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 70,
    );

    final compressedFile = File(file.path)..writeAsBytesSync(compressedBytes!);

    return compressedFile;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      File file = File(pickedFile.path);
      file = await _compressImage(file);
      setState(() {
        _image = file;
      });

      await UserService().updateProfileImage(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: Text(
          'profile_settings'.tr,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        automaticallyImplyLeading: false,
        actions: const [],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Avatar Section
                Center(
                  child: Stack(
                    children: [
                      ValueListenableBuilder<UserModel?>(
                        valueListenable: UserService().currentUser,
                        builder: (context, user, child) {
                          String? imageUrl = user?.profileImage;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[800],
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : (imageUrl != null && imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : null) as ImageProvider?,
                                child: (_image == null &&
                                        (imageUrl == null || imageUrl.isEmpty))
                                    ? const Icon(Icons.person,
                                        size: 65, color: Colors.white)
                                    : null,
                              ),
                              if (_isUploadingImage)
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
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
                                  onTap: _isUploadingImage ? null : _pickImage,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<UserModel?>(
                  valueListenable: UserService().currentUser,
                  builder: (context, user, _) {
                    return Column(
                      children: [
                        Text(
                          user?.fullName ?? 'user'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? 'email'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Menu Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(Icons.person_outline, 'edit_email'.tr),
                      _buildDivider(),
                      _buildListTile(Icons.lock_outline, 'change_password'.tr),
                      _buildDivider(),
                      _buildListTile(Icons.language, 'language'.tr),

                      const SizedBox(height: 50),

                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showConfirmationDialog(
                            title: 'logout_confirm_title'.tr,
                            message: 'logout_confirm_msg'.tr,
                            onConfirm: () {
                              UserService().logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFff6b6b), // Coral Red
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
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
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(
        titleKey.tr,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (titleKey == "edit_email".tr) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ChangeEmailPage()));
        } else if (titleKey == "change_password".tr) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage()));
        } else if (titleKey == "language".tr) {
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
                  // ignore: deprecated_member_use
                  groupValue:
                      LocalizationService.currentLocale.value.languageCode,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    LocalizationService.currentLocale.value =
                        const Locale('en');
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  LocalizationService.currentLocale.value = const Locale('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("العربية"),
                leading: Radio<String>(
                  value: 'ar',
                  // ignore: deprecated_member_use
                  groupValue:
                      LocalizationService.currentLocale.value.languageCode,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    LocalizationService.currentLocale.value =
                        const Locale('ar');
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  LocalizationService.currentLocale.value = const Locale('ar');
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
    return const Divider(height: 1, color: Color(0xFFe5e7eb));
  }
}

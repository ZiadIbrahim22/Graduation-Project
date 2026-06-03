import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reporting_system/services/user_service.dart';
import '../widgets/custom_button.dart';
import '../services/localization_service.dart';
import 'signup_page.dart';
import '../main.dart';
import 'auth/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedLanguage = 'en';

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // ── Subtitles Keys (مش الترجمة نفسها) ──
  final List<String> _subtitleKeys = [
    'Report_incidents_quickly_and_easily',
    'Your_safety_our_priority',
    'Fast_secure_incident_reporting',
    'Smart_reporting_for_a_safer_workplace',
  ];
  int _currentSubtitleIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    _selectedLanguage = LocalizationService.currentLocale.value.languageCode;
    LocalizationService.currentLocale.addListener(_onLocaleChanged);

    // ── Timer للـ subtitles ──
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentSubtitleIndex = (_currentSubtitleIndex + 1) % _subtitleKeys.length;
        });
      }
    });
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _selectedLanguage =
            LocalizationService.currentLocale.value.languageCode;
      });
    }
  }

  @override
  void dispose() {
    LocalizationService.currentLocale.removeListener(_onLocaleChanged);
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Language Selector Bottom Sheet
  // ─────────────────────────────────────────────
  void _showLanguageSelector() {
    String tempLanguage = _selectedLanguage;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: _selectedLanguage == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e3a8a)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.translate_rounded,
                              color: Color(0xFF1e3a8a),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'select_language'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1a1a1a),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLanguageOption(
                      flag: '🇸🇦',
                      language: 'العربية',
                      code: 'ar',
                      isSelected: tempLanguage == 'ar',
                      onTap: () => setModalState(() => tempLanguage = 'ar'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      flag: '🇺🇸',
                      language: 'English',
                      code: 'en',
                      isSelected: tempLanguage == 'en',
                      onTap: () => setModalState(() => tempLanguage = 'en'),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          await LocalizationService()
                              .changeLocale(tempLanguage);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e3a8a),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          tempLanguage == 'ar' ? 'حفظ' : 'Save',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String language,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1e3a8a).withValues(alpha: 0.07)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1e3a8a).withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1e3a8a)
                      : const Color(0xFF1a1a1a),
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1e3a8a)
                        : Colors.grey.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: isSelected
                      ? const Color(0xFF1e3a8a)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Login logic
  // ─────────────────────────────────────────────
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await UserService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('invalid_credentials'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isArabic = _selectedLanguage == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1e3a8a),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(60, 40, 60, 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'app_title'.tr,
                                  textAlign: TextAlign.center,
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 800),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.3),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        )),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _subtitleKeys[_currentSubtitleIndex].tr,
                                    key: ValueKey<int>(_currentSubtitleIndex),
                                    textAlign: TextAlign.center,
                                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 16,
                            child: GestureDetector(
                              onTap: _showLanguageSelector,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isArabic ? '🇸🇦' : '🇺🇸',
                                      style:
                                          const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                      size: 16,
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

                  const SizedBox(height: 30),

                  Directionality(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'login'.tr,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildTextField(
                              controller: _emailController,
                              label: 'email_phone'.tr,
                              icon: Icons.email_outlined,
                              isArabic: isArabic,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'field_required'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _passwordController,
                              label: 'password'.tr,
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              isArabic: isArabic,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword =
                                      !_obscurePassword);
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'field_required'.tr;
                                }
                                return null;
                              },
                            ),

                            Align(
                              alignment: isArabic
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'forgot_password'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF1e3a8a),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CustomButton(
                                    text: 'login'.tr,
                                    onPressed: _login,
                                  ),
                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'create_new_account'.tr,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isArabic,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1e3a8a)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1e3a8a)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
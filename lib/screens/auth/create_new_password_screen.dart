import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reporting_system/services/localization_service.dart';
import '../../services/auth_provider.dart';
import '../login_page.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;

  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _logoutFromAllDevices = true;
  bool _isFormValid = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? error;
    if (password.isNotEmpty && password.length < 8) {
        error = "Password must be at least 8 characters long".tr;
      } else if (password.isNotEmpty && !RegExp(r'[A-Za-z]').hasMatch(password)) {
        error = "Password must contain at least one letter".tr;
      } else if (password.isNotEmpty && !RegExp(r'\d').hasMatch(password)) {
        error = "Password must contain at least one number".tr;
      } else if (password.isNotEmpty && !RegExp(r'[@$!%*#?&]').hasMatch(password)) {
        error = "Password must contain at least one special character (@\$!%*#?&)".tr;
      } else if (confirmPassword.isNotEmpty && password != confirmPassword) {
        error = "Passwords do not match".tr;
      }

    if (_passwordError != error) {
      setState(() {
        _passwordError = error;
      });
    }

    final isValid = password.isNotEmpty && confirmPassword.isNotEmpty && error == null;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _handleSubmit() async {
    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resetPassword(
      email: widget.email,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Password changed successfully!'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!.tr),
          backgroundColor: Colors.red,
        ),
      );
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1a1a1a)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
               Text(
                'CREATE_PASSWORD'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 16),
               Text(
                'your_new_password_must_be_different_from_previous_used_passwords'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'password'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'confirm_password'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _logoutFromAllDevices,
                      activeColor: const Color(0xFF1E5EFF),
                      onChanged: (value) {
                        setState(() {
                          _logoutFromAllDevices = value ?? true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                   Text(
                    'sign_out_from_all_devices'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: (_isFormValid && !authProvider.isLoading) ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5EFF),
                      disabledBackgroundColor: const Color(0xFF1E5EFF).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        :  Text(
                            'confirm_password'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
// import 'package:reporting_system/models/user_model.dart';
// import 'package:reporting_system/services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import '../services/localization_service.dart';
import '../services/user_service.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final user = UserService().currentUser.value;
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String getFriendlyErrorMessage(String error) {
    if (error.contains('FormatException')) {
      return "sorry_error_parsing_data".tr;
    } else if (error.contains('SocketException')) {
      return "no_internet_connection".tr;
    } else if (error.contains('Hey ya!')) {
      return "notification_path_not_found".tr;
    } else if (error.contains('404')) {
      return "the_requested_page_was_not_found".tr;
    } else if (error.contains('User not authenticated')) {
      return "please_login_again_to_view_notifications".tr;
    } else {
      return "an_unexpected_error_occurred".tr;
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await UserService().changeEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Email updated successfully".tr)),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update email".tr)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getFriendlyErrorMessage(e.toString()))),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: Text('edit_email'.tr, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1e3a8a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Form
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          '${'Enter'.tr} ${'current_password'.tr}',
                          _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          '${'Enter'.tr} ${'email'.tr}',
                          _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: _isLoading ? 'Saving...' : 'save_changes'.tr,
                          onPressed: _isLoading ? null : _handleSave,
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2, // Profile is active
        onItemTapped: (index) {
          if (index != 2) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${'please_enter_your'.tr} ${label.tr}';
        }
        return null;
      },
    );
  }
}
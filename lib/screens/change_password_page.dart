import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import '../services/localization_service.dart';
import '../services/user_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String _passwordStrength = "";
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    final user = UserService().currentUser.value;
    _currentPasswordController.text = user?.password ?? '';

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkStrength(String val) {
    setState(() {
      if (val.isEmpty) {
        _passwordStrength = "";
        _strengthColor = Colors.transparent;
      } else if (val.length < 6) {
        _passwordStrength = "Weak".tr;
        _strengthColor = Colors.red;
      } else if (val.length < 10) {
        _passwordStrength = "Medium".tr;
        _strengthColor = Colors.orange;
      } else {
        _passwordStrength = "Strong".tr;
        _strengthColor = Colors.green;
      }
    });
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await UserService().changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password_Updated".tr)),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed_to_change_password".tr)),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: Text(
          'change_password'.tr,
          style: const TextStyle(color: Colors.white),
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                          'current_password'.tr, _currentPasswordController,
                          isObscured: _obscureCurrent,
                          onToggle: () => setState(
                              () => _obscureCurrent = !_obscureCurrent)),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        'new_password'.tr,
                        _newPasswordController,
                        onChanged: _checkStrength,
                        isObscured: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      if (_passwordStrength.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: _passwordStrength == "Weak".tr
                                    ? 0.33
                                    : (_passwordStrength == "Medium".tr
                                        ? 0.66
                                        : 1.0),
                                color: _strengthColor,
                                backgroundColor:
                                    Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _passwordStrength,
                              style: TextStyle(
                                  color: _strengthColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        'confirm_password'.tr,
                        _confirmPasswordController,
                        isObscured: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (val) {
                          if (val != _newPasswordController.text) {
                            return "Password_does_not_match".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'save_changes'.tr,
                        onPressed: _isLoading
                            ? null
                            : () {
                                _handleSave();
                              },
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2,
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

  Widget _buildPasswordField(String label, TextEditingController controller,
      {String? hint,
      Function(String)? onChanged,
      required bool isObscured,
      required VoidCallback onToggle,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
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
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please_enter_password'.tr;
            }
            return null;
          },
    );
  }
}

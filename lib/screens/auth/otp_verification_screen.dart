import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:reporting_system/services/localization_service.dart';
import '../../services/auth_provider.dart';
import 'create_new_password_screen.dart';
import '../../main.dart'; // To navigate to MainScreen

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final OtpFlowType flowType;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.flowType,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerifyEnabled = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 6; i++) {
      _controllers[i].addListener(_checkAllFilled);
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < 6; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  void _checkAllFilled() {
    final allFilled = _controllers.every((controller) => controller.text.length == 1);
    if (_isVerifyEnabled != allFilled) {
      setState(() {
        _isVerifyEnabled = allFilled;
      });
    }
  }

  void _onKeyboardBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  void _handleVerify() async {
    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final otp = _controllers.map((c) => c.text).join();

    bool success = false;
    if (widget.flowType == OtpFlowType.register) {
      success = await authProvider.confirmEmailCitizen(widget.email, otp);
    } else {
      success = await authProvider.verifyResetOtp(widget.email, otp);
    }

    if (!mounted) return;

    if (success) {
      if (widget.flowType == OtpFlowType.register) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateNewPasswordScreen(email: widget.email),
          ),
        );
      }
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      authProvider.clearError();
    }
  }

  void _handleResend() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;
    if (widget.flowType == OtpFlowType.register) {
      success = await authProvider.resendRegistrationOtp(widget.email);
    } else {
      success = await authProvider.resendForgotPasswordOtp(widget.email);
    }
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('code_resent_successfully'.tr),
          backgroundColor: Colors.green,
        ),
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
               Text(
                'confirmation_code'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${'enter_the_6_digit_code_sent_to'.tr}\n${widget.email}'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) {
                        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                          _onKeyboardBackspace(index);
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E5EFF), width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: (_isVerifyEnabled && !authProvider.isLoading) ? _handleVerify : null,
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
                            'verify'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "dont_receive_the_code".tr,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: authProvider.canResend ? _handleResend : null,
                        child: Text(
                          authProvider.canResend
                              ? "resend".tr
                              : "${'resend_in'.tr} ${authProvider.resendCountdown}s",
                          style: TextStyle(
                            color: authProvider.canResend ? const Color(0xFF1E5EFF) : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

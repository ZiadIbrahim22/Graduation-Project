import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:reporting_system/services/user_service.dart';
import '../services/auth_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// القيم لازم تكون زي ما الـ Backend بيستنى (PascalCase):
/// Register | Login | ForgotPassword
enum OtpFlowType { register, login, forgotPassword }

extension OtpFlowTypeExtension on OtpFlowType {
  String get backendValue {
    switch (this) {
      case OtpFlowType.register:
        return 'Register';
      case OtpFlowType.login:
        return 'Login';
      case OtpFlowType.forgotPassword:
        return 'ForgotPassword';
    }
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _deviceToken = '';

  /// استدعيها قبل ما توصل لشاشة الـ OTP (مثلاً في initState أو قبل التنقل)
  Future<void> initDeviceToken() async {
    if (_deviceToken.isNotEmpty) return;
    _deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    print('Device Token: $_deviceToken');
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _resendCountdown = 0;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown == 0;

  String? _resetToken;
  Timer? _timer;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() => _setError(null);

  void startResendTimer() {
    _resendCountdown = 30;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- OTP بعد التسجيل (Register) ---
  Future<bool> confirmEmailCitizen(String email, String otp) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiService.verifyOtp(
        email: email,
        code: otp,
        deviceToken: _deviceToken,
        purpose: OtpFlowType.register.backendValue,
      );

      // ✅ FIX: لو الـ OTP verification رجّع token، احفظه مع المستخدم
      if (response.token != null) {
        final currentUser = UserService().currentUser.value;
        if (currentUser != null) {
          await UserService().saveUser(currentUser, token: response.token);
        }
      }

      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // --- Forgot Password Flow ---
  Future<bool> requestPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.requestPasswordReset(email);
      startResendTimer();
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyResetOtp(String email, String code) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiService.verifyOtp(
        email: email,
        code: code,
        deviceToken: _deviceToken,
        purpose: OtpFlowType.forgotPassword.backendValue, // → "ForgotPassword"
      );
      if (response.token != null) {
        _resetToken = response.token;
      }
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    if (_resetToken == null) {
      _setError('Reset token is missing. Please verify OTP again.');
      _setLoading(false);
      return false;
    }

    try {
      await _apiService.resetPassword(
        email: email,
        token: _resetToken!,
        newPassword: newPassword,
      );
      _resetToken = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // --- Resend OTP ---
  Future<bool> resendRegistrationOtp(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.resendRegistrationOtp(email);
      startResendTimer();
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendForgotPasswordOtp(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiService.resendForgotPasswordOtp(email);
      startResendTimer();
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
}

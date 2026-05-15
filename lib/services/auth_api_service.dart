// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/api_config.dart';
// import '../models/auth_response.dart';

// class ApiException implements Exception {
//   final String message;
//   final int statusCode;
//   ApiException(this.message, this.statusCode);
//   @override
//   String toString() => message;
// }

// class AuthApiService {

//   Future<AuthResponse> _processResponse(http.Response response) async {
//     // print('🔵 STATUS: ${response.statusCode} | BODY: ${response.body}');

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       if (response.body.isEmpty) {
//         return AuthResponse(isSuccess: true);
//       }
//       final decoded = jsonDecode(response.body);
//       if (decoded is String) return AuthResponse(message: decoded, isSuccess: true);
//       if (decoded is List) {
//          return AuthResponse(
//         message: decoded.isNotEmpty ? decoded.first.toString() : 'Success',
//         isSuccess: true,
//       );
//       }
//       return AuthResponse.fromJson(decoded);
//     } else {
//       String errorMessage = 'Something went wrong';
//       try {
//         final body = jsonDecode(response.body);
//         if (body is String) {
//           errorMessage = body;
//         } else if (body is List) {
//           errorMessage = body.isNotEmpty ? body.first.toString() : errorMessage;
//         } else if (body is Map<String, dynamic>) {
//           errorMessage = body['message'] ?? body['error'] ?? errorMessage;
//           final errors = body['errors'];
//           if (errors != null && errors is List && errors.isNotEmpty) {
//             errorMessage = errors.join(', ');
//           }
//         }
//       } catch (_) {}
//       throw ApiException(errorMessage, response.statusCode);
//     }
//   }

//   // ✅ Verify OTP — للاتنين (signup + forgot password)
//   Future<AuthResponse> verifyOtp({
//   required String email,
//   required String code,
//   required String deviceToken,
//   required String purpose, // "signup" | "login" | "forgot-password"
// }) async {
//   final response = await http.post(
//     Uri.parse('${ApiConfig.baseUrl}/api/Account/verify-otp'),
//     headers: ApiConfig.headers,
//     body: jsonEncode({
//       'email': email,
//       'code': code,
//       'deviceToken': deviceToken,
//       'purpose': purpose,
//     }),
//   );
//   return _processResponse(response);
// }

//   // ✅ Forgot Password — ارسل OTP للإيميل
//   Future<AuthResponse> requestPasswordReset(String email) async {
//     final response = await http.post(
//       Uri.parse('${ApiConfig.baseUrl}/api/Account/forgot-password'),
//       headers: ApiConfig.headers,
//       body: jsonEncode({'email': email}),
//     );
//     return _processResponse(response);
//   }

//   // ✅ Reset Password — بعد التحقق من OTP
//   Future<AuthResponse> resetPassword({
//     required String email,
//     required String token,
//     required String newPassword,
//   }) async {
//     final response = await http.post(
//       Uri.parse('${ApiConfig.baseUrl}/api/Account/reset-password'),
//       headers: ApiConfig.headers,
//       body: jsonEncode({
//         'email': email,
//         'token': token,
//         'newPassword': newPassword,
//       }),
//     );
//     print(response.body);
//     return _processResponse(response);
//   }

//   // ✅ Resend OTP — لو مفيش endpoint محدد، ابعت على نفس verify-otp 
//   // أو اعملهولي endpoint منفصل لو الباك اند عنده
//   Future<AuthResponse> resendOtp(String email) async {
//     final response = await http.post(
//       Uri.parse('${ApiConfig.baseUrl}/api/Account/forgot-password'),
//       headers: ApiConfig.headers,
//       body: jsonEncode({'email': email}),
//     );
//     return _processResponse(response);
//   }
// }






import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_response.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class AuthApiService {

  Future<AuthResponse> _processResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return AuthResponse(isSuccess: true);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is String) return AuthResponse(message: decoded, isSuccess: true);
      if (decoded is List) {
         return AuthResponse(
        message: decoded.isNotEmpty ? decoded.first.toString() : 'Success',
        isSuccess: true,
      );
      }
      return AuthResponse.fromJson(decoded);
    } else {
      String errorMessage = 'Something went wrong';
      try {
        final body = jsonDecode(response.body);
        if (body is String) {
          errorMessage = body;
        } else if (body is List) {
          errorMessage = body.isNotEmpty ? body.first.toString() : errorMessage;
        } else if (body is Map<String, dynamic>) {
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
          final errors = body['errors'];
          if (errors != null && errors is List && errors.isNotEmpty) {
            errorMessage = errors.join(', ');
          }
        }
      } catch (_) {}
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  /// Verify OTP — للاتنين (Register + ForgotPassword + Login)
  /// purpose: "Register" | "Login" | "ForgotPassword"
  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
    required String deviceToken,
    required String purpose,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Account/verify-otp'),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'email': email,
        'code': code,
        'deviceToken': deviceToken,
        'purpose': purpose,
      }),
    );
    return _processResponse(response);
  }

  /// Forgot Password — ارسل OTP للإيميل
  Future<AuthResponse> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Account/forgot-password'),
      headers: ApiConfig.headers,
      body: jsonEncode({'email': email}),
    );
    return _processResponse(response);
  }

  /// Reset Password — بعد التحقق من OTP
  Future<AuthResponse> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Account/reset-password'),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'email': email,
        'token': token,
        'newPassword': newPassword,
      }),
    );
    print(response.body);
    return _processResponse(response);
  }

  /// Resend OTP — Forgot Password (نفس الـ forgot-password endpoint)
  Future<AuthResponse> resendForgotPasswordOtp(String email) async {
    return requestPasswordReset(email);
  }

  /// Resend OTP — Registration (لازم Backend يعمل endpoint ده)
  Future<AuthResponse> resendRegistrationOtp(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Account/resend-otp'),
      headers: ApiConfig.headers,
      body: jsonEncode({'email': email}),
    );
    return _processResponse(response);
  }
}
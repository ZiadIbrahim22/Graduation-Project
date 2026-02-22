import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // --- Auth (Login) ---
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Account/login'),                       // API for login
      headers: ApiConfig.headers,
      body: jsonEncode({'emailorPhoneNumber': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // --- Auth (Register) ---
  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/Account/register'),                           // API for register
      headers: ApiConfig.headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // --- Submit Report ---
  static Future<Map<String, dynamic>> submitReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required String token,
    File? image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '${ApiConfig.baseUrl}/api/Reports/CreateReport'),                              // API for submit report
    );

    // Add Token to Header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add Form Fields
    request.fields['Title'] = title;
    request.fields['Description'] = description;
    request.fields['Category'] = category;
    request.fields['Location'] = location;


    // Add Image
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'Photo',
        image.path,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return {"status": "success"};
      return jsonDecode(response.body);
    } else {
      print("Server Error Body: ${response.body}");
      throw Exception("Failed to submit report: ${response.statusCode}");
    }
  }

  // --- Fetch User Stats ---
  static Future<Map<String, dynamic>> fetchUserStats(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/User/GetUserStatus'),                                // API for fetch user stats
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User stats: ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch stats');
    }
  }

  // --- Fetch Notifications ---
  static Future<List<dynamic>> fetchNotifications(String token) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/notifications'),                                 // API for fetch notifications
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Notifications: ${response.body}");
      try {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body;
        } else if (body is Map && body.containsKey('data')) {
          return body['data'];
        } else {
          return [];
        }
      } catch (e) {
        throw Exception(response.body);
      }
    } else {
      throw Exception('Failed to fetch notifications: ${response.body}');
    }
  }

  // --- Delete Account ---
  // static Future<void> deleteAccount({
  //   required String token,
  //   required String password,
  //   required bool confirmDelete,
  //   String? reason,
  // }) async {
  //   final url = Uri.parse(
  //       '${ApiConfig.baseUrl}/api/Account/DeleteAccount');                       // API for delete account

  //   try {
  //     final response = await http.delete(
  //       url,
  //       headers: {
  //         ...ApiConfig.headers,
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({
  //         'password': password,
  //         'confirmDelete': confirmDelete,
  //         'reason': reason,
  //       }),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print("User deleted successfully");
  //     } else {
  //       throw Exception('Failed to delete user: ${response.body}');
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // --- Fetch Reports ---
  static Future<List<dynamic>> fetchMyReports(String token) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/Reports/History'),                             // API for fetch my reports
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body;
      } else if (body is Map) {
        // Handle wrapped responses like {"data": [...]} or {"reports": [...]}
        return body['data'] ?? body['reports'] ?? body['items'] ?? [];
      }
      return [];
    } else {
      throw Exception('Failed to fetch data: ${response.body}');
    }
  }

  // --- change email ---
  static Future<Map<String, dynamic>> editEmail({
    required String token,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/User/ChangeEmail');                  // API for change email

    final response = await http.put(
      url,
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'newEmail': email,
        'currentPassword': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update email: ${response.body}');
    }
  }

  // --- Change Password ---
  static Future<bool> changePassword(String token, String currentPassword,
      String newPassword, String confirmPassword) async {
    final response = await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/User/ChangePassword'),                                 // API for change password
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Change Password Success: ${response.body}");
      return true;
    } else {
      print("Change Password Error: ${response.body}");
      return false;
    }
  }

  static Future<String> uploadProfileImage(String token, File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '${ApiConfig.baseUrl}/api/User/UploadPhoto'),                       // API for upload profile image
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      String path = data['photoPath'] ?? "";
      return path.startsWith('http') ? path : '${ApiConfig.baseUrl}$path';
    } else {
      print("DEBUG: Upload Error: ${response.statusCode} ${response.reasonPhrase} ${response.stream.bytesToString()}");
      throw Exception('Failed to upload image');
    }
  }

  // --- Fetch Profile ---
  static Future<Map<String, dynamic>> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/User/GetProfile'),                                // API for fetch profile
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
}

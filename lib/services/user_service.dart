import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reporting_system/models/user_model.dart';
import 'package:reporting_system/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Current User State
  final ValueNotifier<UserModel?> currentUser = ValueNotifier(null);

  // Auth Token
  String? _authToken;
  Future<String?> getValidToken() async {
    if (_authToken == null) return null;

    if (JwtDecoder.isExpired(_authToken!)) {
      await logout();
      return null;
    }
    return _authToken;
  }
  String? get authToken => _authToken;

  bool get isLoggedIn => currentUser.value != null;

  // Save User
  Future<void> saveUser(UserModel user, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));

    if (token != null) {
      await prefs.setString('auth_token', token);
      _authToken = token;
    }

    currentUser.value = user;
  }

  // Load User
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final token = prefs.getString('auth_token');

    if (userData != null) {
      currentUser.value = UserModel.fromJson(jsonDecode(userData));
      _authToken = token;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
    _authToken = null;
    currentUser.value = null;
  }

  // --- Login ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);

      String? token = response['token'] ?? response['Token'];

      if (token != null) {
        _authToken = token;

        var userData = response['user'] ?? response;

        UserModel user = UserModel.fromJson(userData);
        await saveUser(user, token: token);

        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // --- register ---
  Future<bool> register(UserModel user) async {
    try {
      final response = await ApiService.registerUser(user.toJson());
      String? token = response['token'] ?? response['Token'];
      await saveUser(user, token: token);
      return true;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  // --- delete user ---
  // Future<bool> deleteUser({required String password, String? reason}) async {
  //   try {
  //     if (_authToken == null) return false;

  //     await ApiService.deleteAccount(
  //       token: _authToken!,
  //       password: password,
  //       confirmDelete: true,
  //       reason: reason,
  //     );

  //     currentUser.value = null;
  //     _authToken = null;

  //     return true;
  //   } catch (e) {
  //     print("Delete User Error: $e");
  //     return false;
  //   }
  // }

  // Helpers
  String get userName => currentUser.value?.fullName ?? 'Guest';
  String get userEmail => currentUser.value?.email ?? '';
  String get userPhone => currentUser.value?.phone ?? '';

  // --- change email ---
  Future<bool> changeEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (_authToken == null) throw Exception("Not authenticated");

      final response = await ApiService.editEmail(
        token: _authToken!,
        email: email,
        password: password,
      );

      var userData = response['user'] ?? response;

      if (userData is Map<String, dynamic> && (userData.containsKey('email') || userData.containsKey('id'))) {
        final updatedUser = UserModel.fromJson(userData);
        await saveUser(updatedUser);
        return true;
      }

      return true; 
    } catch (e) {
      print("Change Email Error: $e");
      rethrow; 
    }
  }

  // --- Change Password ---
  Future<bool> changePassword(String currentPassword, String newPassword,
      String confirmNewPassword) async {
    try {
      if (_authToken == null) throw Exception("Not authenticated");

      final success = await ApiService.changePassword(
          _authToken!, currentPassword, newPassword, confirmNewPassword);  
      return success;
    } catch (e) {
      print("Change Password Error: $e");
      rethrow;
    }
  }


  // --- Update Profile Image ---
  Future<void> updateProfileImage(File imageFile) async {
    final token = authToken;
    if (token == null) throw Exception("User not authenticated");

    final imageUrl = await ApiService.uploadProfileImage(
      token, 
      imageFile
    );

    final updatedUser = currentUser.value!.copyWith(
      profileImage: imageUrl,
    );

    currentUser.value = updatedUser;

    await saveUser(updatedUser);
  }

}

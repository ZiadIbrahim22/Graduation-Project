import 'package:reporting_system/config/api_config.dart';

class UserModel {
  final String fullName;
  final String email;
  final String phone;
  final String nationalId;
  final String? profileImage;
  final String? name;
  final int? totalReports;
  final String? imageUrl;

  UserModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationalId,
    this.profileImage,
    this.name,
    this.totalReports,
    this.imageUrl,
  });

  // Copy method to create a new UserModel with updated values
  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? nationalId,
    String? profileImage,
    String? name,
    int? totalReports,
    String? imageUrl,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      totalReports: totalReports ?? this.totalReports,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? rawPath = json['profileImage'];
    String? fullPath = (rawPath != null && rawPath.isNotEmpty && !rawPath.startsWith('http'))
        ? '${ApiConfig.baseUrl}$rawPath'
        : rawPath;

    return UserModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phoneNumber'] ?? json['phone'] ?? '',
      nationalId: json['nationalId'] ?? '',
      profileImage: fullPath,
    );
  }

  // Method to convert UserModel to JSON
  // ✅ deviceToken بقى optional parameter
  
  Map<String, dynamic> toJson({String? deviceToken}) {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phone,
      'nationalId': nationalId,
      'profileImage': profileImage,
      if (deviceToken != null) 'deviceToken': deviceToken,
    };
  }

  // UserService.dart — register بيبعت الباسورد منفصل
  // Future<bool> register(UserModel user, String password, String confirmPassword) async {
  //   try {
  //     final deviceToken = await ApiService.getDeviceToken();
      
  //     final payload = {
  //       ...user.toJson(deviceToken: deviceToken),
  //       'password': password,          // ✅ بتتبعت للـ API بس
  //       'confirmPassword': confirmPassword,
  //     };
      
  //     final response = await ApiService.registerUser(payload);
  //     String? token = response['token'] ?? response['Token'];
  //     await UserService().saveUser(user, token: token); // UserModel محفوظ بدون باسورد ✅
  //     return true;
  //   } catch (e) {
  //     print("Register Error: $e");
  //     return false;
  //   }
  // }
}
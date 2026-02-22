import 'package:reporting_system/config/api_config.dart';

class UserModel {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String nationalId;
  final String? profileImage;
  final String? name;
  final int? totalReports;
  final String? imageUrl;

  UserModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.nationalId,
    required this.confirmPassword,
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
    String? password,
    String? nationalId,
    String? confirmPassword,
    String? profileImage,
    String? name,
    int? totalReports,
    String? imageUrl,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      nationalId: nationalId ?? this.nationalId,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      totalReports: totalReports ?? this.totalReports,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }


  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? rawPath = json['profileImage'];
    // إذا كان المسار ناقصاً، نضيف الـ BaseUrl فوراً عند التحويل من JSON
    String? fullPath = (rawPath != null && rawPath.isNotEmpty && !rawPath.startsWith('http'))
        ? '${ApiConfig.baseUrl}$rawPath'
        : rawPath;

    return UserModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      nationalId: json['nationalId'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
      profileImage: fullPath, // هنا هيتخزن الرابط الكامل دائماً
    );
  }

  // Method to convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phone,
      'password': password,
      'nationalId': nationalId,
      'confirmPassword': confirmPassword,
      'profileImage': profileImage,
    };
  }
  
}

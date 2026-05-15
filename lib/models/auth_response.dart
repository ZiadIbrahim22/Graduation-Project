class AuthResponse {
  final String? token;
  final String? message;
  final bool isSuccess;

  AuthResponse({
    this.token,
    this.message,
    required this.isSuccess,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['data']?['token'],
      message: json['message'],
      isSuccess: true, // Assuming parsing happens on 2xx status
    );
  }
}

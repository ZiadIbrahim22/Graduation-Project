import 'package:timeago/timeago.dart' as timeago;

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final String type; // 'update', 'alert'
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
    required this.createdAt,
  });

  String get formattedTime {
    return timeago.format(createdAt, locale: 'en'); 
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timeAgo: json['time_ago'] ??
          '', // Assuming API might send pre-calculated or handle in client
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'update',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

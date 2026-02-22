import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reporting_system/models/notification.dart';
import 'package:reporting_system/services/api_service.dart';
import 'package:reporting_system/services/user_service.dart';
// import 'package:toastification/toastification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<List<AppNotification>> notifications = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  String? _error;

  String? get error => _error;

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      _error = null;

      final token = UserService().authToken;
      if (token == null) {
        throw Exception("User not authenticated");
      }

      final List<dynamic> data = await ApiService.fetchNotifications(token);

      notifications.value =
          data.map((jsonItem) => AppNotification.fromJson(jsonItem)).toList();
    } catch (e) {
      print("Error fetching notifications: $e");
      _error = e.toString();
      notifications.value = []; // Optionally clear or keep old data
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    notifications.value = [];
    _error = null;
    isLoading.value = false;
  }


  // void showNewNotificationPopup(BuildContext context, String title, String message) {
  //   toastification.show(
  //     context: context,
  //     type: ToastificationType.info,
  //     style: ToastificationStyle.flatColored,
  //     title: Text(
  //       title,
  //       style: const TextStyle(fontWeight: FontWeight.bold),
  //     ),
  //     description: Text(message),
  //     alignment: Alignment.topCenter, // بتخليه ينزل من فوق
  //     autoCloseDuration: const Duration(seconds: 3), // بيختفي لوحده بعد 3 ثواني
  //     animationDuration: const Duration(milliseconds: 300),
  //     icon: const Icon(Icons.notifications_active, color: Color(0xFF1e3a8a)), // لون أزرق زي التطبيق بتاعك
  //     showProgressBar: false,
  //     margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
  //     borderRadius: BorderRadius.circular(12),
  //     boxShadow: highModeShadow, 
  //   );
  // }

  // // داخل NotificationService
  // void handleForegroundMessage(BuildContext context, RemoteMessage message) {
  //   // بنستخرج البيانات من الرسالة اللي بعتها الباك إند
  //   String title = message.notification?.title ?? "تنبيه جديد";
  //   String body = message.notification?.body ?? "";

  //   // بننادي على الـ Popup اللي إنت ضفتها
  //   showNewNotificationPopup(context, title, body);

  //   // تحديث القائمة فوراً عشان المستخدم لما يفتح صفحة الإشعارات يلاقيها زادت
  //   fetchNotifications(); 
  // }
}

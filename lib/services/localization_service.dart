import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final ValueNotifier<Locale> currentLocale =
      ValueNotifier(const Locale('en'));

  Future<void> changeLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);

    currentLocale.value = Locale(languageCode);
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_language') ?? 'en';
    currentLocale.value = Locale(savedLang);
  }

  static bool isArabic() {
    return currentLocale.value.languageCode == 'ar';
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_title': 'Smart Incident Reporting System',

      // Navigation
      'home': 'Home',
      'reports': 'Reports',
      'profile': 'Profile',

      // Home Page
      'welcome': 'Welcome Back,',
      'you_have': 'You have',
      'create_report': 'Create New Report',
      'active_reports': 'reports under review',
      'total_reports': 'Total Reports',
      'report_summary': 'My Report Summary',
      'all_time': 'All Time',
      'this_month': 'this month',

      // Report Status
      'report_status': 'Report Status',
      'tracking_id': 'Tracking ID',
      'pending': 'Pending',
      'inprogress': 'In Progress',
      'solved': 'Solved',
      'report_submitted': 'Report Submitted',
      'ai_analysis': 'AI Analysis',
      'sent_authorities': 'Sent to Authorities',
      'team_assigned': 'Maintenance Team Assigned',
      'estimated_time': 'Estimated time:',
      'days': 'days',
      'report_not_found': 'Report not found',

      // Create Report
      'short_title': 'Short Title',
      'description': 'Description',
      'category': 'Category',
      'select_category': 'Select a category',
      'tap_upload': 'Tap to upload photo',
      'location': 'Location',
      'submit_report': 'Submit Report',
      'please_attach_image': 'Please attach an image',
      'please_select_category': 'Please select a category',
      'field_required': 'This field is required',
      'Traffic_Accident': 'Traffic Accident',
      'Fire_Incident': 'Fire Incident',
      'Medical_Emergency': 'Medical Emergency',
      'Public_Disturbance': 'Public Disturbance',
      'Other': 'Other',
      'e.g.,_Broken_Streetlight_on_Main_St.':
          'e.g., Broken Streetlight on Main St.',
      'Describe_the_issue_in_detail,_the_more_information,_the_better.':
          'Describe the issue in detail, the more information, the better.',
      'Select_a_category': 'Select a category',
      'Please_select_a_category': 'Please select a category',
      'Please_attach_an_image': 'Please attach an image',
      'This_field_is_required': 'This field is required',

      // Map Picker
      'select_location': 'Pick Location',
      'confirm_location': 'Confirm Location',
      'loading_address': 'Loading address...',
      'unknown_location': 'Unknown location',
      'error_fetching_address': 'Error fetching address',

      // Review Report
      'review_report': 'Review Your Report',
      'confirm_send': 'Confirm & Send Report Now',
      'Based_on_your_initial_analysis_the_report_will_be_browsed_to_Police_&_Traffic':
          'Based on your initial analysis the report will be browsed to Police & Traffic',
      'edit_report': 'Edit Report',
      'ai_classification': 'AI Classification Result',
      'incident_type': 'Incident Type',
      'Confirm_&_Send_Report_Now': 'Confirm & Send Report Now',
      'AI_Classification_Result_Traffic_Accident_Severity_High':
          'AI Classification Result: Traffic Accident - Severity: High',
      'unknown': 'Unknown',

      // Report Submitted
      'report_submitted_title': 'Report Submitted',
      'success': 'SUCCESS!',
      'report_id': 'Report ID',
      'view_report_status': 'View Report Status',

      // Reports History
      'reports_history': 'Reports History',
      'all': 'All',
      'search_reports': 'Search reports...',
      'no_reports': 'No reports found',
      'no_reports_found': 'No reports found',

      // Profile & Settings
      'profile_settings': 'Profile & Settings',
      'edit_email': 'Edit Email',
      'change_password': 'Change password',
      'language': 'Language',
      'change_language': 'Change Language',
      'log_out': 'Log Out',
      'delete_account': 'Delete Account',
      'save_changes': 'Save Changes',
      'user': 'User',

      // Change Email
      'email': 'Email',
      'sorry_error_parsing_data':
          'Sorry, there was an error parsing data from the server.',
      'no_internet_connection':
          'No internet connection. Please check your network.',
      'notification_path_not_found':
          'Notification path not found on the server.',
      'an_unexpected_error_occurred':
          'An unexpected error occurred. Please try again later.',
      'please_enter': 'Please enter',
      'profile_updated_successfully': 'Profile updated successfully',
      'Failed_to_update_profile': 'Failed to update profile',
      'please_enter_your': 'Please enter your',

      // Change Password
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      'update_password': 'Update Password',
      'Password_Updated': 'Password Updated',
      'Failed_to_change_password': 'Failed to change password',
      'Enter_your_current_password': 'Enter your current password',
      'Weak': 'Weak',
      'Medium': 'Medium',
      'Strong': 'Strong',
      'Password_does_not_match': 'Password does not match',
      'Please_enter_password': 'Please enter password',

      // Notifications
      'notifications': 'Notifications',
      'no_notifications': 'No notifications',
      'report_status_update': 'Report Status Update',
      'report_update_msg': 'Your report {} is now on {}!',
      'system_alert': 'System Alert',
      'unread': 'Unread',
      'retry': 'Retry',
      'no_results_found': 'No results found',
      'no_notifications_yet': 'No notifications yet!',
      'notification_path_not_found_on_the_server':
          'Notification path not found on the server.',
      'the_requested_page_was_not_found': 'The requested page was not found.',
      'please_login_again_to_view_notifications':
          'Please login again to view notifications.',
      'an_unexpected_error_occurred_please_try_again_later':
          'An unexpected error occurred. Please try again later.',
      'sorry_there_was_an_error_parsing_data_from_the_server':
          'Sorry, there was an error parsing data from the server.',
      'no_internet_connection_please_check_your_network':
          'No internet connection. Please check your network.',

      // Chatbot
      'chatbot': 'AI Assistant',
      'type_message': 'Type a message...',

      // Categories
      'traffic_accident': 'Traffic Accident',
      'fire_incident': 'Fire Incident',
      'medical_emergency': 'Medical Emergency',
      'public_disturbance': 'Public Disturbance',
      'other': 'Other',

      // Sign Up & Login
      'login': 'Log In',
      'sign_up': 'Sign Up',
      'email_phone': 'Phone Number / Email',
      'password': 'Password',
      'national_id': 'National ID',
      'create_new_account': 'Create New Account',
      'report_as_guest': 'Report as Guest',
      'smart_incident_system': 'Smart Incident Reporting System',
      'password_min_length': 'Password must be at least 8 characters',
      'passwords_not_match': 'Passwords do not match',
      'invalid_credentials': 'Invalid email/phone or password',
      'registration_failed': 'Registration failed',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account?',
      'login_here': 'Login here',
      'or': 'or',

      // Dialogs
      'logout_confirm_title': 'Log Out',
      'logout_confirm_msg': 'Are you sure you want to log out?',
      'delete_confirm_title': 'Delete Account',
      'delete_confirm_msg':
          'Are you sure? Your account will be permanently deleted.',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'ok': 'OK',
      'delete_account_warning':
          'This action is irreversible. All your data will be permanently lost.',
      'enter_your_password': 'Enter your password',
      'reason_for_leaving': 'Reason for leaving (Optional)',
      'tell_us_why': 'Tell us why you are deleting your account...',
      'delete_confirmation_text':
          'I understand that this action is permanent and cannot be undone.',
      'please_confirm_deletion': 'Please confirm deletion',
      'failed_to_delete_account': 'Failed to delete account',
      'password_required': 'Password is required',
      'Enter': 'Enter',
    },
    'ar': {
      // App
      'app_title': 'نظام البلاغات الذكي',

      // Navigation
      'home': 'الرئيسية',
      'reports': 'البلاغات',
      'profile': 'الملف الشخصي',

      // Home Page
      'welcome': 'مرحباً بك،',
      'you_have': 'يوجد لديك',
      'active_reports': 'بلاغات قيد المراجعة',
      'create_report': 'إنشاء بلاغ جديد',
      'total_reports': 'إجمالي البلاغات',
      'report_summary': 'ملخص بلاغاتي',
      'all_time': 'كل الوقت',
      'this_month': 'هذا الشهر',

      // Report Status
      'report_status': 'حالة البلاغ',
      'tracking_id': 'رقم التتبع',
      'pending': 'قيد الانتظار',
      'inprogress': 'قيد التنفيذ',
      'solved': 'تم الحل',
      'report_submitted': 'تم إرسال البلاغ',
      'ai_analysis': 'تحليل الذكاء الاصطناعي',
      'sent_authorities': 'تم الإرسال للسلطات المختصة',
      'team_assigned': 'تم تعيين فريق الصيانة',
      'resolved': 'تم الحل',
      'estimated_time': 'الوقت المتوقع:',
      'days': 'أيام',
      'report_not_found': 'البلاغ غير موجود',

      // Create Report
      'short_title': 'العنوان المختصر',
      'description': 'الوصف',
      'category': 'نوع البلاغ',
      'select_category': 'اختر نوع البلاغ',
      'tap_upload': 'اضغط لرفع صورة',
      'location': 'الموقع',
      'submit_report': 'إرسال البلاغ',
      'please_attach_image': 'يرجى إرفاق صورة',
      'please_select_category': 'يرجى اختيار نوع البلاغ',
      'field_required': 'هذا الحقل مطلوب',
      'Traffic_Accident': 'حادث مروري',
      'Fire_Incident': 'حادث حريق',
      'Medical_Emergency': 'حالة طبية طارئة',
      'Public_Disturbance': 'إزعاج عام',
      'Other': 'أخرى',
      'e.g.,_Broken_Streetlight_on_Main_St.':
          'مثال: عمود إنارة مكسور في شارع رئيسي',
      'Describe_the_issue_in_detail,_the_more_information,_the_better.':
          'صف المشكلة بالتفصيل، كلما زادت المعلومات، كان ذلك أفضل.',
      'Select_a_category': 'اختر نوع البلاغ',
      'Please_select_a_category': 'يرجى تحديد نوع البلاغ',
      'Please_attach_an_image': 'يرجى إرفاق صورة',
      'This_field_is_required': 'هذا الحقل مطلوب',

      // Map Picker
      'select_location': 'تحديد الموقع',
      'confirm_location': 'تأكيد الموقع',
      'loading_address': 'جاري تحميل العنوان...',
      'unknown_location': 'موقع غير معروف',
      'error_fetching_address': 'خطأ في جلب العنوان',

      // Review Report
      'review_report': 'مراجعة البلاغ',
      'confirm_send': 'تأكيد وإرسال البلاغ الآن',
      'edit_report': 'تعديل البلاغ',
      'ai_classification': 'نتيجة تصنيف الذكاء الاصطناعي',
      'incident_type': 'نوع البلاغ',
      'Based_on_your_initial_analysis_the_report_will_be_browsed_to_Police_&_Traffic':
          'بناءً على تحليلك الأولي، سيتم إرسال البلاغ إلى الشرطة والمرور',
      'AI_Classification_Result_Traffic_Accident_Severity_High':
          'نتيجة تصنيف الذكاء الاصطناعي: حادث مروري - شدة: عالية',
      'Confirm_&_Send_Report_Now': 'تأكيد وإرسال البلاغ الآن',
      'unknown': 'غير معروف',

      // Report Submitted
      'report_submitted_title': 'تم إرسال البلاغ',
      'success': 'نجاح!',
      'report_id': 'رقم البلاغ',
      'view_report_status': 'عرض حالة البلاغ',

      // Reports History
      'reports_history': 'سجل البلاغات',
      'all': 'الكل',
      'search_reports': 'البحث في البلاغات...',
      'no_reports': 'لا توجد بلاغات',
      'no_reports_found': 'لا توجد بلاغات',

      // Profile & Settings
      'profile_settings': 'الملف الشخصي والإعدادات',
      'edit_email': 'تعديل البريد الإلكتروني',
      'change_password': 'تغيير كلمة المرور',
      'language': 'اللغة',
      'change_language': 'تغيير اللغة',
      'log_out': 'تسجيل الخروج',
      'delete_account': 'حذف الحساب',
      'save_changes': 'حفظ التغييرات',
      'user': 'مستخدم',

      // Change Email
      'email': 'البريد الإلكتروني',
      'sorry_error_parsing_data': 'عذراً، حدث خطأ في تحليل البيانات من الخادم.',
      'no_internet_connection':
          'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
      'notification_path_not_found':
          'لم يتم العثور على مسار الإشعارات على الخادم.',
      'an_unexpected_error_occurred':
          'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.',
      'please_enter': 'يرجى إدخال',
      'profile_updated_successfully': 'تم تحديث الملف الشخصي بنجاح',
      'Failed_to_update_profile': 'فشل تحديث الملف الشخصي',
      'please_enter_your': 'يرجى إدخال',

      // Change Password
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_password': 'تأكيد كلمة المرور',
      'update_password': 'تحديث كلمة المرور',
      'Password_Updated': 'تم تحديث كلمة المرور',
      'Failed_to_change_password': 'فشل تحديث كلمة المرور',
      'Enter_your_current_password': 'أدخل كلمة المرور الحالية',
      'Weak': 'ضعيف',
      'Medium': 'متوسط',
      'Strong': 'قوي',
      'Password_does_not_match': 'كلمة المرور غير متطابقة',
      'Please_enter_password': 'يرجى إدخال كلمة المرور',

      // Notifications
      'notifications': 'الإشعارات',
      'no_notifications': 'لا توجد إشعارات',
      'report_status_update': 'تحديث حالة البلاغ',
      'report_update_msg': 'بلاغك رقم {} أصبح الآن في حالة {}!',
      'system_alert': 'تنبيه النظام',
      'unread': 'غير مقروء',
      'retry': 'إعادة المحاولة',
      'no_results_found': 'لا توجد نتائج',
      'no_notifications_yet': 'لا توجد إشعارات',
      'notification_path_not_found_on_the_server':
          'مسار الإشعار غير موجود على الخادم.',
      'the_requested_page_was_not_found': 'الصفحة المطلوبة غير موجودة.',
      'please_login_again_to_view_notifications':
          'يرجى تسجيل الدخول مرة أخرى لعرض الإشعارات.',
      'an_unexpected_error_occurred_please_try_again_later':
          'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا.',
      'sorry_there_was_an_error_parsing_data_from_the_server':
          'عذرًا، حدث خطأ في تحليل البيانات من الخادم.',
      'no_internet_connection_please_check_your_network':
          'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',

      // Chatbot
      'chatbot': 'المساعد الذكي',
      'type_message': 'اكتب رسالة...',

      // Categories
      'traffic_accident': 'حادث مروري',
      'fire_incident': 'حادث حريق',
      'medical_emergency': 'طوارئ طبية',
      'public_disturbance': 'إخلال بالنظام العام',
      'other': 'أخرى',

      // Sign Up & Login
      'login': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      'email_phone': 'رقم الهاتف / البريد الإلكتروني',
      'password': 'كلمة المرور',
      'national_id': 'الرقم القومي',
      'create_new_account': 'إنشاء حساب جديد',
      'report_as_guest': 'الإبلاغ كزائر',
      'smart_incident_system': 'نظام البلاغات الذكي',
      'password_min_length': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'passwords_not_match': 'كلمات المرور غير متطابقة',
      'invalid_credentials':
          'البريد الإلكتروني/رقم الهاتف أو كلمة المرور غير صحيحة',
      'registration_failed': 'فشل التسجيل',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'create_account': 'إنشاء حساب',
      'already_have_account': 'هل لديك حساب بالفعل؟',
      'login_here': 'تسجيل الدخول هنا',
      'or': 'أو',

      // Dialogs
      'logout_confirm_title': 'تسجيل الخروج',
      'logout_confirm_msg': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'delete_confirm_title': 'حذف الحساب',
      'delete_confirm_msg': 'هل أنت متأكد؟ سيتم حذف حسابك نهائياً.',
      'cancel': 'إلغاء',
      'yes': 'نعم',
      'ok': 'موافق',
      'delete_account_warning':
          'هذا الإجراء لا رجعة فيه. سيتم فقد جميع بياناتك بشكل دائم.',
      'enter_your_password': 'أدخل كلمة المرور',
      'reason_for_leaving': 'سبب المغادرة (اختياري)',
      'tell_us_why': 'أخبرنا سبب حذف حسابك...',
      'delete_confirmation_text':
          'أنا أفهم أن هذا الإجراء دائم ولا يمكن التراجع عنه.',
      'please_confirm_deletion': 'يرجى تأكيد الحذف',
      'failed_to_delete_account': 'فشل حذف الحساب',
      'password_required': 'كلمة المرور مطلوبة',
      'Enter': 'أدخل',
    },
  };

  static String translate(String key) {
    return _localizedValues[currentLocale.value.languageCode]?[key] ?? key;
  }
}

extension StringLocalization on String {
  String get tr => LocalizationService.translate(this);
}

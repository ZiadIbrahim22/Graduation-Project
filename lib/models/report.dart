import 'package:flutter/material.dart';

// Report Status definitions
enum ReportStatus {
  pending,
  inProgress,
  solved,
}

class Report {
  final String id;
  final String title;
  final String description;
  final String incidentType;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final ReportStatus status;
  final IconData? icon;
  final Color? iconColor;
  final String? aiTag;
  final double? confidence;
  final String? formattedConfidence;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.incidentType,
    required this.location,
    required this.date,
    required this.status,
    this.latitude,
    this.longitude,
    this.icon,
    this.iconColor,
    this.aiTag,
    this.confidence,
    this.formattedConfidence,
  });

  // Factory constructor to create a Report from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    // ✅ FIX 1: بنقرأ الـ category من كل الأسماء المحتملة في الـ API
    // API بيبعت: displayCategory, reportCategory, finalCategory
    final String category = json['displayCategory'] ??
        json['reportCategory'] ??
        json['finalCategory'] ??
        json['category'] ??
        'Other';

    return Report(
      id: json['report_ID']?.toString() ?? '0',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      // ✅ FIX 1: استخدام الـ category المستخرج من الـ API مباشرةً
      incidentType: category,
      location: json['location'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      date: _parseDate(json),
      status: _parseStatus(json['status'] ?? json['initialStatus'] ?? 'pending'),
      // ✅ FIX 1: الـ icon والـ color بيتحددوا من الـ category الصح
      icon: getIconForType(category),
      iconColor: getColorForType(category),
      aiTag: json['aiTag'] ?? json['ai_tag'],
      confidence: _parseConfidence(json),
      formattedConfidence: _parseFormattedConfidence(json),
    );
  }

  // ✅ Parse confidence بأمان من أي نوع (num أو String)
  static double? _parseConfidence(Map<String, dynamic> json) {
    final raw = json['confidence'] ??
        json['aiConfidence'] ??
        json['ai_confidence'] ??
        json['Confidence'];
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      // Handle values like "52", "52%", "0.89"
      return double.tryParse(raw.replaceAll('%', '').trim());
    }
    return null;
  }

  // ✅ FIX 2: لو الـ confidence بين 0 و1 (decimal) بنضربها في 100
  // API بيبعت 0.89 → يظهر "89 %" مش "1 %"
  static String? _parseFormattedConfidence(Map<String, dynamic> json) {
    // أول: جرب لو في formattedConfidence جاهز من الـ API
    final raw = json['formattedConfidence'] ??
        json['FormattedConfidence'] ??
        json['formatted_confidence'];
    if (raw != null && raw.toString().isNotEmpty) return raw.toString();

    // تاني: احسبها من الـ raw confidence
    final conf = _parseConfidence(json);
    if (conf != null && conf > 0) {
      // ✅ FIX 2: لو القيمة <= 1 معناها decimal (0.89) → اضربها في 100 = 89%
      // لو القيمة > 1 معناها هي بالفعل كـ percentage (89) → استخدمها مباشرةً
      final displayValue = conf <= 1.0 ? conf * 100 : conf;
      return "${displayValue.toStringAsFixed(0)} %";
    }
    return null;
  }

  // Helper to parse date from various possible field names
  static DateTime _parseDate(Map<String, dynamic> json) {
    final dateStr = json['submittedAt'] ??
        json['created_at'] ??
        json['createdAt'] ??
        json['reportDate'];
    if (dateStr != null) {
      return DateTime.tryParse(dateStr.toString()) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Helper method to parse status string to enum
  static ReportStatus _parseStatus(String status) {
    switch (status.toString().toLowerCase()) {
      case 'solved':
      case 'resolved':
        return ReportStatus.solved;
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return ReportStatus.inProgress;
      default:
        return ReportStatus.pending;
    }
  }

  // Helper method to determine icon based on incident type
  static IconData getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department_sharp;
      case 'accident':
      case 'traffic accident':
        return Icons.car_crash;
      case 'pothole':
      case 'damaged road':
        return Icons.remove_road_sharp;
      default:
        return Icons.report_problem;
    }
  }

  static Color getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'accident':
      case 'traffic accident':
        return Colors.orange;
      case 'pothole':
      case 'damaged road':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
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
  final String incidentType; // الـ primary category (الأعلى score)
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final ReportStatus status;
  final IconData? icon;
  final Color? iconColor;
  final String? aiTag;
  final double? confidence;
  final double? secondConfidence;
  final String? formattedConfidence;
  final String? formattedConfidence2;
  final Map<String, double> aiScores;   // {"Accident": 0.73, "Fire": 0.66}
  final List<String> allCategories;     // ["Accident", "Fire"] مرتبة تنازليًا

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
    this.secondConfidence,
    this.formattedConfidence,
    this.formattedConfidence2,
    this.aiScores = const {},
    this.allCategories = const [],
  });

  factory Report.fromJson(Map<String, dynamic> json) {

    // ✅ المصدر الوحيد: ai_Score فقط
    // "Accident:0.73,Fire:0.66" → {"Accident": 0.73, "Fire": 0.66}
    final aiScores = _parseAiScores(json['ai_Score']);

    // ✅ allCategories مرتبة تنازليًا حسب الـ score (الأعلى أول)
    final allCategories = (aiScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => e.key)
        .toList();

    // ✅ Primary = الأعلى score (أول واحد في اللستة)
    final primaryCategory =
        allCategories.isNotEmpty ? allCategories.first : 'Other';

    final secondPrimaryCategory =
        allCategories.length > 1 ? allCategories[1] : 'Other';

    // ✅ Confidence من aiScores مباشرةً
    final primaryConfidence = aiScores[primaryCategory];
    final secondConfidence = aiScores[secondPrimaryCategory];

    return Report(
      id: json['report_ID']?.toString() ?? '0',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      incidentType: primaryCategory,
      location: json['location'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      date: _parseDate(json),
      status: _parseStatus(json['status'] ?? json['initialStatus'] ?? 'pending'),
      icon: getIconForType(primaryCategory),
      iconColor: getColorForType(primaryCategory),
      aiTag: json['aiTag'] ?? json['ai_tag'],
      confidence: primaryConfidence,
      secondConfidence: secondConfidence,
      formattedConfidence: _formatConfidence(primaryConfidence),
      formattedConfidence2: _formatConfidence(secondConfidence),
      aiScores: aiScores,
      allCategories: allCategories,
    );
  }

  // ✅ Parse "Accident:0.73,Fire:0.66" → {"Accident": 0.73, "Fire": 0.66}
  static Map<String, double> _parseAiScores(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return {};
    final result = <String, double>{};
    for (final part in raw.toString().split(',')) {
      final kv = part.trim().split(':');
      if (kv.length == 2) {
        final type = kv[0].trim();
        final score = double.tryParse(kv[1].trim());
        if (score != null && type.isNotEmpty) {
          result[type] = score;
        }
      }
    }
    return result;
  }

  // ✅ Format: 0.73 → "73 %"  |  73 → "73 %"
  static String? _formatConfidence(double? conf) {
    if (conf == null || conf <= 0) return null;
    final displayValue = conf <= 1.0 ? conf * 100 : conf;
    return "${displayValue.toStringAsFixed(0)} %";
  }

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
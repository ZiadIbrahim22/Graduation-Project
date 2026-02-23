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
  });

  // Factory constructor to create a Report from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['report_ID']?.toString() ?? '0',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      incidentType: json['category'] ?? 'Other',
      location: json['location'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      date: _parseDate(json),
      status: _parseStatus(json['status'] ?? 'pending'),
      icon: _getIconForType(json['category']),
      iconColor: _getColorForType(json['category']),
      aiTag: json['aiTag'],
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : 0.0,
    );
  }

  // Helper to parse date from various possible field names
  static DateTime _parseDate(Map<String, dynamic> json) {
    final dateStr = json['created_at'] ??
        json['createdAt'] ??
        json['reportDate'] ??
        json['submittedAt'];
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
  static IconData _getIconForType(String? type) {
    switch (type) {
      case 'Fire Incident':
        return Icons.local_fire_department;
      case 'Traffic Accident':
        return Icons.car_crash;
      case 'Medical Emergency':
        return Icons.medical_services;
      default:
        return Icons.report_problem;
    }
  }

  // Helper method to determine color based on incident type
  static Color _getColorForType(String? type) {
    switch (type) {
      case 'Fire Incident':
        return Colors.red;
      case 'Traffic Accident':
        return Colors.orange;
      case 'Medical Emergency':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

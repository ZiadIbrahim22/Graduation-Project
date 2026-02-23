import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reporting_system/models/report.dart';
import 'package:reporting_system/services/api_service.dart';
import 'package:reporting_system/services/user_service.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  // Observable list of reports
  final ValueNotifier<List<Report>> _reports = ValueNotifier([]);
  ValueNotifier<List<Report>> get reports => _reports; 

  // --- Fetch Reports ---
  Future<void> fetchReports() async {
    try {
      String? token = await UserService().getValidToken();
      if (token == null) {
        throw Exception("Session expired, please login again");
      }

      final List<dynamic> data = await ApiService.fetchMyReports(token);

      _reports.value =
          data.map((jsonItem) => Report.fromJson(jsonItem)).toList();
    } catch (e) {
      print("Error fetching reports: $e");
      _reports.value = [];
    }
  }

  // --- Add Report ---
  Future<Map<String, dynamic>> addReport(Report report, File? image, {double? lat, double? lng}) async {
    try {

      print("Adding report...");
      String? token = await UserService().getValidToken();
      if (token == null) {
        throw Exception("Session expired, please login again");
      }
      print('Token loaded: $token');

      String formattedLocation = (lat != null && lng != null) 
        ? "$lat,$lng" 
        : report.location;
      print("Formatted Location: $formattedLocation");

      final Map<String, dynamic> responseData = await ApiService.submitReport(
        title: report.title,
        description: report.description,
        category: report.incidentType,
        location: formattedLocation,
        image: image,
        token: token,
        aiTag: report.aiTag,
        confidence: report.confidence,
      );
      print("Response Data: $responseData");

      // Refresh list after successful submission
      await fetchReports();
      print("Reports fetched successfully");
      return responseData;
    } catch (e) {
      print("Error adding report: $e");
      rethrow;
    }
  }

  // --- Get Report by ID ---
  Report? getReportById(String id) {
    try {
      return _reports.value.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
  // --- Clear Data ---
  void clearData() {
    _reports.value = []; 
  }
}

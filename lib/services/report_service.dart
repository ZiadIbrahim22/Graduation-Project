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

  // ✅ حاجات جديدة للـ pagination
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  // --- Fetch Reports ---
  Future<void> fetchReports() async {
    _currentPage = 1;
    _hasMore = true;
    _reports.value = [];
    await _loadPage();
  }
  // تحميل صفحة جديدة — بيضيف على القديم
  Future<void> fetchMoreReports() async {
    if (!_hasMore || _isFetchingMore) return; // لو مفيش أكتر أو لسه شايل
    await _loadPage();
  }

  Future<void> _loadPage() async {
    try {
      _isFetchingMore = true;

      String? token = await UserService().getValidToken();
      if (token == null) throw Exception("Session expired");

      final List<dynamic> data = await ApiService.fetchMyReports(
        token,
        page: _currentPage,
        pageSize: _pageSize,
      );

      final newReports = data.map((j) => Report.fromJson(j)).toList();
      newReports.sort((a, b) => b.date.compareTo(a.date));

      // لو رجع أقل من الـ pageSize يبقى وصلنا للآخر
      if (newReports.length < _pageSize) _hasMore = false;

      // ✅ ضيف الجديد على القديم (مش تبديل)
      _reports.value = [..._reports.value, ...newReports];
      _currentPage++;

    } catch (e) {
      debugPrint("Error fetching reports: $e");
    } finally {
      _isFetchingMore = false;
    }
  }

  // --- Add Report ---
  Future<Map<String, dynamic>> addReport(Report report, File? image,
      {double? lat, double? lng}) async {
    try {
      print("Adding report...");
      String? token = await UserService().getValidToken();
      if (token == null) {
        throw Exception("Session expired, please login again");
      }
      print('Token loaded: $token');

      String formattedLocation =
          (lat != null && lng != null) ? "$lat,$lng" : report.location;
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
    } catch (_) {
      return null;
    }
  }

  // --- Clear Data ---
  Future<void> clearData() async {
    _reports.value = [];
    _currentPage = 1;
    _hasMore = true;
  }
}

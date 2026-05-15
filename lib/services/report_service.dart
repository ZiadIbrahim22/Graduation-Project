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

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  // --- Fetch Reports ---
  // ✅ FIX: شيلنا كل كود الـ SharedPreferences cache
  // دلوقتي الـ category والـ confidence بييجوا مباشرةً من الـ API
  // عن طريق Report.fromJson() اللي اتحسنت في report.dart
  Future<void> fetchReports() async {
    _currentPage = 1;
    _hasMore = true;
    _reports.value = [];
    await _loadPage();
  }

  // تحميل صفحة جديدة — بيضيف على القديم
  Future<void> fetchMoreReports() async {
    if (!_hasMore || _isFetchingMore) return;
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

      // ✅ Report.fromJson() دلوقتي بتقرأ displayCategory, reportCategory, confidence
      // مباشرةً من الـ API من غير ما تحتاج SharedPreferences
      final newReports = data.map((j) => Report.fromJson(j)).toList();
      newReports.sort((a, b) => b.date.compareTo(a.date));

      // ✅ FIX: لو رجع عدد أقل من الـ pageSize معناه مفيش صفحات تانية
      if (newReports.length < _pageSize) _hasMore = false;

      _reports.value = [..._reports.value, ...newReports];
      _currentPage++;
    } catch (e) {
      debugPrint("Error fetching reports: $e");
      // ✅ FIX: لو فيه error، وقّف اللودينج ومتحاولش تجيب أكتر
      _hasMore = false;
    } finally {
      _isFetchingMore = false;
    }
  }

  // --- Add Report ---
  Future<Map<String, dynamic>> addReport(Report report, File? image,
      {double? lat, double? lng}) async {
    try {
      String? token = await UserService().getValidToken();
      if (token == null) {
        throw Exception("Session expired, please login again");
      }

      String formattedLocation =
          (lat != null && lng != null) ? "$lat,$lng" : report.location;

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

      // ✅ بعد الإضافة، بنعمل refresh للقائمة من الـ API مباشرةً
      // والـ API هيبعت الـ displayCategory والـ confidence الصح
      await fetchReports();

      return responseData;
    } catch (e) {
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
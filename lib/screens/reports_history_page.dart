import 'package:flutter/material.dart';
import '../widgets/report_card.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../services/localization_service.dart';
import 'report_status_page.dart';

class ReportsHistoryPage extends StatefulWidget {
  const ReportsHistoryPage({super.key});

  @override
  State<ReportsHistoryPage> createState() => _ReportsHistoryPageState();
}

class _ReportsHistoryPageState extends State<ReportsHistoryPage>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'pending', 'inprogress', 'solved'];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // Auto-fetch reports from API on init
    ReportService().fetchReports();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'search_reports'.tr,
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() {}),
              )
            : Text('reports_history'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: const Color(0xFF1e3a8a),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
          )
        ],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              // Filter Chips
              Container(
                color: const Color(0xFFf5f5f5),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filters.map((filter) {
                      final bool isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Chip(
                            label: Text(
                              filter.toLowerCase().tr,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1e3a8a)
                                    : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? Colors.white
                                : const Color(0xFFe5e7eb),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: isSelected
                                  ? const BorderSide(
                                      color: Color(0xFF1e3a8a), width: 1)
                                  : BorderSide.none,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(
                child: ValueListenableBuilder<List<Report>>(
                    valueListenable:
                        ReportService().reports, // Listen to report updates
                    builder: (context, reports, child) {
                      // Filter logic
                      var filteredReports = _selectedFilter == 'all'
                          ? reports
                          : reports.where((r) {
                              final status = r.status;
                              if (_selectedFilter == 'pending') {
                                return status == ReportStatus.pending;
                              }
                              if (_selectedFilter == 'inprogress') {
                                return status == ReportStatus.inProgress;
                              }
                              if (_selectedFilter == 'solved') {
                                return status == ReportStatus.solved;
                              }
                              return false;
                            }).toList();

                      // Search logic
                      if (_searchController.text.isNotEmpty) {
                        filteredReports = filteredReports.where((r) {
                          final query = _searchController.text.toLowerCase();
                          final id = r.id.toLowerCase();
                          final type = r.title.toLowerCase();
                          return id.contains(query) || type.contains(query);
                        }).toList();
                      }

                      if (filteredReports.isEmpty) {
                        return Center(child: Text("no_reports_found".tr));
                      }

                      return RefreshIndicator(
                          onRefresh: () async {
                            await ReportService().fetchReports();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportStatusPage(
                                            reportId: report.id)),
                                  );
                                },
                                child: ReportCard(
                                  reportId: report.id,
                                  status: report.status,
                                  incidentIcon:
                                      report.icon ?? Icons.report_problem,
                                  incidentIconColor:
                                      report.iconColor ?? Colors.grey,
                                  incidentType: report.incidentType,
                                  date:
                                      "${report.date.year}/${report.date.month}/${report.date.day}",
                                  aiTag: report.aiTag ?? "unknown_tag".tr,
                                  confidence: report.confidence ?? 0.0,
                                ),
                              );
                            },
                          ));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

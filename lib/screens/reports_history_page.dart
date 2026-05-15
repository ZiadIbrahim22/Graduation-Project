import 'package:flutter/material.dart';
import '../widgets/report_card.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../services/localization_service.dart';
import 'report_status_page.dart';
import 'package:intl/intl.dart';

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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ReportService().fetchMoreReports();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          // ✅ مهم: عشان الـ transition يحصل in-place من غير ما يغير الـ layout
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: -1, // يبدأ من الشمال
                child: child,
              ),
            );
          },
          child: _isSearching
              ? Container(
                  key: const ValueKey('search'),
                  height: 40,
                  // ✅ ثبت العرض عشان ميحصلش قفزة
                  width: MediaQuery.of(context).size.width - 100, // اطرح مساحة الـ actions
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    cursorColor: const Color(0xFF1e3a8a),
                    decoration: InputDecoration(
                      hintText: 'search_reports'.tr,
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                )
              : Text(
                  'reports_history'.tr,
                  key: const ValueKey('title'),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              // Filter Chips - using Container instead of Chip for full control
              Container(
                color: isDark ? const Color(0xFF121212) : const Color(0xFFf5f5f5),
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
                            _scrollController.animateTo(0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1e3a8a)
                                  : isDark 
                                      ? const Color(0xFF2a2a2a)
                                      : const Color(0xFFe5e7eb),
                              borderRadius: BorderRadius.circular(24),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF1e3a8a), width: 1.5)
                                  : null,
                            ),
                            child: Text(
                              filter.toLowerCase().tr,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(
                child: ValueListenableBuilder<List<Report>>(
                  valueListenable: ReportService().reports,
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
                        return r.id.toLowerCase().contains(query) ||
                            r.title.toLowerCase().contains(query);
                      }).toList();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ReportService().fetchReports();
                      },
                      child: filteredReports.isEmpty &&
                              !ReportService().isFetchingMore
                          ? LayoutBuilder(
                              builder: (context, constraints) => ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight,
                                    child: Center(
                                      child: Text(
                                        "no_reports_found".tr,
                                        style: TextStyle(
                                          color: isDark ? Colors.white54 : Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding: EdgeInsets.only(
                                left: 16, 
                                right: 16, 
                                top: 16,
                                bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight,
                              ),
                              itemCount: filteredReports.length +
                                  (ReportService().hasMore &&
                                          _selectedFilter == 'all' &&
                                          _searchController.text.isEmpty
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredReports.length) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                final report = filteredReports[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReportStatusPage(
                                            reportId: report.id),
                                      ),
                                    );
                                  },
                                  child: ReportCard(
                                    reportId: report.id,
                                    status: report.status,
                                    incidentIcon: report.icon,
                                    incidentIconColor: report.iconColor,
                                    incidentType: report.incidentType,
                                    date: DateFormat('yyyy/M/d - h:mm a').format(report.date),
                                    aiTag: report.aiTag ?? "unknown_tag".tr,
                                    confidence: report.formattedConfidence ??
                                        "${(report.confidence ?? 0).toStringAsFixed(0)} %",
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
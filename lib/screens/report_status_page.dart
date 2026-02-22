import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/localization_service.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class ReportStatusPage extends StatefulWidget {
  final String reportId;

  const ReportStatusPage({super.key, required this.reportId});

  @override
  State<ReportStatusPage> createState() => _ReportStatusPageState();
}

class _ReportStatusPageState extends State<ReportStatusPage>
    with SingleTickerProviderStateMixin {
  // 5 Status Steps
  final List<String> _allSteps = [
    "report_submitted".tr,
    "ai_analysis".tr,
    "sent_authorities".tr,
    "team_assigned".tr,
    "solved".tr
  ];

  Map<String, dynamic>? _reportStatus;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _fetchStatus();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    await ReportService().fetchReports();
    final report = ReportService().getReportById(widget.reportId);

    if (mounted) {
      if (report != null) {
        setState(() {
          _reportStatus = {
            "reportId": report.id,
            "statusIndex": _getStatusIndex(report.status),
            "status": report.status,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "report_not_found".tr;
          _isLoading = false;
        });
      }
    }
  }

  int _getStatusIndex(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 1; // "AI Analysis" / "Sent"
      case ReportStatus.inProgress:
        return 3; // "Maintenance Team Assigned"
      case ReportStatus.solved:
        return 4; // "Resolved"
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have data, use the index from API, else default to 0
    int currentStepIndex = 0;
    if (_reportStatus != null) {
      currentStepIndex = _reportStatus!['statusIndex'] ?? 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: Text('report_status'.tr,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1e3a8a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Header Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'tracking_id'.tr,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.reportId,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1e3a8a)),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: currentStepIndex ==
                                            _allSteps.length - 1
                                        ? const Color(0xFF22c55e).withValues(
                                            alpha: 0.1) // Green bg for valid
                                        : const Color(0xFFf97316).withValues(
                                            alpha:
                                                0.1), // Orange bg for pending
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentStepIndex == _allSteps.length - 1
                                        ? 'resolved'.tr.toUpperCase()
                                        : 'inprogress'.tr.toUpperCase(),
                                    style: TextStyle(
                                      color: currentStepIndex ==
                                              _allSteps.length - 1
                                          ? const Color(0xFF22c55e)
                                          : const Color(0xFFf97316),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Vertical Stepper
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _allSteps.length,
                            itemBuilder: (context, index) {
                              // Logic for status state
                              // index < currentStepIndex => Completed (Past) => Checkmark
                              // index == currentStepIndex => Current => CircleOutDated (Time/Processing)
                              // index > currentStepIndex => Pending => Empty/Grey
                              // Exception: If resolved (last step) is current, it should be Checkmark too.

                              bool isCompleted = index < currentStepIndex;
                              bool isCurrent = index == currentStepIndex;
                              bool isResolved =
                                  currentStepIndex == _allSteps.length - 1;

                              // If we are at the last step and it is current, it means we are done.
                              bool showCheck =
                                  isCompleted || (isCurrent && isResolved);

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      // Icon
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: showCheck
                                              ? const Color(0xFF1e3a8a)
                                              : (isCurrent
                                                  ? Colors.white
                                                  : Colors.white),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isCurrent || showCheck
                                                ? const Color(0xFF1e3a8a)
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: showCheck
                                              ? const Icon(Icons.check,
                                                  size: 16, color: Colors.white)
                                              : (isCurrent
                                                  ? const Icon(
                                                      Icons
                                                          .hourglass_empty_rounded, // "circleOutDated" -> Pending/Time
                                                      size: 16,
                                                      color: Color(0xFF1e3a8a))
                                                  : null),
                                        ),
                                      ),
                                      // Line
                                      if (index != _allSteps.length - 1)
                                        Container(
                                          width: 2,
                                          height:
                                              50, // Height of line between steps
                                          color: isCompleted
                                              ? const Color(0xFF1e3a8a)
                                              : Colors.grey.shade300,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _allSteps[index].tr,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: showCheck || isCurrent
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: showCheck || isCurrent
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                          if (isCurrent && !isResolved)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                "${'estimated_time'.tr} 2 ${'days'.tr}",
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1, // Reports active
        onItemTapped: (index) {
          if (index != 1) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.pop(context); // Go back to history list
          }
        },
      ),
    );
  }
}

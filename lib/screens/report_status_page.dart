import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/report_service.dart';
import '../models/report.dart';

// ─── Pulsing icon for the current active step ───────────────────────────────
class _PulsingStepIcon extends StatefulWidget {
  const _PulsingStepIcon();

  @override
  State<_PulsingStepIcon> createState() => _PulsingStepIconState();
}

class _PulsingStepIconState extends State<_PulsingStepIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 3.14159)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(3.14159),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.14159, end: 3.14159 * 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(3.14159 * 2),
        weight: 15,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        return Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1e3a8a),
          ),
          child: Center(
            child: Transform.rotate(
              angle: _rotation.value,
              child: const Icon(
                Icons.hourglass_empty,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}



class _DashedCircle extends StatelessWidget {
  const _DashedCircle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _DashedCirclePainter(
        color: Colors.grey.shade400,
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    const dashCount = 10;
    const dashAngle = 3.14159 * 2 / dashCount;
    const gapRatio = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = dashAngle * i;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

// ─── Main Page ───────────────────────────────────────────────────────────────
class ReportStatusPage extends StatefulWidget {
  final String reportId;

  const ReportStatusPage({super.key, required this.reportId});

  @override
  State<ReportStatusPage> createState() => _ReportStatusPageState();
}

class _ReportStatusPageState extends State<ReportStatusPage>
    with SingleTickerProviderStateMixin {
  final List<String> _allSteps = [
    "report_submitted".tr,
    "ai_analysis".tr,
    "sent_authorities".tr,
    "team_assigned".tr,
    "solved".tr,
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
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    Report? report = ReportService().getReportById(widget.reportId);
    if (report == null) {
      await ReportService().fetchReports();
      report = ReportService().getReportById(widget.reportId);
    }

    if (mounted) {
      if (report != null) {
        final statusIndex = _getStatusIndex(report.status);
        setState(() {
          _reportStatus = {
            "reportId": report!.id,
            "statusIndex": statusIndex,
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

  /// Maps backend status → step index
  /// pending   → 2 (Sent to Authorities) — AI already finished
  /// inProgress → 3 (Maintenance Team Assigned)
  /// solved    → 4 (Solved)
  int _getStatusIndex(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 2;
      case ReportStatus.inProgress:
        return 3;
      case ReportStatus.solved:
        return 4;
    }
  }

  /// Subtitle shown under the active step
  String? _getStepSubtitle(int stepIndex, bool isCurrent) {
    if (!isCurrent) return null;
    switch (stepIndex) {
      case 1:
        return 'ai_analysis_subtitle'.tr; // "جارٍ تحليل البلاغ تلقائيًا"
      case 2:
        return 'sent_authorities_subtitle'
            .tr; // "قيد المراجعة من الجهات المختصة"
      case 3:
        return 'team_assigned_subtitle'.tr; // "سيتم التواصل معك قريبًا"
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentStepIndex = 0;
    if (_reportStatus != null) {
      currentStepIndex = _reportStatus!['statusIndex'] ?? 0;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'report_status'.tr,
          style: const TextStyle(color: Colors.white),
        ),
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
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.white,
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                                  Colors.grey,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // ── Header Card ──────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'tracking_id'.tr,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.reportId,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Builder(
                                  builder: (context) {
                                    final ReportStatus? currentStatus =
                                        _reportStatus?['status']
                                            as ReportStatus?;
                                    final bool isPending =
                                        currentStatus == ReportStatus.pending;
                                    final bool isResolved = currentStepIndex ==
                                        _allSteps.length - 1;

                                    final Color statusColor = isPending
                                        ? Colors.grey
                                        : isResolved
                                            ? Colors.green
                                            : Colors.orange;

                                    final String statusText = isPending
                                        ? 'pending'.tr.toUpperCase()
                                        : isResolved
                                            ? 'resolved'.tr.toUpperCase()
                                            : 'inprogress'.tr.toUpperCase();

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ── Vertical Stepper ─────────────────────────────
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _allSteps.length,
                            itemBuilder: (context, index) {
                              final bool isCompleted = index < currentStepIndex;
                              final bool isCurrent = index == currentStepIndex;
                              final bool isResolved =
                                  currentStepIndex == _allSteps.length - 1;

                              // Show checkmark for completed steps and for
                              // the final "solved" step when it is active.
                              final bool showCheck =
                                  isCompleted || (isCurrent && isResolved);

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Left column: icon + connector line ──
                                  Column(
                                    children: [
                                      // Icon
                                      // ── Icon selection ─────────────────────────────────────────
                                      if (showCheck)
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1e3a8a),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      else if (isCurrent)
                                        const _PulsingStepIcon()
                                      else if (index ==
                                          currentStepIndex +
                                              1) // ← الخطوة القادمة فقط
                                        const _DashedCircle()
                                      else
                                        Container(
                                          // ← كل الخطوات البعيدة = دائرة عادية
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 2),
                                          ),
                                        ),
                                      // // Connector line
                                      if (index != _allSteps.length - 1)
                                        Container(
                                          width: 2,
                                          height: 50,
                                          color: isCompleted
                                              ? const Color(0xFF1e3a8a)
                                              : Colors.grey.shade300,
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 16),

                                  // ── Right column: label + subtitle ───────
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
                                                  ? Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color ??
                                                      Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                          if (isCurrent && !isResolved)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                _getStepSubtitle(
                                                        index, isCurrent) ??
                                                    "",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color ??
                                                      Colors.grey,
                                                  fontSize: 12,
                                                ),
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
    );
  }
}

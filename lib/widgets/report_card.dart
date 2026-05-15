import 'package:flutter/material.dart';
import 'package:reporting_system/services/localization_service.dart';
import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final String reportId;
  final ReportStatus status;
  final IconData? incidentIcon;
  final Color? incidentIconColor;
  final String incidentType;
  final String date;
  final String aiTag;
  final String confidence;

  const ReportCard({
    super.key,
    required this.reportId,
    required this.status,
    required this.incidentIcon,
    required this.incidentIconColor,
    required this.incidentType,
    required this.date,
    required this.aiTag,
    required this.confidence,
  });

  Color _getStatusBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case ReportStatus.pending:
        return isDark ? const Color(0xFF4a4a4a) : const Color(0xFFe5e7eb);
      case ReportStatus.inProgress:
        return isDark ? const Color(0xFF8B4513) : const Color(0xFFfed7aa);
      case ReportStatus.solved:
        return isDark ? const Color(0xFF14532d) : const Color(0xFFdcfce7);
    }
  }

  Color _getStatusTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case ReportStatus.pending:
        return isDark ? Colors.white70 : const Color(0xFF374151);
      case ReportStatus.inProgress:
        return isDark ? Colors.white : const Color(0xFF9a3412);
      case ReportStatus.solved:
        return isDark ? Colors.white : const Color(0xFF166534);
    }
  }

  String _getStatusText() {
    switch (status) {
      case ReportStatus.pending:
        return "pending".tr;
      case ReportStatus.inProgress:
        return "inprogress".tr;
      case ReportStatus.solved:
        return "solved".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reportId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1a1a1a),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFe5e7eb)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: incidentIconColor?.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(incidentIcon, color: incidentIconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "incident_type".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : const Color(0xFF6b7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            incidentType,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1a1a1a),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "confidence".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : const Color(0xFF6b7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            confidence,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1a1a1a),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: isDark ? Colors.white38 : const Color(0xFF9ca3af)),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : const Color(0xFF9ca3af),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
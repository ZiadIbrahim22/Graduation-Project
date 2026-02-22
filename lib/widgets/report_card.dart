import 'package:flutter/material.dart';
import 'package:reporting_system/services/localization_service.dart';
import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final String reportId;
  final ReportStatus status;
  final IconData incidentIcon;
  final Color incidentIconColor;
  final String incidentType;
  final String date;

  const ReportCard({
    super.key,
    required this.reportId,
    required this.status,
    required this.incidentIcon,
    required this.incidentIconColor,
    required this.incidentType,
    required this.date,
  });

  Color _getStatusColor() {
    switch (status) {
      case ReportStatus.pending:
        return const Color(0xFF9ca3af); // Pending Gray
      case ReportStatus.inProgress:
        return const Color(0xFFf97316); // In Progress Orange
      case ReportStatus.solved:
        return const Color(0xFF22c55e); // Solved Green
    }
  }

  String _getStatusText() {
    switch (status) {
      case ReportStatus.pending:
        return "pending".tr;
      case ReportStatus.inProgress:
        return "in_progress".tr;
      case ReportStatus.solved:
        return "solved".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reportId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.5)),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: incidentIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(incidentIcon, color: incidentIconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incidentType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

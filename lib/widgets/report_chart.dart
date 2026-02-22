import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:reporting_system/services/localization_service.dart';

class ReportChart extends StatelessWidget {
  final double pending;
  final double inProgress;
  final double solved;

  const ReportChart({
    super.key,
    this.pending = 0,
    this.inProgress = 0,
    this.solved = 0,
  });

  @override
  Widget build(BuildContext context) {
    double maxY = [pending, inProgress, solved]
        .reduce((curr, next) => curr > next ? curr : next);
    if (maxY < 5) maxY = 5;

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(0),
              tooltipMargin: 8,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Color(0xff7589a2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0:
                      text = Text('pending'.tr, style: style);
                      break;
                    case 1:
                      text = Text('inprogress'.tr, style: style);
                      break;
                    case 2:
                      text = Text('solved'.tr, style: style);
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 16.0,
                    child: text,
                  );
                },
                reservedSize: 42,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: pending,
                  color: const Color(0xFF9ca3af), // Pending Gray
                  width: 30,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: inProgress,
                  color: const Color(0xFFf97316), // In Progress Orange
                  width: 30,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: solved,
                  color: const Color(0xFF22c55e), // Solved Green
                  width: 30,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                ),
              ],
            ),
          ],
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

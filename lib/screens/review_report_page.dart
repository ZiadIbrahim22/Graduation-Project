import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/localization_service.dart';
import 'report_submitted_page.dart';
import '../services/report_service.dart';
import '../models/report.dart';
class ReviewReportPage extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReviewReportPage({super.key, required this.reportData});

  @override
  State<ReviewReportPage> createState() => _ReviewReportPageState();
}

class _ReviewReportPageState extends State<ReviewReportPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'review_report'.tr,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${'incident_type'.tr}: ${widget.reportData['category']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color(0xFF1e3a8a)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.reportData['location'],
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Map Thumbnail Placeholder
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: widget.reportData['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.reportData['image'],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                              ),
                      ),

                      const SizedBox(height: 35),
                      Text(
                        "Based_on_your_initial_analysis_the_report_will_be_browsed_to_Police_&_Traffic"
                            .tr,
                        style:
                            TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: _isSubmitting
                      ? "sending".tr
                      : "Confirm_&_Send_Report_Now".tr,
                  onPressed: _isSubmitting ? null : _sendReportToApi, 
                  backgroundColor: const Color(0xFF1e3a8a),
                  textColor: Colors.white,
                  icon: _isSubmitting ? null : Icons.electric_bolt_rounded, 
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "edit_report".tr,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  isOutline: true,
                  backgroundColor: const Color(0xFF1e3a8a),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // أضف في الـ State


Future<void> _sendReportToApi() async {
  setState(() => _isSubmitting = true);  // ← بدل showDialog

  try {
    String locationString = "${widget.reportData['lat']},${widget.reportData['lng']}";

    final newReport = Report(
      id: '',
      title: widget.reportData['title'],
      description: widget.reportData['description'],
      incidentType: widget.reportData['category'],
      location: locationString,
      date: DateTime.now(),
      status: ReportStatus.pending,
    );

    final result = await ReportService().addReport(
      newReport,
      widget.reportData['image'],
      lat: widget.reportData['lat'],
      lng: widget.reportData['lng'],
    );

    if (!mounted) return;

    String aiTag = result['aiTag']?.toString() ?? 'General';
    String displayConfidence = result['formattedConfidence']?.toString() ?? "0%";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReportSubmittedPage(
          reportId: result['reportId']?.toString() ?? 'N/A',
          aiTag: aiTag,
          confidenceText: displayConfidence,
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    setState(() => _isSubmitting = false);  // ← بدل Navigator.pop
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
            const SizedBox(width: 10),
            Text('Error: ${e.toString()}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
          ],
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/localization_service.dart';
import 'report_status_page.dart';
class ReportSubmittedPage extends StatefulWidget {
  final String reportId;
  final String confidenceText;
  final String aiTag;

  const ReportSubmittedPage({
    super.key,
    required this.reportId,
    required this.confidenceText,
    required this.aiTag,
  });

  @override
  State<ReportSubmittedPage> createState() => _ReportSubmittedPageState();
}

class _ReportSubmittedPageState extends State<ReportSubmittedPage>
    with SingleTickerProviderStateMixin {
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
          'report_submitted'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        leading: Builder(
          builder: (context) {
            return Container(); // Hide back button or custom
          },
        ),
        automaticallyImplyLeading: false, // Don't show back arrow
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22c55e),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'success'.tr,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${'report_id'.tr}: ${widget.reportId}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'view_report_status'.tr,
                    backgroundColor: const Color(0xFF1e3a8a),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ReportStatusPage(reportId: widget.reportId)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

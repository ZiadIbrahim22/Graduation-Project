import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/localization_service.dart';
import 'report_status_page.dart';

class ReportSubmittedPage extends StatefulWidget {
  final String reportId;

  const ReportSubmittedPage({super.key, required this.reportId});

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
      backgroundColor: const Color(0xFFf5f5f5),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF22c55e),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'success'.tr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${'report_id'.tr}: ${widget.reportId}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'view_report_status'.tr,
                    isOutline: true,
                    backgroundColor: const Color(0xFF1e3a8a),
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0, // Home active
        onItemTapped: (index) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Assuming Home is at index 0 and is the first route in stack (main.dart)
        },
      ),
    );
  }
}

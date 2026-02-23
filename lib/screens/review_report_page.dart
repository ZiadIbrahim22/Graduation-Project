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
          'review_report'.tr,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                              style: const TextStyle(color: Colors.grey),
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
                          color: Colors.grey[200],
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
                            : const Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                              ),
                      ),

                      const SizedBox(height: 20),

                      // Container(
                      //   padding: const EdgeInsets.all(12),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFf97316).withValues(alpha: 0.1),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: const Color(0xFFf97316)),
                      //   ),
                        // child: Row(
                        //   children: [
                        //     const Icon(Icons.warning_amber,
                        //         color: Color(0xFFf97316)),
                        //     const SizedBox(width: 12),
                        //     Expanded(
                        //       child: Text(
                        //         "AI Classification: ${widget.reportData['aiTag'] ?? 'Analyzing...'}",
                        //         style: const TextStyle(
                        //             color: Color(0xFFc2410c),
                        //             fontWeight: FontWeight.w600),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      // ),

                      const SizedBox(height: 16),
                      Text(
                        "Based_on_your_initial_analysis_the_report_will_be_browsed_to_Police_&_Traffic"
                            .tr,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: "Confirm_&_Send_Report_Now".tr,
                  onPressed: () {
                    _sendReportToApi();
                  },
                  backgroundColor: const Color(0xFFdc2626), // Red
                  icon: Icons
                      .electric_bolt_rounded, // Or checkmark icon inside button
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "edit_report".tr,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  isOutline: true,
                  backgroundColor: const Color(
                      0xFF1e3a8a), // Use blue for outline color context
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _sendReportToApi() async {
    try {
      // 1. إظهار مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 2. تجهيز موديل التقرير (حسب ما ReportService بيحتاج)
      // ملاحظة: الـ Location في الـ API بتاعك لازم يتبعت بصيغة "lat,lng"
      String locationString = "${widget.reportData['lat']},${widget.reportData['lng']}";

      final newReport = Report(
        id: '', 
        title: widget.reportData['title'],
        description: widget.reportData['description'],
        incidentType: widget.reportData['category'],
        location: locationString, // الصيغة اللي السيرفر طالبها
        date: DateTime.now(),
        status: ReportStatus.pending,
      );

      // 3. نداء خدمة الرفع
      // تأكد إن ReportService بيستخدم اسم الحقل "Photo" زي ما مكتوب في الـ JSON
      final result = await ReportService().addReport(
        newReport,
        widget.reportData['image'], // ملف الصورة
        lat: widget.reportData['lat'],
        lng: widget.reportData['lng'],
      );

      if (!mounted) return;
      Navigator.pop(context); // إخفاء التحميل

      String aiTag = result['aiTag'] ?? '';
      double realConfidence = (result['confidence'] as num).toDouble();

      // 4. الانتقال لصفحة النجاح
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportSubmittedPage(
            reportId: result['reportId']?.toString() ?? 'N/A', // أو الـ ID اللي راجع من السيرفر
            aiTag: aiTag,
            confidence: realConfidence * 100,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("report_submitted_success".tr),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      if(mounted){
        Navigator.pop(context); // إخفاء التحميل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white), // أيقونة خطأ
                const SizedBox(width: 10),
                Text('Error: ${e.toString()}'), // الرسالة
              ],
            ),
            backgroundColor: Colors.red, // لون الخلفية أحمر للخطأ
            behavior: SnackBarBehavior.floating, // يخلي الإشعار طاير مش لازق تحت
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3), // يختفي بعد 3 ثواني
          ),
        );
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:reporting_system/config/api_config.dart';
import '../widgets/report_chart.dart';
import 'notification_center_page.dart';
import 'create_report_page.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const HomePage({super.key, this.onNavigateToProfile});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> _stats = {
    "totalReports": 0,
    "thisMonth": 0,
    "pending": 0,
    "inProgress": 0,
    "solved": 0,
  };
  bool _isLoading = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    loadHomeData();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  void loadHomeData() async {
    try {
      final token = UserService().authToken;
      if (token == null) return;

      final profile = await ApiService.fetchProfile(token);
      final stats = await ApiService.fetchUserStats(token);
      print("Stats from API: $stats");

      final currentUser = UserService().currentUser.value;
      if (currentUser != null) {
        String rawPhoto = stats['photo'] ?? "";
        String fullImageUrl = (rawPhoto.isNotEmpty && !rawPhoto.startsWith('http'))
            ? '${ApiConfig.baseUrl}$rawPhoto'
            : rawPhoto;

        final updatedUser = currentUser.copyWith(
          fullName: profile['fullName'] ?? currentUser.fullName,
          profileImage: fullImageUrl.isNotEmpty ? fullImageUrl : currentUser.profileImage,
        );
        await UserService().saveUser(updatedUser);
      }
      
      if (mounted) {
        setState(() {
          _stats = {
            "totalReports": stats['totalReports'] ?? 0,
            "thisMonth": stats['thisMonth'] ?? 0,
            "pending": stats['pendingCount'] ?? 0,
            "inProgress": stats['inProgressCount'] ?? 0,
            "solved": stats['solvedCount'] ?? 0,
            "notifications": stats['notifications'] ?? 0,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading home data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  loadHomeData(); 
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Top section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: widget.onNavigateToProfile,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<UserModel?>(
                                      valueListenable: UserService().currentUser,
                                      builder: (context, user, child) {
                                        String? imageUrl = user?.profileImage;

                                        return CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.grey[800],
                                          backgroundImage: (imageUrl != null &&
                                                  imageUrl.isNotEmpty)
                                              ? NetworkImage(imageUrl)
                                              : null,
                                          child: (imageUrl == null ||
                                                  imageUrl.isEmpty)
                                              ? const Icon(Icons.person,
                                                  size: 25, color: Colors.white)
                                              : null,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'welcome'.tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        ValueListenableBuilder<UserModel?>(
                                          valueListenable:
                                              UserService().currentUser,
                                          builder: (context, user, _) {
                                            return Text(
                                              "${user?.fullName ?? 'User'}!",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1a1a1a),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationCenterPage()));
                                    },
                                    child: const Icon(Icons.notifications_none,
                                        size: 28),
                                  ),
                                ),
                                if ((_stats['notifications'] ?? 0) > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // // Active Reports Notification
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: 8,
                      //       height: 8,
                      //       decoration: const BoxDecoration(
                      //         color: Color(0xFFf97316),
                      //         shape: BoxShape.circle,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Text(
                      //       "${'you_have'.tr} ${_stats['inProgress']} ${'active_reports'.tr}",
                      //       style: const TextStyle(
                      //         color: Colors.grey,
                      //         fontSize: 14,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // const SizedBox(height: 20),

                      // Create New Report Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateReportPage()
                              )
                            );
                            loadHomeData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1e3a8a),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'create_report'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Report Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'report_summary'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${_stats['totalReports']} ${'total_reports'.tr}",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1a1a1a),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${'all_time'.tr} ",
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "+${_stats['thisMonth']} ${'this_month'.tr}",
                                                  style: const TextStyle(
                                                      color: Color(0xFF22c55e),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Mascot/Icon
                                      Opacity(
                                        opacity: 0.8,
                                        child: Icon(
                                          Icons.analytics_outlined,
                                          size: 40,
                                          color: const Color(0xFF1e3a8a)
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Bar Chart
                                  SizedBox(
                                    height: 200,
                                    child: ReportChart(
                                      pending:
                                          _stats['pending']?.toDouble() ?? 0,
                                      inProgress:
                                          _stats['inProgress']?.toDouble() ?? 0,
                                      solved: _stats['solved']?.toDouble() ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ))
    );
  }
}

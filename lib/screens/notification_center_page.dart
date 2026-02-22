import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../widgets/notification_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    NotificationService().fetchNotifications();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'search reports',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() {}),
              )
            : Text(
                'notifications'.tr,
                style: const TextStyle(color: Colors.white),
              ),
        backgroundColor: const Color(0xFF1e3a8a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ValueListenableBuilder<bool>(
            valueListenable: NotificationService().isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              String getFriendlyErrorMessage(String error) {
                if (error.contains('FormatException')) {
                  return "sorry_there_was_an_error_parsing_data_from_the_server"
                      .tr;
                } else if (error.contains('SocketException')) {
                  return "no_internet_connection_please_check_your_network".tr;
                } else if (error.contains('Hey ya!')) {
                  return "notification_path_not_found_on_the_server".tr;
                } else if (error.contains('404')) {
                  return "the_requested_page_was_not_found".tr;
                } else if (error.contains('User not authenticated')) {
                  return "please_login_again_to_view_notifications".tr;
                } else {
                  return "an_unexpected_error_occurred_please_try_again_later"
                      .tr;
                }
              }

              return ValueListenableBuilder<List<AppNotification>>(
                valueListenable: NotificationService().notifications,
                builder: (context, notifications, child) {
                  if (notifications.isEmpty) {
                    if (NotificationService().error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 50, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              getFriendlyErrorMessage(
                                  NotificationService().error!),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  NotificationService().fetchNotifications(),
                              child: Text('retry'.tr),
                            )
                          ],
                        ),
                      );
                    }
                    return Center(child: Text("no_notifications_yet".tr));
                  }

                  // Filter logic
                  final filteredNotifications = _searchController.text.isEmpty
                      ? notifications
                      : notifications.where((n) {
                          final query = _searchController.text.toLowerCase();
                          return n.title.toLowerCase().contains(query) ||
                              n.message.toLowerCase().contains(query);
                        }).toList();

                  if (filteredNotifications.isEmpty) {
                    return Center(child: Text("no_results_found".tr));
                  }

                  return RefreshIndicator(
                    onRefresh: () => NotificationService().fetchNotifications(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(
                            notification: filteredNotifications[index]);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2,
        onItemTapped: (index) {
          if (index != 2) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

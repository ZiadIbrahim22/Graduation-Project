import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _dipAnimation;

  late int _previousIndex;

  static const double _navBarHeight = 68.0;
  static const double _bubbleSize = 56.0;
  static const double _bubbleRise = 15.0;
  static const double _diveDepth = 45.0;
  static const double _notchDepth = 32.0;
  static const Color _navColor = Color(0xFF1e3a8a);
  static const Color _bubbleColor = Color(0xFF1e3a8a);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _xAnimation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(_controller);

    _dipAnimation = const AlwaysStoppedAnimation(0.0);
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final double from = _previousIndex.toDouble();
      final double to = widget.selectedIndex.toDouble();
      _previousIndex = widget.selectedIndex;

      _xAnimation = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
        ),
      );

      _dipAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
      ]).animate(_controller);

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: احسب الـ bottom inset (gesture bar / home indicator)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'home'.tr),
      _NavItem(icon: Icons.folder_rounded, label: 'reports'.tr),
      _NavItem(icon: Icons.person_rounded, label: 'profile'.tr),
    ];

    return SizedBox(
      // ✅ FIX: ارتفاع الـ navbar + مساحة شريط الإيماءات
      height: _navBarHeight + bottomPadding,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double xPos = _xAnimation.value;
          final double dip = _dipAnimation.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              final double itemWidth = totalWidth / items.length;
              // ✅ FIX RTL: في حالة RTL الـ Row بيعكس الأيقونات، فلازم نعكس الـ bubble كمان
              final bool isRtl = Directionality.of(context) == TextDirection.rtl;
              final double centerX = isRtl
                  ? totalWidth - (xPos + 0.5) * itemWidth
                  : (xPos + 0.5) * itemWidth;

              final double currentNotch =
                  _notchDepth + (_diveDepth * dip * 0.5);

              // ✅ FIX: الـ bubble يرتفع فوق الـ navbar الحقيقي، مش فوق الـ inset
              final double bubbleBottom = (_bubbleSize / 2) +
                  _bubbleRise -
                  (_bubbleRise + _diveDepth) * dip +
                  bottomPadding;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✅ FIX: امليء منطقة الـ inset بنفس لون الـ navbar (ما يبقاش فيه فراغ أبيض)
                  if (bottomPadding > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: bottomPadding + 1,
                      child: ColoredBox(color: _navColor),
                    ),

                  // ── الـ Bubble ──
                  Positioned(
                    bottom: bubbleBottom,
                    left: centerX - _bubbleSize / 2,
                    child: GestureDetector(
                      onTap: () => widget.onItemTapped(widget.selectedIndex),
                        child: Container(
                        width: _bubbleSize,
                        height: _bubbleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bubbleColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          items[widget.selectedIndex].icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  // ── خلفية الـ Navbar مع الـ Notch (فوق الـ inset بس) ──
                  Positioned(
                    bottom: bottomPadding,
                    left: 0,
                    right: 0,
                    height: _navBarHeight,
                    child: CustomPaint(
                      painter: _NotchPainter(
                        notchCenter: centerX,
                        notchRadius: _bubbleSize / 2 + 10,
                        notchDepth: currentNotch,
                        color: _navColor,
                      ),
                    ),
                  ),

                  // ── أيقونات الـ items غير المختارة (فوق الـ inset بس) ──
                  Positioned(
                    bottom: bottomPadding,
                    left: 0,
                    right: 0,
                    height: _navBarHeight,
                    child: Row(
                      children: List.generate(items.length, (i) {
                        final double dist = (xPos - i).abs().clamp(0.0, 1.0);
                        final double opacity =
                            dist < 0.05 ? 0.0 : dist.clamp(0.0, 1.0);

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => widget.onItemTapped(i),
                            child: Opacity(
                              opacity: opacity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    items[i].icon,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    items[i].label,
                                    style: TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── Painter الـ Navbar مع الـ Notch في الأعلى ──
class _NotchPainter extends CustomPainter {
  final double notchCenter;
  final double notchRadius;
  final double notchDepth;
  final Color color;

  const _NotchPainter({
    required this.notchCenter,
    required this.notchRadius,
    required this.notchDepth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double left = notchCenter - notchRadius - 12;
    final double right = notchCenter + notchRadius + 12;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(left, 0)
      ..cubicTo(left + 14, 0, notchCenter - notchRadius, notchDepth,
          notchCenter, notchDepth)
      ..cubicTo(notchCenter + notchRadius, notchDepth, right - 14, 0, right, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NotchPainter old) =>
      old.notchCenter != notchCenter || old.notchDepth != notchDepth;
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
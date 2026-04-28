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

  /// 0.0 = الـ bubble فوق عادي | 1.0 = نزلت داخل الشريط
  late Animation<double> _dipAnimation;

  late int _previousIndex;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // الـ SizedBox بياخد الـ _navBarHeight بس ← مفيش مساحة زيادة
  static const double _navBarHeight = 68.0;
  static const double _bubbleSize = 56.0;

  // كمية طلوع الـ bubble فوق الـ navbar (موجب = فوق)
  static const double _bubbleRise = 15.0;

  // كمية النزول للأسفل أثناء الانيميشن (بتروح جوه الشريط)
  static const double _diveDepth = 45.0;

  // عمق الـ notch المرسوم في الشريط
  static const double _notchDepth = 35.0;

  static const Color _navColor = Color(0xFF1e3a8a);
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

      // الأفقي: يبدأ بعد ما ينزل شوية ويخلص قبل ما يصحى
      _xAnimation = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
        ),
      );

      // الرأسي: ينزل جوه الشريط ويرجع يطلع
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
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'home'.tr),
      _NavItem(icon: Icons.folder_rounded, label: 'reports'.tr),
      _NavItem(icon: Icons.person_rounded, label: 'profile'.tr),
    ];

    return SizedBox(
      // ✅ ارتفاع ثابت = مفيش مساحة بيضا
      height: _navBarHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double xPos = _xAnimation.value;
          final double dip = _dipAnimation.value; // 0→1→0

          return LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              final double itemWidth = totalWidth / items.length;
              final double centerX = (xPos + 0.5) * itemWidth;

              // الـ notch بيعمق مع الـ dip
              final double currentNotch =
                  _notchDepth + (_diveDepth * dip * 0.5);

              // الـ bubble:
              //   لما dip=0 → فوق الـ navbar بمقدار _bubbleRise
              //   لما dip=1 → نازلة جوه الشريط بمقدار _diveDepth
              final double bubbleBottom = (_bubbleSize / 2) +
                  _bubbleRise -
                  (_bubbleRise + _diveDepth) * dip;

              return Stack(
                clipBehavior: Clip.none, // ✅ يسمح للـ bubble تطلع فوق
                children: [
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
                          color: _navColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
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
                  // ── خلفية الـ Navbar مع الـ Notch ──
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchPainter(
                        notchCenter: centerX,
                        notchRadius: _bubbleSize / 2 + 10,
                        notchDepth: currentNotch,
                        color: _navColor,
                      ),
                    ),
                  ),

                  // ── أيقونات الـ items غير المختارة ──
                  Positioned.fill(
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
                                    color: Colors.white.withValues(alpha: 0.65),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    items[i].label,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.65),
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
  final double notchDepth; // الـ notch بينزل للأسفل من أعلى الشريط
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

    // الـ notch في الأعلى (y=0) وبينزل للأسفل بمقدار notchDepth
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

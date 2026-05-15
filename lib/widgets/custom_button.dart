import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutline;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1e3a8a);
    final bgColor = backgroundColor ?? primaryBlue;
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : bgColor,
          foregroundColor: isOutline ? primaryBlue : txtColor,
          side: isOutline
              ? const BorderSide(color: primaryBlue)
              : BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isOutline ? 0 : 2,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOutline ? primaryBlue : txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
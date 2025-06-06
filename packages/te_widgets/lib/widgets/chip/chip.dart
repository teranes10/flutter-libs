import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class TChip extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final MaterialColor? color;
  final Color? background;
  final Color? textColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const TChip({
    super.key,
    this.text,
    this.icon,
    this.color = AppColors.primary,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background ?? color?.shade50 ?? Colors.blue,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: textColor ?? color?.shade400 ?? Colors.white,
              ),
              if (text != null) const SizedBox(width: 4),
            ],
            if (text != null)
              Text(
                text!,
                style: TextStyle(
                  color: textColor ?? color?.shade400 ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

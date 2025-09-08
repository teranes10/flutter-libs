import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TChip extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? color;
  final Color? background;
  final Color? textColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final TColorType? type;

  const TChip({
    super.key,
    this.text,
    this.icon,
    this.color,
    this.background,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final exTheme = context.exTheme;
    final mColor = color ?? exTheme.primary;
    final wTheme = context.getWidgetTheme(type ?? exTheme.chipType, mColor);
    final mBackgroundColor = background ?? wTheme.container;
    final mTextColor = textColor ?? wTheme.onContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: mBackgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            border: Border.all(color: wTheme.outline ?? Colors.transparent, width: 1)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: mTextColor),
              if (text != null) const SizedBox(width: 4),
            ],
            if (text != null) Text(text!, style: TextStyle(color: mTextColor, fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

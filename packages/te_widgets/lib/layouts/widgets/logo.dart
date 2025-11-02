import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TLogo extends StatelessWidget {
  final String? icon;
  final String? text;
  final VoidCallback? onTap;
  final Axis axis;
  final double size;
  final double fontSize;
  final double spacing;

  const TLogo({
    super.key,
    this.icon,
    this.text,
    this.onTap,
    this.axis = Axis.horizontal,
    this.size = 40,
    this.fontSize = 30,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: [
          if (icon != null) Image.asset(icon!, height: size, fit: BoxFit.cover),
          if (text != null) Text(text!, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: colors.primary)),
        ],
      ),
    );
  }
}

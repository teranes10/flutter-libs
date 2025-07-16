import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TLogo extends StatelessWidget {
  final String? icon;
  final String? text;
  final VoidCallback? onTap;
  final Axis axis;
  final double size;
  final double spacing;

  const TLogo({
    super.key,
    this.icon,
    this.text,
    this.onTap,
    this.axis = Axis.horizontal,
    this.size = 40,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return InkWell(
      onTap: onTap,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: [
          if (icon != null)
            Image.asset(
              icon!,
              height: 36,
              fit: BoxFit.cover,
            ),
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w500,
                color: theme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

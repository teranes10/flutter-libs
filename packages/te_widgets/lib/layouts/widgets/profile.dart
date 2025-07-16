import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TProfile extends StatelessWidget {
  final String? icon;
  final String? text;
  final Axis axis;
  final double size;
  final double spacing;

  const TProfile({
    super.key,
    this.icon,
    this.text,
    this.axis = Axis.horizontal,
    this.size = 40,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: [
        if (icon != null)
          Image.asset(
            icon!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        if (text != null)
          Text(
            text!,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: theme.onSurface,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final TShadowLevel shadow;

  const TCard({
    super.key,
    required this.child,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.onTap,
    this.boxShadow,
    this.shadow = TShadowLevel.low,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(8);

    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: elevation ?? shadow.toElevation(),
        borderRadius: defaultBorderRadius,
        color: backgroundColor ?? theme.surface,
        child: InkWell(
          borderRadius: defaultBorderRadius,
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: backgroundColor ?? theme.surface, boxShadow: boxShadow ?? shadow.toBoxShadow(), borderRadius: defaultBorderRadius),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

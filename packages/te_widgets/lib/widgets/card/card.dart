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
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(8);

    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: elevation ?? 1,
        borderRadius: defaultBorderRadius,
        color: backgroundColor ?? colors.surface,
        child: InkWell(
          borderRadius: defaultBorderRadius,
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor ?? colors.surface,
              boxShadow: boxShadow ?? [BoxShadow(color: colors.shadow, offset: const Offset(0, 2), blurRadius: 0, spreadRadius: 0)],
              borderRadius: defaultBorderRadius,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

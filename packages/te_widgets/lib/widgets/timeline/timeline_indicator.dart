import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A circular timeline indicator surrounded by a colored outer ring.
///
/// Features:
/// - Outer ring with customizable color, thickness, and gap.
/// - Inner circle background and icon colors resolved via [TVariant] and [TWidgetTheme].
/// - Inner icon matching the theme variant or custom overrides.
class TTimelineIndicator extends StatelessWidget {
  /// The total diameter (width and height) of the indicator.
  final double size;

  /// Color override for the indicator and ring.
  final Color? color;

  /// Specific color for the outer ring. Defaults to [color] or resolved variant color.
  final Color? ringColor;

  /// Specific background color for the inner circle.
  final Color? innerColor;

  /// Thickness of the outer colored ring. Defaults to 2.0.
  final double ringWidth;

  /// Gap spacing between the outer ring and the inner circle. Defaults to 2.5.
  final double ringGap;

  /// Optional icon to display inside the inner circle.
  final Widget? icon;

  /// Optional [IconData] shorthand for [icon].
  final dynamic iconData;

  /// Size of the icon. Defaults to `size * 0.44`.
  final double? iconSize;

  /// Color of the icon.
  final Color? iconColor;

  /// Visual variant of the indicator (solid, tonal, outline, etc.). Defaults to [TVariant.tonal].
  final TVariant variant;

  /// Whether the indicator represents an active/highlighted step.
  final bool isActive;

  /// Whether the indicator represents a completed step.
  final bool isCompleted;

  /// Whether this indicator renders a minimalist center dot.
  final bool isDot;

  /// Optional custom child widget inside the inner circle.
  final Widget? child;

  /// Callback when the indicator is tapped.
  final VoidCallback? onTap;

  const TTimelineIndicator({
    super.key,
    this.size = 36.0,
    this.color,
    this.ringColor,
    this.innerColor,
    this.ringWidth = 2.0,
    this.ringGap = 2.5,
    this.icon,
    this.iconData,
    this.iconSize,
    this.iconColor,
    this.variant = TVariant.tonal,
    this.isActive = false,
    this.isCompleted = false,
    this.isDot = false,
    this.child,
    this.onTap,
  });

  /// Factory for a simple dot indicator inside the colored ring.
  const TTimelineIndicator.dot({
    super.key,
    this.size = 24.0,
    this.color,
    this.ringColor,
    this.innerColor,
    this.ringWidth = 2.0,
    this.ringGap = 2.0,
    this.variant = TVariant.tonal,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
  })  : icon = null,
        iconData = null,
        iconSize = null,
        iconColor = null,
        isDot = true,
        child = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;

    // Resolve base color
    final resolvedColor = color ?? (isActive || isCompleted ? theme.primary : colors.outlineVariant);

    // Resolve widget theme from variant
    final wTheme = context.getWidgetTheme(variant, resolvedColor);

    // Resolve outer ring color
    final resolvedRingColor = ringColor ?? (isActive || isCompleted || color != null ? resolvedColor : colors.outlineVariant);

    // Resolve inner circle background and icon colors based on variant
    final resolvedInnerBg = innerColor ?? (wTheme.container.isTransparent ? colors.surface : wTheme.container);
    final resolvedFg = iconColor ?? (variant == TVariant.solid ? Colors.white : wTheme.onContainer);

    final resolvedIconSize = iconSize ?? (size * 0.44);

    Widget? contentWidget = child;
    if (contentWidget == null) {
      if (icon != null) {
        contentWidget = IconTheme(
          data: IconThemeData(color: resolvedFg, size: resolvedIconSize),
          child: icon!,
        );
      } else if (iconData != null) {
        contentWidget = TIcon.raw(iconData, size: resolvedIconSize, color: resolvedFg);
      } else if (isCompleted && !isDot) {
        contentWidget = TIcon.raw(HugeIcons.strokeRoundedTick01, size: resolvedIconSize, color: resolvedFg);
      } else if (isDot) {
        final dotSize = (size - 2 * (ringWidth + ringGap)) * 0.5;
        contentWidget = Center(
          child: Container(
            width: dotSize.clamp(4.0, 12.0),
            height: dotSize.clamp(4.0, 12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resolvedColor,
            ),
          ),
        );
      }
    }

    final innerDiameter = (size - 2 * ringWidth - 2 * ringGap).clamp(4.0, size);

    Widget indicatorWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: resolvedRingColor,
          width: ringWidth,
        ),
      ),
      padding: EdgeInsets.all(ringGap),
      child: Center(
        child: Container(
          width: innerDiameter,
          height: innerDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: resolvedInnerBg,
          ),
          child: contentWidget != null ? Center(child: contentWidget) : null,
        ),
      ),
    );

    if (onTap != null) {
      indicatorWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: indicatorWidget,
        ),
      );
    }

    return indicatorWidget;
  }
}

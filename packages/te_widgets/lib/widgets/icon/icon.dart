import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final EdgeInsets padding;
  final IconData? activeIcon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? activeColor;
  final Color? hoverColor;
  final (double initial, double active)? turns;
  final bool active;
  final int animationMilliseconds;

  const TIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 16,
    this.active = false,
    this.padding = const EdgeInsets.all(8),
    this.turns,
    this.animationMilliseconds = 200,
    this.color,
    this.activeIcon,
    this.activeColor,
    this.hoverColor,
  });

  factory TIcon.close(
    ColorScheme colors, {
    VoidCallback? onTap,
    double size = 20,
  }) {
    return TIcon(
      icon: Icons.cancel_outlined,
      onTap: onTap,
      size: size,
      color: colors.surfaceContainerHighest,
      hoverColor: colors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = color ?? colors.onSurfaceVariant;
    final hoverOrActiveColor = hoverColor ?? activeColor;

    Widget buildIcon({required bool isHovering}) {
      final effectiveIcon = active ? activeIcon ?? icon : icon;
      final effectiveColor = (isHovering && hoverOrActiveColor != null)
          ? hoverOrActiveColor
          : active
              ? (activeColor ?? baseColor)
              : baseColor;

      Widget iconWidget = Icon(effectiveIcon, size: size, color: effectiveColor);

      if (turns != null) {
        final (initialTurn, activeTurn) = turns!;
        iconWidget = AnimatedRotation(
          turns: active ? activeTurn : initialTurn,
          duration: Duration(milliseconds: animationMilliseconds),
          child: iconWidget,
        );
      }

      return iconWidget;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: padding,
        child: hoverOrActiveColor == null
            ? buildIcon(isHovering: false)
            : THoverable(builder: (context, isHovering) => buildIcon(isHovering: isHovering)),
      ),
    );
  }
}

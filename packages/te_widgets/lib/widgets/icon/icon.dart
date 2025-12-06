import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// An interactive icon with hover, active states, and rotation.
///
/// `TIcon` provides an enhanced icon widget with:
/// - Hover and active states
/// - Color transitions
/// - Rotation animations
/// - Tap handling
/// - Custom sizing and padding
///
/// ## Basic Usage
///
/// ```dart
/// TIcon(
///   icon: Icons.favorite,
///   onTap: () => print('Tapped'),
/// )
/// ```
///
/// ## With Active State
///
/// ```dart
/// TIcon(
///   icon: Icons.favorite_border,
///   activeIcon: Icons.favorite,
///   active: isFavorite,
///   color: Colors.grey,
///   activeColor: Colors.red,
///   onTap: () => setState(() => isFavorite = !isFavorite),
/// )
/// ```
///
/// ## With Rotation
///
/// ```dart
/// TIcon(
///   icon: Icons.refresh,
///   turns: (0, 1),  // Rotate 360° when active
///   active: isRefreshing,
///   onTap: () => refresh(),
/// )
/// ```
///
/// See also:
/// - [TImage] for image display
class TIcon extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon.
  final double size;

  /// Padding around the icon.
  final EdgeInsets padding;

  /// Alternative icon to show when active.
  final IconData? activeIcon;

  /// Callback fired when the icon is tapped.
  final VoidCallback? onTap;

  /// The default color of the icon.
  final Color? color;

  /// The color when active.
  final Color? activeColor;

  /// The color on hover.
  final Color? hoverColor;

  /// Rotation turns (initial, active) for animation.
  final (double initial, double active)? turns;

  /// Whether the icon is in active state.
  final bool active;

  /// Duration of rotation animation in milliseconds.
  final int animationMilliseconds;

  /// Creates an icon.
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

  /// Creates a close icon with default styling.
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

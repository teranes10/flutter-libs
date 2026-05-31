import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A badge widget that displays a small status or numerical indicator.
///
/// `TBadge` is usually used to wrap an icon or avatar to show notification counts,
/// status dots, or other small alerts.
///
/// ## Basic Usage
///
/// ```dart
/// TBadge(
///   count: 5,
///   child: Icon(Icons.notifications),
/// )
/// ```
///
/// ## Status Dot
///
/// ```dart
/// TBadge(
///   dot: true,
///   child: TAvatar(name: 'User'),
/// )
/// ```
class TBadge extends StatelessWidget {
  /// The widget to display the badge on.
  final Widget child;

  /// The numerical value to display in the badge.
  ///
  /// If [count] is null and [label] is null, nothing is displayed unless [dot] is true.
  final int? count;

  /// A custom text label to display instead of [count].
  final String? label;

  /// Whether to display a small dot instead of text/count.
  final bool dot;

  /// The background color of the badge.
  ///
  /// Defaults to [AppColors.danger].
  final Color? color;

  /// The text color of the badge.
  ///
  /// Defaults to white.
  final Color? textColor;

  /// The maximum count to display before showing a '+' sign.
  ///
  /// Defaults to 99.
  final int maxCount;

  /// Whether to hide the badge when [count] is 0.
  ///
  /// Defaults to true.
  final bool hideZero;

  /// Whether the badge is hidden.
  final bool hidden;

  /// The size of the badge (width/height).
  ///
  /// Defaults to 18 for count, 8 for dot.
  final double? size;

  /// Creates a badge.
  const TBadge({
    super.key,
    required this.child,
    this.count,
    this.label,
    this.dot = false,
    this.color,
    this.textColor,
    this.maxCount = 99,
    this.hideZero = true,
    this.hidden = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden || (hideZero && count == 0 && !dot && label == null)) {
      return child;
    }

    final badgeColor = color ?? AppColors.danger;
    final badgeTextColor = textColor ?? Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: dot ? -2 : -4,
          right: dot ? -2 : -4,
          child: _buildBadge(badgeColor, badgeTextColor),
        ),
      ],
    );
  }

  Widget _buildBadge(Color bgColor, Color fgColor) {
    if (dot) {
      return Container(
        width: size ?? 8,
        height: size ?? 8,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      );
    }

    String text = label ?? (count! > maxCount ? '$maxCount+' : count.toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: BoxConstraints(
        minWidth: size ?? 18,
        minHeight: size ?? 18,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: fgColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

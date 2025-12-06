import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A Material Design card widget with customizable styling and tap interaction.
///
/// `TCard` provides a container with elevation, rounded corners, and optional
/// tap interaction. It follows Material Design principles and integrates with
/// the app's theme system.
///
/// ## Basic Usage
///
/// ```dart
/// TCard(
///   child: Text('Card Content'),
/// )
/// ```
///
/// ## With Custom Styling
///
/// ```dart
/// TCard(
///   backgroundColor: Colors.blue.shade50,
///   borderRadius: BorderRadius.circular(16),
///   elevation: 4,
///   padding: EdgeInsets.all(24),
///   onTap: () => print('Card tapped'),
///   child: Column(
///     children: [
///       Icon(Icons.star),
///       Text('Featured Item'),
///     ],
///   ),
/// )
/// ```
///
/// See also:
/// - [Material] for the underlying Material widget
/// - [InkWell] for tap interaction
class TCard extends StatelessWidget {
  /// The widget to display inside the card.
  final Widget child;

  /// The external margin around the card.
  ///
  /// Defaults to `EdgeInsets.only(bottom: 8)`.
  final EdgeInsetsGeometry? margin;

  /// The elevation of the card (shadow depth).
  ///
  /// Defaults to 1.
  final double? elevation;

  /// The border radius of the card corners.
  ///
  /// Defaults to `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// The background color of the card.
  ///
  /// Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// The internal padding inside the card.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: 12, horizontal: 16)`.
  final EdgeInsetsGeometry padding;

  /// Callback fired when the card is tapped.
  ///
  /// If null, the card will not be interactive.
  final VoidCallback? onTap;

  /// Custom box shadows for the card.
  ///
  /// If null, uses a default shadow based on the theme.
  final List<BoxShadow>? boxShadow;

  /// Creates a Material Design card widget.
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

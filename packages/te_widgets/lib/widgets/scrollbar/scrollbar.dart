import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A customizable scrollbar with hover effects.
///
/// `TScrollbar` provides enhanced scrollbar with:
/// - Hover color changes
/// - Horizontal or vertical orientation
/// - Always visible or auto-hide
/// - Custom styling
///
/// ## Usage Example
///
/// ```dart
/// final scrollController = ScrollController();
///
/// TScrollbar(
///   controller: scrollController,
///   child: ListView.builder(
///     controller: scrollController,
///     itemCount: 100,
///     itemBuilder: (context, index) => ListTile(title: Text('Item \$index')),
///   ),
/// )
/// ```
///
/// ## Horizontal Scrollbar
///
/// ```dart
/// TScrollbar(
///   controller: scrollController,
///   isHorizontal: true,
///   child: SingleChildScrollView(
///     controller: scrollController,
///     scrollDirection: Axis.horizontal,
///     child: wideContent,
///   ),
/// )
/// ```
///
/// See also:
/// - [Scrollbar] for Material scrollbar
class TScrollbar extends StatelessWidget {
  /// The scroll controller for the scrollable widget.
  final ScrollController controller;

  /// Whether the scrollbar is horizontal.
  final bool isHorizontal;

  /// Whether the scrollbar thumb is always visible.
  final bool thumbVisibility;

  /// The scrollable child widget.
  final Widget child;

  /// Creates a scrollbar.
  const TScrollbar({
    super.key,
    required this.controller,
    this.isHorizontal = false,
    this.thumbVisibility = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return THoverable(
      builder: (context, isHovered) {
        return RawScrollbar(
          controller: controller,
          scrollbarOrientation: isHorizontal ? ScrollbarOrientation.bottom : ScrollbarOrientation.right,
          thumbVisibility: thumbVisibility,
          trackVisibility: true,
          interactive: true,
          thickness: 8.0,
          radius: const Radius.circular(8.0),
          thumbColor: isHovered ? colors.surfaceContainerLow : colors.surfaceContainerLowest,
          trackColor: Colors.transparent,
          trackBorderColor: Colors.transparent,
          crossAxisMargin: 0.0,
          mainAxisMargin: 0.0,
          minThumbLength: 36.0,
          child: child,
        );
      },
    );
  }
}

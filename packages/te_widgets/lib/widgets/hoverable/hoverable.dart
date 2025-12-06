import 'package:flutter/material.dart';

/// A widget that tracks hover state and rebuilds on hover changes.
///
/// `THoverable` provides hover detection with:
/// - Hover state tracking
/// - Custom mouse cursor
/// - Builder pattern for conditional rendering
///
/// ## Basic Usage
///
/// ```dart
/// THoverable(
///   builder: (context, isHovering) {
///     return Container(
///       color: isHovering ? Colors.blue : Colors.grey,
///       child: Text('Hover me'),
///     );
///   },
/// )
/// ```
///
/// ## With Custom Cursor
///
/// ```dart
/// THoverable(
///   cursor: SystemMouseCursors.grab,
///   builder: (context, isHovering) {
///     return Icon(
///       Icons.drag_handle,
///       color: isHovering ? Colors.blue : Colors.grey,
///     );
///   },
/// )
/// ```
class THoverable extends StatefulWidget {
  /// Builder function that receives hover state.
  final Widget Function(BuildContext context, bool isHovering) builder;

  /// The mouse cursor to display on hover.
  final MouseCursor cursor;

  /// Creates a hoverable widget.
  const THoverable({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  State<THoverable> createState() => _THoverableState();
}

class _THoverableState extends State<THoverable> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: widget.builder(context, _isHovering),
    );
  }
}

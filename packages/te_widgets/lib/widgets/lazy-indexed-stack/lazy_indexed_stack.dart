import 'package:flutter/material.dart';

/// A lazy-loading indexed stack that builds children on demand.
///
/// `TLazyIndexedStack` provides memory-efficient tab/page switching with:
/// - Lazy child building (only builds when first shown)
/// - Preserves state of built children
/// - Memory efficient for many tabs
///
/// ## Usage Example
///
/// ```dart
/// TLazyIndexedStack(
///   index: currentIndex,
///   children: [
///     (context) => HomePage(),
///     (context) => ProfilePage(),
///     (context) => SettingsPage(),
///   ],
/// )
/// ```
///
/// See also:
/// - [IndexedStack] for eager loading
/// - [TTabs] for tab navigation
class TLazyIndexedStack extends StatefulWidget {
  /// The index of the child to display.
  final int index;

  /// Builder functions for each child (built lazily).
  final List<WidgetBuilder> children;

  /// Creates a lazy indexed stack.
  const TLazyIndexedStack({required this.index, required this.children, super.key});

  @override
  State<TLazyIndexedStack> createState() => _TLazyIndexedStackState();
}

class _TLazyIndexedStackState extends State<TLazyIndexedStack> {
  late List<Widget?> _builtChildren;

  @override
  void initState() {
    super.initState();
    _builtChildren = List<Widget?>.filled(widget.children.length, null);
    _buildChild(widget.index);
  }

  void _buildChild(int index) {
    if (_builtChildren[index] == null) {
      _builtChildren[index] = widget.children[index](context);
    }
  }

  @override
  void didUpdateWidget(TLazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildChild(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: _builtChildren.map((child) => child ?? SizedBox()).toList(),
    );
  }
}

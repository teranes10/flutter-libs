import 'package:flutter/material.dart';

/// Manages scrolling behavior for tab widgets.
class TabScrollManager {
  final ScrollController scrollController;
  final Axis axis;
  final Map<dynamic, GlobalKey> tabKeys;

  TabScrollManager({
    required this.scrollController,
    required this.axis,
    required this.tabKeys,
  });

  /// Scrolls to the tab with the given value.
  void scrollToTab(dynamic selectedValue) {
    if (!scrollController.hasClients) return;

    final key = tabKeys[selectedValue];
    if (key?.currentContext == null) return;

    final RenderBox? renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);

    final scrollOffset = axis == Axis.horizontal
        ? position.dx - 50 // Add some padding
        : position.dy - 50;

    final targetOffset = scrollController.offset + scrollOffset;

    scrollController.animateTo(
      targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Scrolls backward by one viewport.
  void scrollToStart() {
    if (!scrollController.hasClients) return;

    final currentOffset = scrollController.offset;
    final viewportSize = scrollController.position.viewportDimension;
    final targetOffset = (currentOffset - viewportSize).clamp(0.0, scrollController.position.maxScrollExtent);

    scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Scrolls forward by one viewport.
  void scrollToEnd() {
    if (!scrollController.hasClients) return;

    final currentOffset = scrollController.offset;
    final viewportSize = scrollController.position.viewportDimension;
    final targetOffset = (currentOffset + viewportSize).clamp(0.0, scrollController.position.maxScrollExtent);

    scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Checks if scrolling to start is possible.
  bool canScrollStart() {
    return scrollController.hasClients && scrollController.offset > 0;
  }

  /// Checks if scrolling to end is possible.
  bool canScrollEnd() {
    return scrollController.hasClients && scrollController.offset < scrollController.position.maxScrollExtent;
  }
}

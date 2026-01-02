import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/lazy-indexed-stack/lazy_indexed_stack.dart';
import 'tab_controller.dart';
import 'tab.dart';

/// A widget that displays tab content based on a [TTabController].
///
/// Uses [TLazyIndexedStack] to efficiently render tab content only when needed.
/// Automatically rebuilds when the controller's value changes.
///
/// Example:
/// ```dart
/// final controller = TTabController<int>(initialValue: 0);
///
/// // Tabs
/// TTabs(
///   controller: controller,
///   tabs: myTabs,
/// )
///
/// // Content
/// TTabContent(
///   controller: controller,
///   tabs: myTabs,
/// )
/// ```
class TTabContent<T> extends StatelessWidget {
  /// The controller managing tab selection.
  final TTabController<T> controller;

  /// The list of tabs with their content builders.
  final List<TTab<T>> tabs;

  /// Creates a tab content widget.
  const TTabContent({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: controller,
      builder: (context, selectedValue, _) {
        final index = tabs.indexWhere((tab) => tab.value == selectedValue);
        final validIndex = index >= 0 ? index : 0;

        return TLazyIndexedStack(
          index: validIndex,
          children: tabs.map((tab) => (BuildContext context) => tab.content?.call(context) ?? const SizedBox.shrink()).toList(),
        );
      },
    );
  }
}

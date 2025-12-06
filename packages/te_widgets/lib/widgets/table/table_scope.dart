import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Provides table context to descendants.
///
/// `TTableScope` allows deep descendants in a table (like editable cells)
/// to access shared state, such as the currently active cell cursor
/// or the list controller.
class TTableScope extends InheritedWidget {
  /// The list controller managing the table data.
  final TListController controller;

  /// Notifier for the currently active editable cell key.
  final ValueNotifier<String?>? activeCellNotifier;

  /// Creates a table scope.
  const TTableScope({
    super.key,
    required this.controller,
    required this.activeCellNotifier,
    required super.child,
  });

  /// Retrieves the nearest [TTableScope] from the context (nullable).
  static TTableScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TTableScope>();
  }

  /// Retrieves the nearest [TTableScope] from the context (throws if not found).
  static TTableScope of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'TTableScope not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TTableScope oldWidget) =>
      controller != oldWidget.controller || activeCellNotifier != oldWidget.activeCellNotifier;
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Provides table context to descendants.
///
/// `TTableScope` allows deep descendants in a table (like editable cells)
/// to access shared state, such as the list controller or expansion mode.
///
/// > **Note**: The active editable cell is tracked separately by
/// > [TTableCellScope] to avoid unnecessary subtree rebuilds when a cell
/// > enters or exits edit mode.
class TTableScope extends InheritedWidget {
  /// The list controller managing the table data.
  final TListController controller;

  /// Whether the table is dense.
  final bool dense;

  /// The active expansion mode of the table.
  final TTableExpansionMode? expansionMode;

  /// Callback to check if closing is allowed.
  final Future<bool> Function(dynamic)? onWillCollapse;

  /// Creates a table scope.
  const TTableScope({
    super.key,
    required this.controller,
    required this.dense,
    this.expansionMode,
    this.onWillCollapse,
    required super.child,
  });

  /// Collapses or closes the active detail view, checking `onWillCollapse` if provided.
  Future<void> close(BuildContext context) async {
    if (onWillCollapse != null) {
      final allowed = await onWillCollapse!(controller.value.activeKey);
      if (!allowed) return;
    }

    if (!context.mounted) return;

    if (controller.value.isCreatingItem) {
      controller.cancelCreateItem();
    } else if (controller.value.isEditingItem) {
      controller.cancelEditItem();
    } else {
      controller.collapseAll();
    }

    if (expansionMode == TTableExpansionMode.dialog || expansionMode == TTableExpansionMode.page) {
      final useRoot = expansionMode == TTableExpansionMode.dialog;
      Navigator.of(context, rootNavigator: useRoot).maybePop();
    }
  }

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
      controller != oldWidget.controller ||
      dense != oldWidget.dense ||
      expansionMode != oldWidget.expansionMode ||
      onWillCollapse != oldWidget.onWillCollapse;
}

import 'package:flutter/material.dart';

/// Provides the active cell notifier to editable cell descendants.
///
/// `TTableCellScope` is an `InheritedNotifier` that wraps a
/// `ValueNotifier<String?>` tracking which cell is currently in edit mode.
/// Only widgets that call [TTableCellScope.of] or [TTableCellScope.maybeOf]
/// will subscribe and rebuild when the active cell changes — non-editable
/// cells and rows are completely unaffected.
///
/// This is deliberately separate from [TTableScope] so that activating a
/// cell does **not** trigger a full `TTableScope` subtree notification.
class TTableCellScope extends InheritedNotifier<ValueNotifier<String?>> {
  /// Creates a cell scope.
  ///
  /// [notifier] is the shared `ValueNotifier<String?>` owned by the table
  /// state. Pass `null` when the table is not editable; [maybeOf] will then
  /// return `null` and all cells will render in read-only mode.
  const TTableCellScope({
    super.key,
    required ValueNotifier<String?> super.notifier,
    required super.child,
  });

  /// Returns the active-cell notifier for the nearest [TTableCellScope], or
  /// `null` if no editable table is in scope.
  static ValueNotifier<String?>? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TTableCellScope>()?.notifier;
  }

  /// Returns the active-cell notifier for the nearest [TTableCellScope].
  ///
  /// Throws an assertion error if no [TTableCellScope] is found.
  static ValueNotifier<String?> of(BuildContext context) {
    final notifier = maybeOf(context);
    assert(notifier != null, 'TTableCellScope not found in context');
    return notifier!;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides the active cell notifier and cell error resolution to editable cell descendants.
///
/// `TTableCellScope` is an `InheritedNotifier` that wraps a
/// `ValueNotifier<String?>` tracking which cell is currently in edit mode,
/// and provides cell-level error lookup for validation in tables.
/// Only widgets that call [TTableCellScope.of] or [TTableCellScope.maybeOf]
/// will subscribe and rebuild when the active cell or errors change — non-editable
/// cells and rows are completely unaffected.
///
/// This is deliberately separate from [TTableScope] so that activating a
/// cell does **not** trigger a full `TTableScope` subtree notification.
class TTableCellScope extends InheritedNotifier<Listenable> {
  /// The active cell notifier tracking which cell is in edit mode.
  final ValueNotifier<String?> activeCellNotifier;

  /// Optional builder function to extract an error message for a given row item and column.
  final String? Function(dynamic data, String column)? cellErrorBuilder;

  /// Optional static map of cell errors keyed by cell key (e.g. `"${itemKey}_$column"` or `"$column"`).
  final Map<String, String>? cellErrors;

  /// Optional notifier for dynamic cell errors.
  final ValueListenable<Map<String, String>>? errorsNotifier;

  /// Creates a cell scope.
  ///
  /// [activeCellNotifier] is the shared `ValueNotifier<String?>` owned by the table
  /// state. Pass `null` when the table is not editable; [maybeOf] will then
  /// return `null` and all cells will render in read-only mode.
  TTableCellScope({
    super.key,
    required this.activeCellNotifier,
    this.cellErrorBuilder,
    this.cellErrors,
    this.errorsNotifier,
    required super.child,
  }) : super(
          notifier: errorsNotifier != null
              ? Listenable.merge([activeCellNotifier, errorsNotifier])
              : activeCellNotifier,
        );

  /// Returns the active-cell notifier for the nearest [TTableCellScope], or
  /// `null` if no editable table is in scope.
  static ValueNotifier<String?>? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TTableCellScope>()?.activeCellNotifier;
  }

  /// Returns the active-cell notifier for the nearest [TTableCellScope].
  ///
  /// Throws an assertion error if no [TTableCellScope] is found.
  static ValueNotifier<String?> of(BuildContext context) {
    final notifier = maybeOf(context);
    assert(notifier != null, 'TTableCellScope not found in context');
    return notifier!;
  }

  /// Returns the nearest [TTableCellScope], or `null` if none is in scope.
  static TTableCellScope? maybeScopeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TTableCellScope>();
  }

  /// Resolves the error message for a specific cell, if any.
  String? getError(dynamic data, String column, [String? cellKey]) {
    // 1. Check errors notifier if provided
    if (errorsNotifier != null) {
      final map = errorsNotifier!.value;
      if (cellKey != null && map.containsKey(cellKey)) {
        return map[cellKey];
      }
      if (map.containsKey(column)) {
        return map[column];
      }
    }
    // 2. Check static cell errors map
    if (cellErrors != null) {
      if (cellKey != null && cellErrors!.containsKey(cellKey)) {
        return cellErrors![cellKey];
      }
      if (cellErrors!.containsKey(column)) {
        return cellErrors![column];
      }
    }
    // 3. Check cellErrorBuilder callback
    if (cellErrorBuilder != null && data != null) {
      return cellErrorBuilder!(data, column);
    }
    return null;
  }

  /// Static helper to resolve an error for a cell from the nearest [TTableCellScope].
  static String? cellErrorOf(BuildContext context, dynamic data, String column, [String? cellKey]) {
    final scope = maybeScopeOf(context);
    return scope?.getError(data, column, cellKey);
  }
}


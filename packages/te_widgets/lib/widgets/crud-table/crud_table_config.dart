import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Configuration for [TCrudTable].
///
/// `TCrudConfig` defines permission checks, UI labels, tabs, and actions
/// available in the CRUD interface.
class TCrudConfig<T, K> {
  /// Check if viewing details is allowed.
  final Future<bool> Function(T)? canView;

  /// Check if editing is allowed.
  final Future<bool> Function(T)? canEdit;

  /// Check if deletion is allowed.
  final Future<bool> Function(T)? canDelete;

  /// Check if archiving is allowed.
  final Future<bool> Function(T)? canArchive;

  /// Check if restoring is allowed.
  final Future<bool> Function(T)? canRestore;

  // UI Labels
  /// Text for the "Add New" button.
  final String addButtonText;

  /// Tab definitions for the table view.
  final List<TTab<int>>? tabs;

  /// Content definitions for each tab.
  final List<TCrudTableContent<T, K>> tabContents;

  /// Placeholder text for the search bar.
  final String searchPlaceholder;

  // Action visibility
  /// Whether to show the actions column.
  final bool showActions;

  /// Default number of items per page.
  final int itemsPerPage;

  /// Options for items per page dropdown.
  final List<int> itemsPerPageOptions;

  /// Custom actions available for active items.
  final List<TCrudCustomAction<T>> activeActions;

  /// Custom actions available for archived items.
  final List<TCrudCustomAction<T>> archiveActions;

  /// Width of the action buttons column.
  final double actionButtonWidth;

  /// Custom actions to display in the top bar.
  final List<Widget> topBarActions;

  /// Creates a CRUD configuration.
  const TCrudConfig({
    this.canView,
    this.canEdit,
    this.canDelete,
    this.canArchive,
    this.canRestore,
    this.addButtonText = 'Add New',
    this.tabs,
    this.tabContents = const [],
    this.searchPlaceholder = 'Search...',
    this.showActions = true,
    this.itemsPerPage = 0,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.activeActions = const [],
    this.archiveActions = const [],
    this.topBarActions = const [],
    this.actionButtonWidth = 50.0,
  });
}

/// Defines a custom action button in the [TCrudTable].
class TCrudCustomAction<T> {
  /// Tooltip text for the action button.
  final String tooltip;

  /// Icon to display.
  final IconData icon;

  /// Color of the action button.
  final Color color;

  /// Callback when the action is pressed.
  final Future<void> Function(T item) onPressed;

  /// Optional check to enable/disable the action for specific items.
  final Future<bool> Function(T item)? canPerform;

  /// Creates a custom CRUD action.
  const TCrudCustomAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.canPerform,
  });
}

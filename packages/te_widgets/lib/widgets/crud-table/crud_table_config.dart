import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Permission strings guarding the built-in CRUD actions.
///
/// Each value is a `String` or [TPermission] checked against the nearest
/// [TAuthScope]. Denied actions are disabled by default; set [onDenied] to
/// [TAuthMode.hide] to remove them instead. These combine (AND) with the
/// per-row `canView`/`canEdit`/... checks in [TCrudConfig].
class TCrudPermissions {
  final Object? view;
  final Object? create;
  final Object? edit;
  final Object? delete;
  final Object? archive;
  final Object? restore;
  final Object? export;

  /// Overrides the denied behaviour for all built-in actions.
  final TAuthMode? onDenied;

  const TCrudPermissions({this.view, this.create, this.edit, this.delete, this.archive, this.restore, this.export, this.onDenied});

  /// Convenience: `orders.view`, `orders.create`, ... from a prefix.
  factory TCrudPermissions.prefix(String prefix, {TAuthMode? onDenied}) => TCrudPermissions(
        view: '$prefix.view',
        create: '$prefix.create',
        edit: '$prefix.edit',
        delete: '$prefix.delete',
        archive: '$prefix.archive',
        restore: '$prefix.restore',
        export: '$prefix.export',
        onDenied: onDenied,
      );
}

/// Configuration for [TCrudTable].
///
/// `TCrudConfig` defines permission checks, UI labels, tabs, and actions
/// available in the CRUD interface.
class TCrudConfig<T, K> {
  /// Permission strings for the built-in actions (see [TCrudPermissions]).
  final TCrudPermissions? permissions;

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

  /// Whether rows can be multi-selected via checkboxes, enabling bulk actions.
  ///
  /// When true, a checkbox column appears (desktop and mobile) and
  /// [bulkActionsBuilder] is used to render the top bar while at least one
  /// row is selected. Defaults to false -- fully backwards compatible with
  /// existing [TCrudTable] usages that never opt in.
  final bool enableBulkActions;

  /// Builds the top-bar content shown while one or more rows are selected
  /// (only used when [enableBulkActions] is true). Receives the active
  /// [TListController] so actions can read [TListController.selectedItems]
  /// / [TListController.selectedCount] and call
  /// [TListController.clearSelection] when done. Replaces [topBarActions]
  /// for the duration of the selection; falls back to the normal top bar
  /// (create button + [topBarActions]) when nothing is selected.
  final List<Widget> Function(BuildContext context, TListController<T, K> controller)? bulkActionsBuilder;

  /// Callback fired when a tab is selected.
  final void Function(int tab)? onTabChange;

  /// Whether the table layout should be dense.
  final bool? dense;

  /// Whether to render action buttons flat (inline/independently) instead of the default hoverable dropdown menu.
  final bool flatActions;

  /// Whether the footer pagination bar is skipped when there's only 1 page and no more items.
  final bool? optionalPaginationBar;

  /// Default layout presentation mode for items in card view. Defaults to [TKeyValueMode.inlineFlow].
  final TKeyValueMode? cardKeyValueMode;

  /// Explicit filter field definitions for the table.
  /// If omitted for client-side tables, filter fields are automatically inferred from [TTableHeader] definitions.
  /// For server-side tables, filters must be explicitly provided.
  final List<TFilterDef<T>>? filters;

  /// Whether to show the filter button in the top bar. Defaults to true.
  final bool? showFilter;

  /// Optional unique key to identify and persist table layout settings (dense layout, view mode, card layout).
  /// If null, settings are automatically persisted by the current route name.
  final String? storageKey;

  /// Whether the view action should render flat (inline).
  final bool canViewFlat;

  /// Whether the edit action should render flat (inline).
  final bool canEditFlat;

  /// Whether the delete action should render flat (inline).
  final bool canDeleteFlat;

  /// Whether the archive action should render flat (inline).
  final bool canArchiveFlat;

  /// Whether the restore action should render flat (inline).
  final bool canRestoreFlat;

  /// Whether to persist table layout settings (dense layout, view mode, card layout) per route or [storageKey]. Defaults to true.
  final bool? persistSettings;

  /// Creates a CRUD configuration.
  const TCrudConfig({
    this.permissions,
    this.canView,
    this.canEdit,
    this.canDelete,
    this.canArchive,
    this.canRestore,
    this.canViewFlat = true,
    this.canEditFlat = true,
    this.canDeleteFlat = false,
    this.canArchiveFlat = false,
    this.canRestoreFlat = false,
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
    this.enableBulkActions = false,
    this.bulkActionsBuilder,
    this.actionButtonWidth = 50.0,
    this.onTabChange,
    this.dense,
    this.flatActions = false,
    this.optionalPaginationBar,
    this.cardKeyValueMode,
    this.filters,
    this.showFilter = true,
    this.storageKey,
    this.persistSettings = true,
  });
}

/// Defines a custom action button in the [TCrudTable].
class TCrudCustomAction<T> {
  /// Tooltip text for the action button.
  final String tooltip;

  /// Icon to display.
  final dynamic icon;

  /// Color of the action button.
  final Color color;

  /// Callback when the action is pressed.
  final Future<void> Function(T item) onPressed;

  /// Optional check to enable/disable the action for specific items.
  final Future<bool> Function(T item)? canPerform;

  /// Whether this action should render flat (inline) when [TCrudConfig.flatActions] is false.
  final bool showFlat;

  /// Permission (`String` or [TPermission]) required for this action.
  final Object? permission;

  /// Overrides the denied behaviour (default: disabled).
  final TAuthMode? onDenied;

  /// Creates a custom CRUD action.
  const TCrudCustomAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.canPerform,
    this.showFlat = false,
    this.permission,
    this.onDenied,
  });
}

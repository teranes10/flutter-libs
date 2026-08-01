import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:pdf/widgets.dart' as pw;

part 'crud_table_top_bar.dart';
part 'crud_table_builder.dart';
part 'crud_table_actions.dart';
part 'crud_table_export.dart';
part 'crud_table_form.dart';
part 'crud_table_settings.dart';

/// A complete CRUD (Create, Read, Update, Delete) table component.
///
/// `TCrudTable` provides a full-featured data table with:
/// - Create, edit, view, archive, restore, and delete operations
/// - Form-based create/edit dialogs
/// - Active and archive tabs
/// - Permission-based action visibility
/// - Expandable rows
/// - Server-side or client-side data
/// - Custom actions
///
/// ## Basic Usage
///
/// ```dart
/// TCrudTable<Product, int, ProductForm>(
///   headers: productHeaders,
///   items: products,
///   createForm: () => ProductForm(),
///   editForm: (product) => ProductForm.fromProduct(product),
///   onCreate: (form) async {
///     return await api.createProduct(form.toJson());
///   },
///   onEdit: (product, form) async {
///     return await api.updateProduct(product.id, form.toJson());
///   },
///   onArchive: (product) async {
///     await api.archiveProduct(product.id);
///     return true;
///   },
/// )
/// ```
///
/// ## With Archive Support
///
/// ```dart
/// TCrudTable<User, int, UserForm>(
///   headers: userHeaders,
///   onLoad: (options) async {
///     final response = await api.getUsers(options);
///     return TLoadResult(
///        response.users,
///        response.total,
///     );
///   },
///   onArchiveLoad: (options) async {
///     final response = await api.getArchivedUsers(options);
///     return TLoadResult(
///        response.users,
///        response.total,
///     );
///   },
///   onRestore: (user) async {
///     await api.restoreUser(user.id);
///     return true;
///   },
///   onDelete: (user) async {
///     await api.deleteUser(user.id);
///     return true;
///   },
/// )
/// ```
///
/// Type parameters:
/// - [T]: The type of items in the table
/// - [K]: The type of the item key
/// - [F]: The form type (must extend TFormBase)
///
/// - [TFormBase] for form definitions
class TCrudTable<T, K, F extends TFormBase> extends StatefulWidget {
  /// The column headers for the table.
  final List<TTableHeader<T, K>> headers;

  /// The list of active items (for client-side).
  final List<T>? items;

  /// Callback for loading active items (for server-side).
  final TLoadListener<T>? onLoad;

  /// Controller for managing active items.
  final TListController<T, K>? controller;

  /// Callback fired when the active list controller is initialized and ready.
  final TControllerReadyListener<T, K>? onControllerReady;

  /// The list of archived items (for client-side).
  final List<T>? archivedItems;

  /// Callback for loading archived items (for server-side).
  final TLoadListener<T>? onArchiveLoad;

  /// Controller for managing archived items.
  final TListController<T, K>? archiveController;

  /// Callback fired when the archived list controller is initialized and ready.
  final void Function(TListController<T, K> controller)? onArchiveControllerReady;

  /// Factory function to create a new form.
  final F Function()? createForm;

  /// Factory function to create an edit form from an item.
  final F Function(T item)? editForm;

  /// Callback for creating a new item.
  final Future<T?> Function(F form)? onCreate;

  /// Callback for editing an existing item.
  final Future<T?> Function(T item, F form)? onEdit;

  /// Callback for viewing an item.
  final Future<void> Function(T item)? onView;

  /// Callback for archiving an item.
  final Future<bool?> Function(T item)? onArchive;

  /// Callback for restoring an archived item.
  final Future<bool?> Function(T item)? onRestore;

  /// Callback for permanently deleting an item.
  final Future<bool?> Function(T item)? onDelete;

  /// Configuration for the CRUD table.
  final TCrudConfig<T, K> config;

  /// Builder for expanded row content.
  final TListExpandedBuilder<T, K>? expandedBuilder;

  /// Detailed configuration for row expansion. If provided, overrides [expansionMode], [createMode], [expandedBuilder], etc.
  final TTableDetails<T, K>? expandedDetails;

  /// Defines how the expanded content is presented.
  final TTableExpansionMode expansionMode;

  /// Defines how the expanded content is presented during creation/editing.
  final TTableExpansionMode? createMode;

  /// Custom width for the dialog when creating or editing items in dialog mode.
  final double? createDialogWidth;

  /// Function to extract the title from an item.
  final String? Function(T item)? itemTitle;

  /// Function to extract the sub-title from an item.
  final String? Function(T item)? itemSubTitle;

  /// Function to extract the description from an item.
  final String? Function(T item)? itemDescription;

  /// Function to extract the image URL from an item.
  final String? Function(T item)? itemImageUrl;

  /// Function to extract key-value information from an item.
  final List<TKeyValue>? Function(T item)? itemInfo;

  /// Whether to display key and value inline in grid layout (Key: Value) for itemInfo. Defaults to true.
  final bool itemInfoGridInline;

  final TTableTheme? theme;

  /// Custom builder for the row.
  ///
  /// If provided, this builder is called for each row and can be used to
  /// wrap or replace the default row card.
  final Widget Function(BuildContext ctx, TListItem<T, K> item, int index, Widget row)? rowBuilder;

  /// Custom builder for the row background color.
  final Color? Function(TListItem<T, K> item, int index)? rowColorBuilder;

  /// Creates a CRUD table.
  const TCrudTable({
    super.key,
    required this.headers,
    this.items,
    this.onLoad,
    this.archivedItems,
    this.onArchiveLoad,
    this.createForm,
    this.editForm,
    this.onCreate,
    this.onView,
    this.onEdit,
    this.onArchive,
    this.onRestore,
    this.onDelete,
    this.config = const TCrudConfig(),
    this.controller,
    this.onControllerReady,
    this.archiveController,
    this.onArchiveControllerReady,
    this.expandedBuilder,
    this.expandedDetails,
    this.expansionMode = TTableExpansionMode.dialog,
    this.createMode,
    this.createDialogWidth,
    this.itemTitle,
    this.itemSubTitle,
    this.itemDescription,
    this.itemImageUrl,
    this.itemInfo,
    this.itemInfoGridInline = true,
    this.theme,
    this.rowBuilder,
    this.rowColorBuilder,
  })  : assert(
          controller == null || (items == null && onLoad == null && onControllerReady == null),
          'Provide either `controller` OR (`items` / `onLoad` / `onControllerReady`), not both.',
        ),
        assert(
          archiveController == null || (archivedItems == null && onArchiveLoad == null && onArchiveControllerReady == null),
          'Provide either `archiveController` OR (`archivedItems` / `onArchiveLoad` / `onArchiveControllerReady`), not both.',
        );

  @override
  State<TCrudTable<T, K, F>> createState() => _TCrudTableState<T, K, F>();
}

class _TCrudTableState<T, K, F extends TFormBase> extends State<TCrudTable<T, K, F>> {
  late final TListController<T, K> _listController;
  late final TListController<T, K> _archiveListController;

  late final bool _isControllerOwned;
  late final bool _isArchiveControllerOwned;

  int _currentTab = 0;
  final Map<T, Map<String, bool>> _permissionCache = {};

  bool _hasInitializedRouteSettings = false;

  bool _dense = false;
  bool get dense => _dense;
  set dense(bool value) {
    setState(() => _dense = value);
    _persistRouteSettings();
  }

  int _viewMode = 0; // 0: Table, 1: Card, 2: Grid
  int get viewMode => _viewMode;
  set viewMode(int value) {
    setState(() => _viewMode = value);
    _persistRouteSettings();
  }

  TTableExpansionMode? _selectedExpansionMode;
  TTableExpansionMode get effectiveExpansionMode => _selectedExpansionMode ?? widget.expandedDetails?.mode ?? widget.expansionMode;
  set expansionMode(TTableExpansionMode mode) {
    setState(() => _selectedExpansionMode = mode);
    _persistRouteSettings();
  }

  TTableExpansionMode? _selectedCreateMode;
  TTableExpansionMode get effectiveCreateMode =>
      _selectedCreateMode ?? widget.expandedDetails?.createMode ?? widget.createMode ?? widget.expansionMode;
  set createMode(TTableExpansionMode mode) {
    setState(() => _selectedCreateMode = mode);
    _persistRouteSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedRouteSettings && (widget.config.persistSettings ?? true)) {
      _hasInitializedRouteSettings = true;
      _restoreRouteSettings();
    }
  }

  @override
  void initState() {
    super.initState();

    _dense = widget.config.dense ?? false;

    _isControllerOwned = widget.controller == null;
    _isArchiveControllerOwned = widget.archiveController == null;

    _listController = widget.controller ??
        TListController<T, K>(
          itemsPerPage: widget.config.itemsPerPage,
          items: widget.items ?? [],
          onLoad: widget.onLoad,
        );

    widget.onControllerReady?.call(_listController);

    _archiveListController = widget.archiveController ??
        TListController<T, K>(
          itemsPerPage: widget.config.itemsPerPage,
          items: widget.archivedItems ?? [],
          onLoad: widget.onArchiveLoad,
          itemKey: _listController.itemKey,
        );

    widget.onArchiveControllerReady?.call(_archiveListController);
  }

  @override
  void didUpdateWidget(covariant TCrudTable<T, K, F> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.items != null && widget.items != null) && !oldWidget.items!.listEquals(widget.items!)) {
      _listController.updateItems(widget.items ?? []);
    }

    if ((oldWidget.archivedItems != null && widget.archivedItems != null) && !oldWidget.archivedItems!.listEquals(widget.archivedItems!)) {
      _archiveListController.updateItems(widget.archivedItems ?? []);
    }
  }

  @override
  void dispose() {
    _permissionCache.clear();
    if (_isControllerOwned) {
      _listController.dispose();
    }
    if (_isArchiveControllerOwned) {
      _archiveListController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tableTheme = widget.theme ?? theme.tableTheme;

    Widget headerContent(BuildContext ctx) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tableTheme.headerBuilder != null) tableTheme.headerBuilder!(ctx),
          LayoutBuilder(builder: _buildTopBar),
        ],
      );
    }

    return _buildContent(
      theme,
      tableTheme.copyWith(
        headerBuilder: headerContent,
      ),
    );
  }

  // Getters for child classes
  bool get hasArchive => widget.archivedItems != null || widget.onArchiveLoad != null || widget.archiveController != null;
  bool get showTabs => hasArchive || widget.config.tabs != null;
  List<TTab> get tabs => widget.config.tabs ?? const [TTab(text: "Active", value: 0), TTab(text: "Archive", value: 1)];
  bool get canCreate => widget.createForm != null && widget.onCreate != null;
  bool get canEdit => widget.editForm != null && widget.onEdit != null;
  bool get hasActiveActions => widget.onView != null || canEdit || widget.onArchive != null || widget.config.activeActions.isNotEmpty;
  bool get hasArchiveActions =>
      widget.onView != null || widget.onRestore != null || widget.onDelete != null || widget.config.archiveActions.isNotEmpty;

  // Getters for controllers and notifiers
  TListController<T, K> get listController => _listController;
  TListController<T, K> get archiveListController => _archiveListController;
  int get currentTab => _currentTab;
  set currentTab(int value) => setState(() => _currentTab = value);
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:pdf/widgets.dart' as pw;

part 'crud_table_top_bar.dart';
part 'crud_table_builder.dart';

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
/// See also:
/// Position where the form is shown.
enum TCrudFormPosition {
  /// Show the form in-page (above table or replacing the row).
  inline,

  /// Show the form in a dialog modal.
  dialog,
}

/// - [TDataTable] for simple data tables
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

  /// The list of archived items (for client-side).
  final List<T>? archivedItems;

  /// Callback for loading archived items (for server-side).
  final TLoadListener<T>? onArchiveLoad;

  /// Controller for managing archived items.
  final TListController<T, K>? archiveController;

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
  final Future<bool> Function(T item)? onArchive;

  /// Callback for restoring an archived item.
  final Future<bool> Function(T item)? onRestore;

  /// Callback for permanently deleting an item.
  final Future<bool> Function(T item)? onDelete;

  /// Configuration for the CRUD table.
  final TCrudConfig<T, K> config;

  /// Builder for expanded row content.
  final TListExpandedBuilder<T, K>? expandedBuilder;

  /// Custom theme for the table.
  final TTableTheme? theme;

  /// Custom builder for the row.
  ///
  /// If provided, this builder is called for each row and can be used to
  /// wrap or replace the default row card.
  final Widget Function(BuildContext ctx, TListItem<T, K> item, int index, Widget row)? rowBuilder;

  /// Custom builder for the row background color.
  final Color? Function(TListItem<T, K> item, int index)? rowColorBuilder;

  /// The position where the form is shown (inPage or dialog).
  final TCrudFormPosition formPosition;

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
    this.archiveController,
    this.expandedBuilder,
    this.theme,
    this.rowBuilder,
    this.rowColorBuilder,
    this.formPosition = TCrudFormPosition.inline,
  })  : assert(
          (controller == null && (items != null || onLoad != null)) || (controller != null && items == null && onLoad == null),
          'Provide either `controller` OR (`items` / `onLoad`), not both.',
        ),
        assert(
          (archiveController == null && archivedItems == null && onArchiveLoad == null) ||
              (archiveController == null && (archivedItems != null || onArchiveLoad != null)) ||
              (archiveController != null && (archivedItems == null && onArchiveLoad == null)),
          'Provide either `archiveController` OR (`archivedItems` / `onArchiveLoad`), not both.',
        );

  @override
  State<TCrudTable<T, K, F>> createState() => _TCrudTableState<T, K, F>();
}

class _TCrudTableState<T, K, F extends TFormBase> extends State<TCrudTable<T, K, F>> {
  late final TListController<T, K> _listController;
  late final TListController<T, K> _archiveListController;

  late final bool _isControllerOwned;
  late final bool _isArchiveControllerOwned;

  late final _TCrudTopBar<T, K, F> _topBar;
  late final _TCrudTableBuilder<T, K, F> _tableBuilder;

  int _currentTab = 0;
  final Map<T, Map<String, bool>> _permissionCache = {};

  F? _activeForm;
  T? _editingItem;

  @override
  void initState() {
    super.initState();

    _isControllerOwned = widget.controller == null;
    _isArchiveControllerOwned = widget.archiveController == null;

    _listController = widget.controller ??
        TListController<T, K>(
          itemsPerPage: widget.config.itemsPerPage,
          items: widget.items ?? [],
          onLoad: widget.onLoad,
        );

    _archiveListController = widget.archiveController ??
        TListController<T, K>(
            itemsPerPage: widget.config.itemsPerPage,
            items: widget.archivedItems ?? [],
            onLoad: widget.onArchiveLoad,
            itemKey: _listController.itemKey);

    _topBar = _TCrudTopBar<T, K, F>(parent: this);
    _tableBuilder = _TCrudTableBuilder<T, K, F>(parent: this);
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

    return _tableBuilder._buildContent(
      theme,
      tableTheme.copyWith(
        headerBuilder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tableTheme.headerBuilder != null) tableTheme.headerBuilder!(ctx),
            LayoutBuilder(builder: _topBar.build),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(F form, {required bool isEditing}) {
    final theme = context.theme;

    return TCard(
      elevation: widget.formPosition == TCrudFormPosition.dialog ? 0 : 1,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TFormBuilder(input: form),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              TButton(
                baseTheme: TWidgetTheme.surfaceTheme(context.colors),
                size: TButtonSize.md.copyWith(minW: 100),
                text: 'Cancel',
                onTap: handleCancelForm,
              ),
              TButton(
                loading: true,
                size: TButtonSize.md.copyWith(minW: 100),
                color: theme.primary,
                text: isEditing ? 'Update' : 'Save',
                onPressed: handleSaveForm,
              ),
            ],
          ),
        ],
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

  int _viewMode = 0; // 0: Table, 1: Card, 2: Grid
  int get viewMode => _viewMode;
  set viewMode(int value) => setState(() => _viewMode = value);

  // Permission methods
  bool canPerformActionSync(T item, Future<bool> Function(T)? permission) {
    if (permission == null) return true;

    final cacheKey = permission.toString();
    final itemCache = _permissionCache[item] ??= <String, bool>{};

    if (itemCache.containsKey(cacheKey)) {
      return itemCache[cacheKey]!;
    }

    itemCache[cacheKey] = true;
    _updatePermissionAsync(item, cacheKey, permission);

    return true;
  }

  void _updatePermissionAsync(T item, String cacheKey, Future<bool> Function(T) permission) {
    permission(item).then((result) {
      final itemCache = _permissionCache[item];
      if (itemCache != null && itemCache[cacheKey] != result) {
        itemCache[cacheKey] = result;
        if (mounted) setState(() {});
      }
    }).catchError((e) {
      final itemCache = _permissionCache[item];
      if (itemCache != null) {
        itemCache[cacheKey] = false;
        if (mounted) setState(() {});
      }
    });
  }

  // Action handlers
  void handleCreate() {
    if (widget.formPosition == TCrudFormPosition.inline) {
      setState(() {
        _activeForm?.dispose();
        _activeForm = widget.createForm?.call();
        _editingItem = null;
      });
    } else {
      _performAction(() async {
        final form = widget.createForm?.call();
        if (form == null) return;

        final formData = await TFormService.show(context, form);
        if (formData == null) return;

        final newItem = await widget.onCreate?.call(formData);
        if (newItem != null) {
          _listController.addItem(newItem);
        }

        form.reset();
        form.dispose();
      });
    }
  }

  void handleEdit(T item) {
    if (widget.formPosition == TCrudFormPosition.inline) {
      setState(() {
        _activeForm?.dispose();
        _activeForm = widget.editForm?.call(item);
        _editingItem = item;
      });
    } else {
      _performAction(() async {
        final form = widget.editForm?.call(item);
        if (form == null) return;

        final formData = await TFormService.show(context, form);
        if (formData == null) return;

        final updatedItem = await widget.onEdit?.call(item, formData);
        if (updatedItem != null) {
          _listController.updateItem(item, updatedItem);
        }

        form.reset();
        form.dispose();
      });
    }
  }

  void handleCancelForm() {
    setState(() {
      _activeForm?.dispose();
      _activeForm = null;
      _editingItem = null;
    });
  }

  void handleSaveForm(TButtonPressOptions options) async {
    final form = _activeForm;
    if (form == null) {
      options.stopLoading();
      return;
    }

    final errors = form.validationErrors;
    if (errors.isNotEmpty) {
      for (var message in errors) {
        TToastService.error(context, message);
      }
      options.stopLoading();
      return;
    }

    try {
      final editingItem = _editingItem;
      if (editingItem != null) {
        final updatedItem = await widget.onEdit?.call(editingItem, form);
        if (updatedItem != null) {
          _listController.updateItem(editingItem, updatedItem);
        }
      } else {
        final newItem = await widget.onCreate?.call(form);
        if (newItem != null) {
          _listController.addItem(newItem);
        }
      }

      handleCancelForm();
    } catch (e) {
      debugPrint('__ TCrudTable save error: $e');
    } finally {
      options.stopLoading();
    }
  }

  void handleArchive(T item) {
    TAlertService.confirmArchive(context, () async {
      await _performAction(() async {
        final success = await widget.onArchive!(item);
        if (success) {
          _listController.removeItem(item);
          _permissionCache.remove(item);
        }
      });
    });
  }

  void handleRestore(T item) {
    TAlertService.confirmRestore(context, () async {
      await _performAction(() async {
        final success = await widget.onRestore!(item);
        if (success) {
          _archiveListController.removeItem(item);
          _permissionCache.remove(item);
        }
      });
    });
  }

  void handleDelete(T item) {
    TAlertService.confirmDelete(context, () async {
      await _performAction(() async {
        final success = await widget.onDelete!(item);
        if (success) {
          _archiveListController.removeItem(item);
          _permissionCache.remove(item);
        }
      });
    });
  }

  Future<void> performAction(Future<void> Function() action) => _performAction(action);

  Future<void> _performAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('__ TCrudTable action error: $e');
    }
  }

  void handleExportPdf() async {
    final controller = _currentTab == 0 ? _listController : _archiveListController;
    final items = controller.value.displayItems.map((e) => e.data).toList();
    if (items.isEmpty) return;

    final pdf = pw.Document();
    final colors = context.colors;
    final table = await TTableHelper.from(context, widget.headers, items);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          buildBackground: (context) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: colors.surface.toPdfColor())),
        ),
        build: (context) => [
          pw.Text('Exported Data', style: pw.TextStyle(fontSize: 16, color: colors.onSurfaceVariant.toPdfColor())),
          pw.SizedBox(height: 15),
          table
        ],
      ),
    );

    await pdf.download(fileName: "export_${DateTime.now().millisecondsSinceEpoch}");
  }

  void handleExportCsv() async {
    final controller = _currentTab == 0 ? _listController : _archiveListController;
    final items = controller.value.displayItems.map((e) => e.data).toList();
    if (items.isEmpty) return;

    final effectiveHeaders = widget.headers.where((h) => h.map != null).toList();
    final csvRows = <List<String>>[];

    // Headers
    csvRows.add(effectiveHeaders.map((h) => h.text).toList());

    // Data
    for (var item in items) {
      csvRows.add(effectiveHeaders.map((h) => h.getValue(item)).toList());
    }

    final csvString = csvRows.map((row) => row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(',')).join('\n');
    final bytes = utf8.encode(csvString);

    await FileSaver.instance.saveFile(
      name: "export_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: "csv",
      mimeType: MimeType.csv,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'crud_table_top_bar.dart';
part 'crud_table_builder.dart';

class TCrudTable<T, K, F extends TFormBase> extends StatefulWidget {
  final List<TTableHeader<T>> headers;

  final List<T>? items;
  final TLoadListener<T>? onLoad;
  final TListController<T, K>? controller;

  final List<T>? archivedItems;
  final TLoadListener<T>? onArchiveLoad;
  final TListController<T, K>? archiveController;

  final F Function()? createForm;
  final F Function(T item)? editForm;

  final Future<T?> Function(F form)? onCreate;
  final Future<T?> Function(T item, F form)? onEdit;
  final Future<void> Function(T item)? onView;
  final Future<bool> Function(T item)? onArchive;
  final Future<bool> Function(T item)? onRestore;
  final Future<bool> Function(T item)? onDelete;

  final TCrudConfig<T, K> config;
  final Widget Function(T item, int index)? expandedBuilder;

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
  })  : assert(
          (controller == null && (items != null || onLoad != null)) || (controller != null && items == null && onLoad == null),
          'Provide either `controller` OR (`items` / `onLoad`), not both.',
        ),
        assert(
          (archiveController == null && (archivedItems != null || onArchiveLoad != null)) ||
              (archiveController != null && archivedItems == null && onArchiveLoad == null),
          'Provide either `archiveController` OR (`archivedItems` / `onArchiveLoad`), not both.',
        );

  @override
  State<TCrudTable<T, K, F>> createState() => _TCrudTableState<T, K, F>();
}

class _TCrudTableState<T, K, F extends TFormBase> extends State<TCrudTable<T, K, F>> {
  late final TListController<T, K> _listController;
  late final TListController<T, K> _archiveListController;

  late final _TCrudTopBar<T, K, F> _topBar;
  late final _TCrudTableBuilder<T, K, F> _tableBuilder;

  int _currentTab = 0;
  final Map<T, Map<String, bool>> _permissionCache = {};

  @override
  void initState() {
    super.initState();

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
        );

    _topBar = _TCrudTopBar<T, K, F>(parent: this);
    _tableBuilder = _TCrudTableBuilder<T, K, F>(parent: this);
  }

  @override
  void dispose() {
    _permissionCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return _tableBuilder._buildContent(
      theme,
      theme.tableTheme.copyWith(
        headerWidget: LayoutBuilder(builder: (_, constraints) => _topBar.build(context, constraints)),
      ),
    );
  }

  // Getters for child classes
  bool get hasArchive => widget.archivedItems != null || widget.onArchiveLoad != null;
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

  void handleEdit(T item) {
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
}

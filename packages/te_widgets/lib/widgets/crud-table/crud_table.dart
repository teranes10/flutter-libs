import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCrudTable<T, F extends TFormBase> extends StatefulWidget {
  final List<TTableHeader<T>> headers;

  final List<T>? items;
  final TLoadListener<T>? onLoad;
  final List<T>? archivedItems;
  final TLoadListener<T>? onArchiveLoad;

  final F Function()? createForm;
  final F Function(T item)? editForm;

  final Future<T?> Function(F form)? onCreate;
  final Future<T?> Function(T item, F form)? onEdit;
  final Future<void> Function(T item)? onView;
  final Future<bool> Function(T item)? onArchive;
  final Future<bool> Function(T item)? onRestore;
  final Future<bool> Function(T item)? onDelete;

  final TCrudConfig<T> config;
  final TPaginationController<T>? controller;
  final TTableController<T>? tableController;
  final TTableDecoration decoration;
  final TTableInteractionConfig interactionConfig;

  // Expandable configuration
  final bool expandable;
  final bool singleExpand;
  final Widget Function(T item, int index, bool isExpanded)? expandedBuilder;

  // Selectable configuration
  final bool selectable;
  final bool singleSelect;

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
    this.tableController,
    this.decoration = const TTableDecoration(),
    this.interactionConfig = const TTableInteractionConfig(),
    this.expandable = false,
    this.singleExpand = true,
    this.expandedBuilder,
    this.selectable = false,
    this.singleSelect = false,
  });

  @override
  State<TCrudTable<T, F>> createState() => _TCrudTableState<T, F>();
}

class _TCrudTableState<T, F extends TFormBase> extends State<TCrudTable<T, F>> {
  late final ValueNotifier<String> _searchNotifier;
  late final ValueNotifier<String> _archiveSearchNotifier;
  late final TPaginationController<T> _paginationController;
  late final TPaginationController<T> _archivePaginationController;

  int _currentTab = 0;
  final Map<T, Map<String, bool>> _permissionCache = {};

  bool get _hasArchive => widget.archivedItems != null || widget.onArchiveLoad != null;
  bool get _canCreate => widget.createForm != null && widget.onCreate != null;
  bool get _canEdit => widget.editForm != null && widget.onEdit != null;
  bool get _hasActiveActions => widget.onView != null || _canEdit || widget.onArchive != null || widget.config.activeActions.isNotEmpty;
  bool get _hasArchiveActions =>
      widget.onView != null || widget.onRestore != null || widget.onDelete != null || widget.config.archiveActions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchNotifier = ValueNotifier('');
    _archiveSearchNotifier = ValueNotifier('');
    _paginationController = widget.controller ?? TPaginationController<T>();
    _archivePaginationController = TPaginationController<T>();
  }

  @override
  void dispose() {
    _searchNotifier.dispose();
    _archiveSearchNotifier.dispose();
    _permissionCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;

    return Column(
      children: [
        _buildHeader(theme),
        _buildContent(exTheme),
      ],
    );
  }

  Widget _buildHeader(ColorScheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200),
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_canCreate)
                    TButton(
                      type: TButtonType.softOutline,
                      size: TButtonSize.lg,
                      icon: Icons.add,
                      text: widget.config.addButtonText,
                      onPressed: (_) => _handleCreate(),
                    ),
                  ...widget.config.topBarActions,
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_hasArchive)
                    TTabs(
                      inline: true,
                      selectedIndex: _currentTab,
                      onTabChanged: (i) => setState(() => _currentTab = i),
                      tabs: [
                        TTab(text: widget.config.activeTabText),
                        TTab(text: widget.config.archiveTabText),
                      ],
                    ),
                  SizedBox(
                    width: 250,
                    child: TTextField(
                      placeholder: widget.config.searchPlaceholder,
                      postWidget: Icon(Icons.search_rounded, size: 18, color: theme.onSurface),
                      size: TInputSize.sm,
                      valueNotifier: _currentTab == 0 ? _searchNotifier : _archiveSearchNotifier,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TColorScheme exTheme) {
    if (!_hasArchive) {
      return _buildTable(
        isArchive: false,
        headers: _buildActiveHeaders(exTheme),
        items: widget.items,
        onLoad: widget.onLoad,
        searchNotifier: _searchNotifier,
        controller: _paginationController,
      );
    }

    return IndexedStack(
      index: _currentTab,
      children: [
        _buildTable(
          isArchive: false,
          headers: _buildActiveHeaders(exTheme),
          items: widget.items,
          onLoad: widget.onLoad,
          searchNotifier: _searchNotifier,
          controller: _paginationController,
        ),
        _buildTable(
          isArchive: true,
          headers: _buildArchiveHeaders(exTheme),
          items: widget.archivedItems,
          onLoad: widget.onArchiveLoad,
          searchNotifier: _archiveSearchNotifier,
          controller: _archivePaginationController,
        ),
      ],
    );
  }

  Widget _buildTable({
    required bool isArchive,
    required List<TTableHeader<T>> headers,
    required List<T>? items,
    required TLoadListener<T>? onLoad,
    required ValueNotifier<String> searchNotifier,
    required TPaginationController<T> controller,
  }) {
    return TDataTable<T>(
      headers: headers,
      decoration: widget.decoration,
      interactionConfig: widget.interactionConfig,
      expandable: !isArchive && widget.expandable,
      selectable: !isArchive && widget.selectable,
      singleExpand: widget.singleExpand,
      singleSelect: widget.singleSelect,
      expandedBuilder: widget.expandedBuilder,
      items: items,
      onLoad: onLoad,
      searchNotifier: searchNotifier,
      controller: controller,
      tableController: widget.tableController,
      itemsPerPage: widget.config.itemsPerPage,
      itemsPerPageOptions: widget.config.itemsPerPageOptions,
    );
  }

  List<TTableHeader<T>> _buildActiveHeaders(TColorScheme exTheme) {
    final headers = [...widget.headers];

    if (widget.config.showActions && _hasActiveActions) {
      headers.add(TTableHeader<T>(
        'Actions',
        maxWidth: (27.0 * (3 + widget.config.activeActions.length)),
        alignment: Alignment.center,
        builder: (context, item) => _buildActiveActionButtons(exTheme, item),
      ));
    }

    return headers;
  }

  List<TTableHeader<T>> _buildArchiveHeaders(TColorScheme exTheme) {
    final headers = [...widget.headers];

    if (widget.config.showActions && _hasArchiveActions) {
      headers.add(TTableHeader<T>(
        'Actions',
        maxWidth: (27.0 * (3 + widget.config.activeActions.length)),
        alignment: Alignment.center,
        builder: (context, item) => _buildArchiveActionButtons(exTheme, item),
      ));
    }

    return headers;
  }

  Widget _buildActiveActionButtons(TColorScheme exTheme, T item) {
    final buttons = <TButtonGroupItem>[];

    if (widget.onView != null && _canPerformActionSync(item, widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: exTheme.success,
        onPressed: (_) => widget.onView!(item),
      ));
    }

    if (_canEdit && _canPerformActionSync(item, widget.config.canEdit)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Edit',
        icon: Icons.edit,
        color: exTheme.info,
        onPressed: (_) => _handleEdit(item),
      ));
    }

    if (widget.onArchive != null && _canPerformActionSync(item, widget.config.canArchive)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Archive',
        icon: Icons.archive,
        color: exTheme.danger,
        onPressed: (_) => _handleArchive(item),
      ));
    }

    for (final action in widget.config.activeActions) {
      if (_canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          icon: action.icon,
          color: action.color,
          onPressed: (_) => _performAction(() => action.onPressed(item)),
        ));
      }
    }

    return buttons.isEmpty
        ? const SizedBox.shrink()
        : TButtonGroup(
            type: TButtonGroupType.text,
            items: buttons,
          );
  }

  Widget _buildArchiveActionButtons(TColorScheme exTheme, T item) {
    final buttons = <TButtonGroupItem>[];

    // View action
    if (widget.onView != null && _canPerformActionSync(item, widget.config.canView)) {
      buttons
          .add(TButtonGroupItem(tooltip: 'View', icon: Icons.visibility, color: exTheme.success, onPressed: (_) => widget.onView!(item)));
    }

    // Restore action
    if (widget.onRestore != null && _canPerformActionSync(item, widget.config.canRestore)) {
      buttons.add(TButtonGroupItem(tooltip: 'Restore', icon: Icons.restore, color: exTheme.info, onPressed: (_) => _handleRestore(item)));
    }

    // Delete permanently action
    if (widget.onDelete != null && _canPerformActionSync(item, widget.config.canDelete)) {
      buttons.add(
          TButtonGroupItem(tooltip: 'Delete', icon: Icons.delete_forever, color: exTheme.danger, onPressed: (_) => _handleDelete(item)));
    }

    // Custom actions for archive table
    for (final action in widget.config.archiveActions) {
      if (_canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
            tooltip: action.tooltip,
            icon: action.icon,
            color: action.color,
            onPressed: (_) => _performAction(() => action.onPressed(item))));
      }
    }

    return buttons.isEmpty
        ? const SizedBox.shrink()
        : TButtonGroup(
            type: TButtonGroupType.text,
            items: buttons,
          );
  }

  // Synchronous permission check with caching
  bool _canPerformActionSync(T item, Future<bool> Function(T)? permission) {
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

  // Update permission asynchronously and rebuild if needed
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
  void _handleCreate() {
    _performAction(() async {
      final form = widget.createForm?.call();
      if (form == null) return;

      final formData = await TFormService.show(context, form);
      if (formData == null) return;

      final newItem = await widget.onCreate?.call(formData);
      if (newItem != null) {
        _paginationController.addItem(newItem);
        form.reset();
      }
    });
  }

  void _handleEdit(T item) {
    _performAction(() async {
      final form = widget.editForm?.call(item);
      if (form == null) return;

      final formData = await TFormService.show(context, form);
      if (formData == null) return;

      final updatedItem = await widget.onEdit?.call(item, formData);
      if (updatedItem != null) {
        _paginationController.updateItem(item, updatedItem);
        form.reset();
      }
    });
  }

  void _handleArchive(T item) {
    TAlertService.confirmArchive(context, () async {
      await _performAction(() async {
        final success = await widget.onArchive!(item);
        if (success) {
          _paginationController.removeItem(item);
          // Clear cache for this item
          _permissionCache.remove(item);
        }
      });
    });
  }

  void _handleRestore(T item) {
    TAlertService.confirmRestore(context, () async {
      await _performAction(() async {
        final success = await widget.onRestore!(item);
        if (success) {
          _archivePaginationController.removeItem(item);
          // Clear cache for this item
          _permissionCache.remove(item);
        }
      });
    });
  }

  void _handleDelete(T item) {
    TAlertService.confirmDelete(context, () async {
      // Fixed: using confirmDelete instead of confirmRestore
      await _performAction(() async {
        final success = await widget.onDelete!(item);
        if (success) {
          _archivePaginationController.removeItem(item);
          // Clear cache for this item
          _permissionCache.remove(item);
        }
      });
    });
  }

  Future<void> _performAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (kDebugMode) {
        print('__ TCrudTable action error: $e');
      }
    }
  }
}

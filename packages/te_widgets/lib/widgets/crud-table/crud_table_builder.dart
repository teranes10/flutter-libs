part of 'crud_table.dart';

class _TCrudTableBuilder<T, F extends TFormBase> {
  final _TCrudTableState<T, F> parent;

  _TCrudTableBuilder({required this.parent});

  Widget _buildContent(TColorScheme exTheme) {
    if (!parent.hasArchive) {
      return _buildTable(
        isArchive: false,
        headers: _buildActiveHeaders(exTheme),
        items: parent.widget.items,
        onLoad: parent.widget.onLoad,
        searchNotifier: parent.searchNotifier,
        controller: parent.paginationController,
      );
    }

    return IndexedStack(
      index: parent.currentTab,
      children: [
        _buildTable(
          isArchive: false,
          headers: _buildActiveHeaders(exTheme),
          items: parent.widget.items,
          onLoad: parent.widget.onLoad,
          searchNotifier: parent.searchNotifier,
          controller: parent.paginationController,
        ),
        _buildTable(
          isArchive: true,
          headers: _buildArchiveHeaders(exTheme),
          items: parent.widget.archivedItems,
          onLoad: parent.widget.onArchiveLoad,
          searchNotifier: parent.archiveSearchNotifier,
          controller: parent.archivePaginationController,
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
      decoration: parent.widget.decoration,
      interactionConfig: parent.widget.interactionConfig,
      expandable: !isArchive && parent.widget.expandable,
      selectable: !isArchive && parent.widget.selectable,
      singleExpand: parent.widget.singleExpand,
      singleSelect: parent.widget.singleSelect,
      expandedBuilder: parent.widget.expandedBuilder,
      items: items,
      onLoad: onLoad,
      searchNotifier: searchNotifier,
      controller: controller,
      tableController: parent.widget.tableController,
      itemsPerPage: parent.widget.config.itemsPerPage,
      itemsPerPageOptions: parent.widget.config.itemsPerPageOptions,
    );
  }

  List<TTableHeader<T>> _buildActiveHeaders(TColorScheme exTheme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasActiveActions) {
      headers.add(TTableHeader<T>(
        'Actions',
        maxWidth: (27.0 * (3 + parent.widget.config.activeActions.length)),
        alignment: Alignment.center,
        builder: (context, item) => _buildActiveActionButtons(exTheme, item),
      ));
    }

    return headers;
  }

  List<TTableHeader<T>> _buildArchiveHeaders(TColorScheme exTheme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasArchiveActions) {
      headers.add(TTableHeader<T>(
        'Actions',
        maxWidth: (27.0 * (3 + parent.widget.config.activeActions.length)),
        alignment: Alignment.center,
        builder: (context, item) => _buildArchiveActionButtons(exTheme, item),
      ));
    }

    return headers;
  }

  Widget _buildActiveActionButtons(TColorScheme exTheme, T item) {
    final buttons = <TButtonGroupItem>[];

    if (parent.widget.onView != null && parent.canPerformActionSync(item, parent.widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: exTheme.success,
        onPressed: (_) => parent.widget.onView!(item),
      ));
    }

    if (parent.canEdit && parent.canPerformActionSync(item, parent.widget.config.canEdit)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Edit',
        icon: Icons.edit,
        color: exTheme.info,
        onPressed: (_) => parent.handleEdit(item),
      ));
    }

    if (parent.widget.onArchive != null && parent.canPerformActionSync(item, parent.widget.config.canArchive)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Archive',
        icon: Icons.archive,
        color: exTheme.danger,
        onPressed: (_) => parent.handleArchive(item),
      ));
    }

    for (final action in parent.widget.config.activeActions) {
      if (parent.canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          icon: action.icon,
          color: action.color,
          onPressed: (_) => parent.performAction(() => action.onPressed(item)),
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
    if (parent.widget.onView != null && parent.canPerformActionSync(item, parent.widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: exTheme.success,
        onPressed: (_) => parent.widget.onView!(item),
      ));
    }

    // Restore action
    if (parent.widget.onRestore != null && parent.canPerformActionSync(item, parent.widget.config.canRestore)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Restore',
        icon: Icons.restore,
        color: exTheme.info,
        onPressed: (_) => parent.handleRestore(item),
      ));
    }

    // Delete permanently action
    if (parent.widget.onDelete != null && parent.canPerformActionSync(item, parent.widget.config.canDelete)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Delete',
        icon: Icons.delete_forever,
        color: exTheme.danger,
        onPressed: (_) => parent.handleDelete(item),
      ));
    }

    // Custom actions for archive table
    for (final action in parent.widget.config.archiveActions) {
      if (parent.canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          icon: action.icon,
          color: action.color,
          onPressed: (_) => parent.performAction(() => action.onPressed(item)),
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
}

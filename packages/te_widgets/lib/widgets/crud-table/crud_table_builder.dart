part of 'crud_table.dart';

class TCrudTableContent<T, K> {
  final List<TTableHeader<T, K>> headers;
  final TListController<T, K> controller;

  TCrudTableContent({required this.headers, required this.controller});
}

class _TCrudTableBuilder<T, K, F extends TFormBase> {
  final _TCrudTableState<T, K, F> parent;

  _TCrudTableBuilder({required this.parent});

  Widget _buildContent(TWidgetThemeExtension theme, TTableTheme tableTheme) {
    Widget buildTable({
      required List<TTableHeader<T, K>> headers,
      required TListController<T, K> controller,
    }) {
      return TDataTable<T, K>(
        theme: tableTheme,
        headers: headers,
        expandedBuilder: parent.widget.expandedBuilder,
        controller: controller,
        itemsPerPageOptions: parent.widget.config.itemsPerPageOptions,
      );
    }

    return TLazyIndexedStack(
      index: parent.currentTab,
      children: [
        (_) => buildTable(headers: _buildActiveHeaders(theme), controller: parent.listController),
        (_) => buildTable(headers: _buildArchiveHeaders(theme), controller: parent.archiveListController),
        ...parent.widget.config.tabContents.map((x) => (_) => buildTable(headers: x.headers, controller: x.controller))
      ],
    );
  }

  List<TTableHeader<T, K>> _buildActiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasActiveActions) {
      headers.add(TTableHeader<T, K>.actions(
        (item) => _buildActiveActionButtons(theme, item.data),
        maxWidth: parent.widget.config.actionButtonWidth * _activeActionsCount(),
      ));
    }

    return headers;
  }

  List<TTableHeader<T, K>> _buildArchiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasArchiveActions) {
      headers.add(TTableHeader<T, K>.actions(
        (item) => _buildArchiveActionButtons(theme, item.data),
        minWidth: parent.widget.config.actionButtonWidth * _archiveActionsCount(),
      ));
    }

    return headers;
  }

  int _activeActionsCount() {
    int count = 0;

    if (parent.widget.onView != null) {
      count++;
    }
    if (parent.canEdit) {
      count++;
    }
    if (parent.widget.onArchive != null) {
      count++;
    }

    count += parent.widget.config.activeActions.length;

    return count;
  }

  List<TButtonGroupItem> _buildActiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    if (parent.widget.onView != null && parent.canPerformActionSync(item, parent.widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: theme.success,
        onPressed: (_) => parent.widget.onView!(item),
      ));
    }

    if (parent.canEdit && parent.canPerformActionSync(item, parent.widget.config.canEdit)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Edit',
        icon: Icons.edit,
        color: theme.info,
        onPressed: (_) => parent.handleEdit(item),
      ));
    }

    if (parent.widget.onArchive != null && parent.canPerformActionSync(item, parent.widget.config.canArchive)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Archive',
        icon: Icons.archive,
        color: theme.danger,
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

    return buttons;
  }

  int _archiveActionsCount() {
    int count = 0;

    if (parent.widget.onView != null) {
      count++;
    }
    if (parent.widget.onRestore != null) {
      count++;
    }
    if (parent.widget.onDelete != null) {
      count++;
    }

    count += parent.widget.config.archiveActions.length;

    return count;
  }

  List<TButtonGroupItem> _buildArchiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    // View action
    if (parent.widget.onView != null && parent.canPerformActionSync(item, parent.widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: theme.success,
        onPressed: (_) => parent.widget.onView!(item),
      ));
    }

    // Restore action
    if (parent.widget.onRestore != null && parent.canPerformActionSync(item, parent.widget.config.canRestore)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Restore',
        icon: Icons.restore,
        color: theme.info,
        onPressed: (_) => parent.handleRestore(item),
      ));
    }

    // Delete permanently action
    if (parent.widget.onDelete != null && parent.canPerformActionSync(item, parent.widget.config.canDelete)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Delete',
        icon: Icons.delete_forever,
        color: theme.danger,
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

    return buttons;
  }
}

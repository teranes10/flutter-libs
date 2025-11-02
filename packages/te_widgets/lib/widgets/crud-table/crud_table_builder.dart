part of 'crud_table.dart';

class _TCrudTableBuilder<T, K, F extends TFormBase> {
  final _TCrudTableState<T, K, F> parent;

  _TCrudTableBuilder({required this.parent});

  Widget _buildContent(TWidgetThemeExtension theme) {
    if (!parent.hasArchive) {
      return _buildTable(
        isArchive: false,
        headers: _buildActiveHeaders(theme),
        controller: parent.listController,
      );
    }

    return TLazyIndexedStack(
      index: parent.currentTab,
      children: [
        (_) => _buildTable(isArchive: false, headers: _buildActiveHeaders(theme), controller: parent.listController),
        (_) => _buildTable(isArchive: true, headers: _buildArchiveHeaders(theme), controller: parent.archiveListController),
      ],
    );
  }

  Widget _buildTable({
    required bool isArchive,
    required List<TTableHeader<T>> headers,
    required TListController<T, K> controller,
  }) {
    return TDataTable<T, K>(
      headers: headers,
      expandedBuilder: parent.widget.expandedBuilder,
      controller: controller,
      interaction: parent.widget.config.interaction ??
          TListInteraction<T>(
            tapAction: TListInteractionType.expand,
            doubleTapAction: TListInteractionType.select,
          ),
      itemsPerPageOptions: parent.widget.config.itemsPerPageOptions,
    );
  }

  List<TTableHeader<T>> _buildActiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasActiveActions) {
      headers.add(TTableHeader<T>(
        'Actions',
        maxWidth: (27.0 * (3 + parent.widget.config.activeActions.length)),
        alignment: Alignment.center,
        builder: (context, item) => _buildActiveActionButtons(theme, item),
      ));
    }

    return headers;
  }

  List<TTableHeader<T>> _buildArchiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasArchiveActions) {
      headers.add(TTableHeader<T>(
        'Actions',
        maxWidth: (27.0 * (3 + parent.widget.config.activeActions.length)),
        alignment: Alignment.center,
        builder: (context, item) => _buildArchiveActionButtons(theme, item),
      ));
    }

    return headers;
  }

  Widget _buildActiveActionButtons(TWidgetThemeExtension theme, T item) {
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

    return buttons.isEmpty
        ? const SizedBox.shrink()
        : TButtonGroup(
            type: TButtonGroupType.icon,
            items: buttons,
          );
  }

  Widget _buildArchiveActionButtons(TWidgetThemeExtension theme, T item) {
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

    return buttons.isEmpty
        ? const SizedBox.shrink()
        : TButtonGroup(
            type: TButtonGroupType.icon,
            items: buttons,
          );
  }
}

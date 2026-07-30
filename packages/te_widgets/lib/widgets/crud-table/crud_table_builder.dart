part of 'crud_table.dart';

/// Defines the content for a specific tab in [TCrudTable].
class TCrudTableContent<T, K> {
  /// The headers specific to this tab's table.
  final List<TTableHeader<T, K>> headers;

  /// The list controller managing data for this tab.
  final TListController<T, K> controller;

  /// Creates a content definition for a CRUD table tab.
  TCrudTableContent({required this.headers, required this.controller});
}

extension _TCrudTableBuilderExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  Widget _buildContent(TWidgetThemeExtension theme, TTableTheme tableTheme) {
    Widget buildTable({
      required List<TTableHeader<T, K>> headers,
      required TListController<T, K> controller,
    }) {
      return ValueListenableBuilder<TListState<T, K>>(
        valueListenable: controller,
        builder: (context, state, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              TTableTheme effectiveTheme = tableTheme;
              if (viewMode == 1) {
                effectiveTheme = tableTheme.copyWith(forceCardStyle: true, grid: null);
              } else if (viewMode == 2) {
                effectiveTheme = tableTheme.copyWith(
                  forceCardStyle: false,
                  grid: TGridMode.masonry,
                  gridDelegate: (context) => context.isMobile ? TGridDelegate(crossAxisCount: 1) : TGridDelegate(maxCrossAxisExtent: 350),
                );
              } else {
                effectiveTheme = tableTheme.copyWith(forceCardStyle: false, grid: null);
              }

              return TDataTable<T, K>(
                key: const ValueKey('table_layout'),
                theme: effectiveTheme.copyWith(dense: dense),
                headers: headers,
                controller: controller,
                itemsPerPageOptions: widget.config.itemsPerPageOptions,
                rowBuilder: widget.rowBuilder,
                rowColorBuilder: widget.rowColorBuilder,
                details: widget.expandedDetails ??
                    TTableDetails<T, K>(
                      mode: effectiveExpansionMode,
                      createMode: effectiveCreateMode,
                      createDialogWidth: widget.createDialogWidth,
                      builder: widget.expandedBuilder,
                      createBuilder: _buildInlineCreateBuilder(),
                      itemTitle: widget.itemTitle,
                      itemSubTitle: widget.itemSubTitle,
                      itemDescription: widget.itemDescription,
                      itemImageUrl: widget.itemImageUrl,
                      itemInfo: widget.itemInfo,
                      itemInfoGridInline: widget.itemInfoGridInline,
                      actions: (item) {
                        final buttonItems = controller == listController
                            ? _buildActiveActionButtons(theme, item)
                            : (controller == archiveListController ? _buildArchiveActionButtons(theme, item) : <TButtonGroupItem>[]);

                        return buttonItems
                            .map((b) => IconButton(
                                  icon: Icon(b.icon),
                                  color: b.color,
                                  tooltip: b.tooltip,
                                  onPressed: b.onPressed != null ? () => b.onPressed!(TButtonPressOptions(stopLoading: () {})) : null,
                                ))
                            .toList();
                      },
                    ),
              );
            },
          );
        },
      );
    }

    return TLazyIndexedStack(
      index: currentTab,
      children: [
        (_) => buildTable(headers: _buildActiveHeaders(theme), controller: listController),
        (_) => buildTable(headers: _buildArchiveHeaders(theme), controller: archiveListController),
        ...widget.config.tabContents.map((x) => (_) => buildTable(headers: x.headers, controller: x.controller))
      ],
    );
  }

  List<TTableHeader<T, K>> _buildActiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...widget.headers];

    if (widget.config.showActions && hasActiveActions) {
      if (widget.config.flatActions) {
        headers.add(TTableHeader<T, K>.actions(
          (item) => _buildActiveActionButtons(theme, item.data),
          maxWidth: widget.config.actionButtonWidth * _activeActionsCount(),
        ));
      } else {
        headers.add(TTableHeader<T, K>.actions(
          (item) => [
            TButtonGroupItem(
              child: _buildActionMenu(context, theme, _buildActiveActionButtons(theme, item.data)),
            ),
          ],
          maxWidth: 75.0,
        ));
      }
    }

    return headers;
  }

  List<TTableHeader<T, K>> _buildArchiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...widget.headers];

    if (widget.config.showActions && hasArchiveActions) {
      if (widget.config.flatActions) {
        headers.add(TTableHeader<T, K>.actions(
          (item) => _buildArchiveActionButtons(theme, item.data),
          minWidth: widget.config.actionButtonWidth * _archiveActionsCount(),
        ));
      } else {
        headers.add(TTableHeader<T, K>.actions(
          (item) => [
            TButtonGroupItem(
              child: _buildActionMenu(context, theme, _buildArchiveActionButtons(theme, item.data)),
            ),
          ],
          maxWidth: 75.0,
        ));
      }
    }

    return headers;
  }

  Widget _buildActionMenu(BuildContext context, TWidgetThemeExtension theme, List<TButtonGroupItem> buttons) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    final dropdownItems = buttons.map((button) {
      return TDropdownItem(
        icon: button.icon,
        text: button.tooltip ?? button.text,
        color: button.color,
        onTap: () {
          if (button.onPressed != null) {
            button.onPressed!(TButtonPressOptions(stopLoading: () {}));
          } else if (button.onTap != null) {
            button.onTap!();
          }
        },
      );
    }).toList();

    return TDropdown(
      items: dropdownItems,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.more_vert,
            size: 20,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  int _activeActionsCount() {
    int count = 0;

    if (widget.onView != null) {
      count++;
    }
    if (canEdit) {
      count++;
    }
    if (widget.onArchive != null) {
      count++;
    }

    count += widget.config.activeActions.length;

    return count;
  }

  List<TButtonGroupItem> _buildActiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    if (widget.onView != null && canPerformActionSync(item, widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: theme.success,
        onPressed: (_) => handleView(item),
      ));
    }

    if (canEdit && canPerformActionSync(item, widget.config.canEdit)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Edit',
        icon: Icons.edit,
        color: theme.info,
        onPressed: (_) => handleEdit(item),
      ));
    }

    if (widget.onArchive != null && canPerformActionSync(item, widget.config.canArchive)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Archive',
        icon: Icons.archive,
        color: theme.danger,
        onPressed: (_) => handleArchive(item),
      ));
    }

    for (final action in widget.config.activeActions) {
      if (canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          icon: action.icon,
          color: action.color,
          onPressed: (_) => performAction(() => action.onPressed(item)),
        ));
      }
    }

    return buttons;
  }

  int _archiveActionsCount() {
    int count = 0;

    if (widget.onView != null) {
      count++;
    }
    if (widget.onRestore != null) {
      count++;
    }
    if (widget.onDelete != null) {
      count++;
    }

    count += widget.config.archiveActions.length;

    return count;
  }

  List<TButtonGroupItem> _buildArchiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    // View action
    if (widget.onView != null && canPerformActionSync(item, widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: theme.success,
        onPressed: (_) => handleView(item),
      ));
    }

    // Restore action
    if (widget.onRestore != null && canPerformActionSync(item, widget.config.canRestore)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Restore',
        icon: Icons.restore,
        color: theme.info,
        onPressed: (_) => handleRestore(item),
      ));
    }

    // Delete permanently action
    if (widget.onDelete != null && canPerformActionSync(item, widget.config.canDelete)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Delete',
        icon: Icons.delete_forever,
        color: theme.danger,
        onPressed: (_) => handleDelete(item),
      ));
    }

    // Custom actions for archive table
    for (final action in widget.config.archiveActions) {
      if (canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          icon: action.icon,
          color: action.color,
          onPressed: (_) => performAction(() => action.onPressed(item)),
        ));
      }
    }

    return buttons;
  }
}

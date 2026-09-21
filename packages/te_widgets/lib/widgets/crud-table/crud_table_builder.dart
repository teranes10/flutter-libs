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
      return LayoutBuilder(
        builder: (context, constraints) {
          TTableTheme effectiveTheme = tableTheme.copyWith(
            mobileCardTheme: tableTheme.mobileCardTheme.copyWith(
              mode: cardKeyValueMode,
            ),
          );
          if (viewMode == 1) {
            effectiveTheme = effectiveTheme.copyWith(forceCardStyle: true, grid: null);
          } else if (viewMode == 2) {
            effectiveTheme = effectiveTheme.copyWith(
              forceCardStyle: false,
              grid: TGridMode.masonry,
              gridDelegate: (context) => context.isMobile ? TGridDelegate(crossAxisCount: 1) : TGridDelegate(maxCrossAxisExtent: 350),
            );
          } else {
            effectiveTheme = effectiveTheme.copyWith(forceCardStyle: false, grid: null);
          }

          return TDataTable<T, K>(
            key: const ValueKey('table_layout'),
            theme: effectiveTheme.copyWith(dense: dense),
            optionalPaginationBar: widget.config.optionalPaginationBar,
            headers: headers,
            controller: controller,
            itemsPerPageOptions: widget.config.itemsPerPageOptions,
            rowBuilder: widget.rowBuilder,
            rowColorBuilder: widget.rowColorBuilder,
            details: (widget.expandedDetails != null)
                ? widget.expandedDetails!.copyWith(
                    mode: effectiveExpansionMode,
                    createMode: effectiveCreateMode,
                    dialogWidth: effectiveDialogWidth,
                    createDialogWidth: effectiveCreateDialogWidth,
                    sideOverlayWidth: effectiveSideOverlayWidth,
                    createSideOverlayWidth: effectiveCreateSideOverlayWidth,
                    sideOverlayMinWidth: effectiveSideOverlayMinWidth,
                    sideOverlayMaxWidth: effectiveSideOverlayMaxWidth,
                    sideOverlayWidthRatio: effectiveSideOverlayWidthRatio,
                    createSideOverlayMinWidth: effectiveCreateSideOverlayMinWidth,
                    createSideOverlayMaxWidth: effectiveCreateSideOverlayMaxWidth,
                    createSideOverlayWidthRatio: effectiveCreateSideOverlayWidthRatio,
                  )
                : TTableDetails<T, K>(
                    mode: effectiveExpansionMode,
                    createMode: effectiveCreateMode,
                    dialogWidth: effectiveDialogWidth,
                    createDialogWidth: effectiveCreateDialogWidth,
                    sideOverlayWidth: effectiveSideOverlayWidth,
                    createSideOverlayWidth: effectiveCreateSideOverlayWidth,
                    sideOverlayMinWidth: effectiveSideOverlayMinWidth,
                    sideOverlayMaxWidth: effectiveSideOverlayMaxWidth,
                    sideOverlayWidthRatio: effectiveSideOverlayWidthRatio,
                    createSideOverlayMinWidth: effectiveCreateSideOverlayMinWidth,
                    createSideOverlayMaxWidth: effectiveCreateSideOverlayMaxWidth,
                    createSideOverlayWidthRatio: effectiveCreateSideOverlayWidthRatio,
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
    final headers = List<TTableHeader<T, K>>.from(widget.headers);

    if (widget.config.showActions && hasActiveActions) {
      if (widget.config.flatActions) {
        headers.add(TTableHeader<T, K>.actions(
          (item) => _buildActiveActionButtons(theme, item.data),
          count: _activeActionsCount(),
          maxWidth: widget.config.actionButtonWidth * _activeActionsCount(),
        ));
      } else {
        final visibleCount = _effectiveActiveVisibleCount();
        headers.add(TTableHeader<T, K>.actions(
          (item) {
            final buttons = _buildActiveActionButtons(theme, item.data);
            final flatButtons = buttons.where((b) => b.showFlat).toList();
            final menuButtons = buttons.where((b) => !b.showFlat).toList();

            final result = <TButtonGroupItem>[...flatButtons];
            if (menuButtons.isNotEmpty) {
              result.add(TButtonGroupItem(
                child: _buildActionMenu(context, theme, menuButtons),
              ));
            }
            return result;
          },
          count: visibleCount,
          maxWidth: (widget.config.actionButtonWidth * visibleCount).clamp(75.0, 300.0),
        ));
      }
    }

    return headers;
  }

  List<TTableHeader<T, K>> _buildArchiveHeaders(TWidgetThemeExtension theme) {
    final headers = List<TTableHeader<T, K>>.from(widget.headers);

    if (widget.config.showActions && hasArchiveActions) {
      if (widget.config.flatActions) {
        headers.add(TTableHeader<T, K>.actions(
          (item) => _buildArchiveActionButtons(theme, item.data),
          count: _archiveActionsCount(),
          maxWidth: widget.config.actionButtonWidth * _archiveActionsCount(),
        ));
      } else {
        final visibleCount = _effectiveArchiveVisibleCount();
        headers.add(TTableHeader<T, K>.actions(
          (item) {
            final buttons = _buildArchiveActionButtons(theme, item.data);
            final flatButtons = buttons.where((b) => b.showFlat).toList();
            final menuButtons = buttons.where((b) => !b.showFlat).toList();

            final result = <TButtonGroupItem>[...flatButtons];
            if (menuButtons.isNotEmpty) {
              result.add(TButtonGroupItem(
                child: _buildActionMenu(context, theme, menuButtons),
              ));
            }
            return result;
          },
          count: visibleCount,
          maxWidth: (widget.config.actionButtonWidth * visibleCount).clamp(75.0, 300.0),
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

  int _effectiveActiveVisibleCount() {
    int flat = 0;
    int menu = 0;

    if (widget.onView != null) {
      widget.config.canViewFlat ? flat++ : menu++;
    }
    if (canEdit) {
      widget.config.canEditFlat ? flat++ : menu++;
    }
    if (widget.onArchive != null) {
      widget.config.canArchiveFlat ? flat++ : menu++;
    }

    for (final action in widget.config.activeActions) {
      action.showFlat ? flat++ : menu++;
    }

    return flat + (menu > 0 ? 1 : 0);
  }

  List<TButtonGroupItem> _buildActiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    if (widget.onView != null && canPerformActionSync(item, widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: theme.success,
        showFlat: widget.config.canViewFlat,
        onPressed: (_) => handleView(item),
      ));
    }

    if (canEdit && canPerformActionSync(item, widget.config.canEdit)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Edit',
        icon: Icons.edit,
        color: theme.info,
        showFlat: widget.config.canEditFlat,
        onPressed: (_) => handleEdit(item),
      ));
    }

    if (widget.onArchive != null && canPerformActionSync(item, widget.config.canArchive)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Archive',
        icon: Icons.archive,
        color: theme.danger,
        showFlat: widget.config.canArchiveFlat,
        onPressed: (_) => handleArchive(item),
      ));
    }

    for (final action in widget.config.activeActions) {
      if (canPerformActionSync(item, action.canPerform)) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          icon: action.icon,
          color: action.color,
          showFlat: action.showFlat,
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

  int _effectiveArchiveVisibleCount() {
    int flat = 0;
    int menu = 0;

    if (widget.onView != null) {
      widget.config.canViewFlat ? flat++ : menu++;
    }
    if (widget.onRestore != null) {
      widget.config.canRestoreFlat ? flat++ : menu++;
    }
    if (widget.onDelete != null) {
      widget.config.canDeleteFlat ? flat++ : menu++;
    }

    for (final action in widget.config.archiveActions) {
      action.showFlat ? flat++ : menu++;
    }

    return flat + (menu > 0 ? 1 : 0);
  }

  List<TButtonGroupItem> _buildArchiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    // View action
    if (widget.onView != null && canPerformActionSync(item, widget.config.canView)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        icon: Icons.visibility,
        color: theme.success,
        showFlat: widget.config.canViewFlat,
        onPressed: (_) => handleView(item),
      ));
    }

    // Restore action
    if (widget.onRestore != null && canPerformActionSync(item, widget.config.canRestore)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Restore',
        icon: Icons.restore,
        color: theme.info,
        showFlat: widget.config.canRestoreFlat,
        onPressed: (_) => handleRestore(item),
      ));
    }

    // Delete permanently action
    if (widget.onDelete != null && canPerformActionSync(item, widget.config.canDelete)) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Delete',
        icon: Icons.delete_forever,
        color: theme.danger,
        showFlat: widget.config.canDeleteFlat,
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
          showFlat: action.showFlat,
          onPressed: (_) => performAction(() => action.onPressed(item)),
        ));
      }
    }

    return buttons;
  }
}

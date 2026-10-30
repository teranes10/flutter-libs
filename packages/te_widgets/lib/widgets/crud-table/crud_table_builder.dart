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
            mobileCardBuilder: widget.mobileCardBuilder ?? _defaultMobileCard,
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
                    showExpandIcon: false,
                    expandOnRowTap: false,
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
                    showExpandIcon: false,
                    expandOnRowTap: false,
                    builder: widget.expandedBuilder ?? (ctx, item, index) => _defaultDetails(ctx, headers, item, index),
                    createBuilder: _buildInlineCreateBuilder(),
                    itemTitle: widget.itemTitle,
                    itemSubTitle: widget.itemSubTitle,
                    itemDescription: widget.itemDescription,
                    itemImageUrl: widget.itemImageUrl,
                    itemInfo: widget.itemInfo,
                    itemHighlights: widget.itemHighlights,
                    itemInfoGridInline: widget.itemInfoGridInline,
                    actions: (item) {
                      final buttonItems = controller == listController
                          ? _buildActiveActionButtons(theme, item)
                          : (controller == archiveListController ? _buildArchiveActionButtons(theme, item) : <TButtonGroupItem>[]);
                      final isMobile = context.isMobile;
                      // The details panel is already the view, so its header omits the View action.
                      return buttonItems
                          .where((b) => b.tooltip != 'View')
                          .map((b) => Semantics(
                              identifier: b.semanticIdentifier,
                              child: IconButton(
                                icon: TIcon.raw(b.icon),
                                iconSize: 24,
                                padding: EdgeInsets.all(isMobile ? 4 : 8),
                                visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                                color: b.color,
                                tooltip: b.tooltip,
                                onPressed: b.onPressed != null ? () => b.onPressed!(TButtonPressOptions(stopLoading: () {})) : null,
                              )))
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

  Widget _defaultMobileCard(BuildContext ctx, TListItem<T, K> item, int index, VoidCallback? onTap) {
    final children = widget.itemChildren?.call(item.data);
    final hasChildren = children != null && children.isNotEmpty;

    return TTile(
      title: widget.itemTitle?.call(item.data),
      subtitle: widget.itemSubTitle?.call(item.data),
      imageUrl: widget.itemImageUrl?.call(item.data),
      iconSize: 56,
      spacing: 12,
      trailing: hasChildren ? TChip(text: '${children.length}', size: TChipSize.sm, type: TVariant.tonal) : null,
    ).card(
      padding: const EdgeInsetsGeometry.all(8),
      onTap: hasChildren ? () => _openChildrenPage(ctx, item, children) : onTap,
    );
  }

  /// Hierarchical items drill down on cards: each level is its own page that
  /// lists the children of the tapped item with the same table configuration.
  void _openChildrenPage(BuildContext ctx, TListItem<T, K> item, List<T> children) {
    final hasTabs = widget.config.tabs != null || widget.config.tabContents.isNotEmpty;
    Navigator.of(ctx).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(widget.itemTitle?.call(item.data) ?? '')),
          body: TCrudTable<T, K, F>(
            headers: widget.headers,
            items: children,
            itemKey: _listController.itemKey,
            itemChildren: widget.itemChildren,
            createForm: widget.createForm,
            editForm: widget.editForm,
            onCreate: widget.onCreate,
            onView: widget.onView,
            onEdit: widget.onEdit,
            onArchive: widget.onArchive,
            onRestore: widget.onRestore,
            onDelete: widget.onDelete,
            config: hasTabs ? const TCrudConfig() : widget.config,
            expandedBuilder: widget.expandedBuilder,
            expandedDetails: widget.expandedDetails,
            expansionMode: widget.expansionMode,
            createMode: widget.createMode,
            itemTitle: widget.itemTitle,
            itemSubTitle: widget.itemSubTitle,
            itemDescription: widget.itemDescription,
            itemImageUrl: widget.itemImageUrl,
            itemInfo: widget.itemInfo,
            itemHighlights: widget.itemHighlights,
            itemInfoGridInline: widget.itemInfoGridInline,
            theme: widget.theme,
            rowBuilder: widget.rowBuilder,
            rowColorBuilder: widget.rowColorBuilder,
            mobileCardBuilder: widget.mobileCardBuilder,
            filters: widget.filters,
          ),
        ),
      ),
    );
  }

  Widget _defaultDetails(BuildContext ctx, List<TTableHeader<T, K>> headers, TListItem<T, K> item, int index) {
    return TKeyValueSection(
      theme: ctx.theme.tableTheme.mobileCardTheme,
      mode: cardKeyValueMode,
      values: TKeyValue.mapHeaders(ctx, headers.where((h) => h.showInDetails).toList(), item, index),
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
            if (menuButtons.length == 1) {
              result.add(menuButtons.first);
            } else if (menuButtons.isNotEmpty) {
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
            if (menuButtons.length == 1) {
              result.add(menuButtons.first);
            } else if (menuButtons.isNotEmpty) {
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
        permission: button.permission,
        onDenied: button.onDenied,
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
          child: Semantics(
            button: true,
            label: 'More actions',
            identifier: 'row-action-menu',
            excludeSemantics: true,
            child: TIcon.raw(HugeIcons.strokeRoundedMoreVertical,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  int _activeActionsCount() {
    int count = 0;

    if (canView && _crudVisible(_perms?.view)) {
      count++;
    }
    if (canEdit && _crudVisible(_perms?.edit)) {
      count++;
    }
    if (widget.onArchive != null && _crudVisible(_perms?.archive)) {
      count++;
    }

    count += widget.config.activeActions.length;

    return count;
  }

  int _effectiveActiveVisibleCount() {
    int flat = 0;
    int menu = 0;

    if (canView && _crudVisible(_perms?.view)) {
      widget.config.canViewFlat ? flat++ : menu++;
    }
    if (canEdit && _crudVisible(_perms?.edit)) {
      widget.config.canEditFlat ? flat++ : menu++;
    }
    if (widget.onArchive != null && _crudVisible(_perms?.archive)) {
      widget.config.canArchiveFlat ? flat++ : menu++;
    }

    for (final action in widget.config.activeActions) {
      action.showFlat ? flat++ : menu++;
    }

    return flat + (menu > 0 ? 1 : 0);
  }

  List<TButtonGroupItem> _buildActiveActionButtons(TWidgetThemeExtension theme, T item) {
    final buttons = <TButtonGroupItem>[];

    if (canView && _crudVisible(_perms?.view) && canPerformActionSync(item, widget.config.canView, key: 'view')) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        semanticIdentifier: 'row-action-view',
        icon: HugeIcons.strokeRoundedView,
        color: theme.success,
        showFlat: widget.config.canViewFlat,
        permission: _perms?.view,
        onDenied: _crudDenied(_perms?.view),
        onPressed: (_) => handleView(item, _listController),
      ));
    }

    if (canEdit && _crudVisible(_perms?.edit) && canPerformActionSync(item, widget.config.canEdit, key: 'edit')) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Edit',
        semanticIdentifier: 'row-action-edit',
        icon: HugeIcons.strokeRoundedEdit02,
        color: theme.info,
        showFlat: widget.config.canEditFlat,
        permission: _perms?.edit,
        onDenied: _crudDenied(_perms?.edit),
        onPressed: (_) => handleEdit(item),
      ));
    }

    if (widget.onArchive != null && _crudVisible(_perms?.archive) && canPerformActionSync(item, widget.config.canArchive, key: 'archive')) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Archive',
        semanticIdentifier: 'row-action-archive',
        icon: HugeIcons.strokeRoundedArchive,
        color: theme.danger,
        showFlat: widget.config.canArchiveFlat,
        permission: _perms?.archive,
        onDenied: _crudDenied(_perms?.archive),
        onPressed: (_) => handleArchive(item),
      ));
    }

    for (final action in widget.config.activeActions) {
      if (_crudVisible(action.permission, action.onDenied) && canPerformActionSync(item, action.canPerform, key: 'custom:${action.tooltip}')) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          semanticIdentifier: 'row-action-${action.tooltip.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
          icon: action.icon,
          color: action.color,
          showFlat: action.showFlat,
          permission: action.permission,
          onDenied: _crudDenied(action.permission, action.onDenied),
          onPressed: (_) => performAction(() => action.onPressed(item)),
        ));
      }
    }

    return buttons;
  }

  int _archiveActionsCount() {
    int count = 0;

    if (canView && _crudVisible(_perms?.view)) {
      count++;
    }
    if (widget.onRestore != null && _crudVisible(_perms?.restore)) {
      count++;
    }
    if (widget.onDelete != null && _crudVisible(_perms?.delete)) {
      count++;
    }

    count += widget.config.archiveActions.length;

    return count;
  }

  int _effectiveArchiveVisibleCount() {
    int flat = 0;
    int menu = 0;

    if (canView && _crudVisible(_perms?.view)) {
      widget.config.canViewFlat ? flat++ : menu++;
    }
    if (widget.onRestore != null && _crudVisible(_perms?.restore)) {
      widget.config.canRestoreFlat ? flat++ : menu++;
    }
    if (widget.onDelete != null && _crudVisible(_perms?.delete)) {
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
    if (canView && _crudVisible(_perms?.view) && canPerformActionSync(item, widget.config.canView, key: 'view')) {
      buttons.add(TButtonGroupItem(
        tooltip: 'View',
        semanticIdentifier: 'row-action-view',
        icon: HugeIcons.strokeRoundedView,
        color: theme.success,
        showFlat: widget.config.canViewFlat,
        permission: _perms?.view,
        onDenied: _crudDenied(_perms?.view),
        onPressed: (_) => handleView(item, _archiveListController),
      ));
    }

    // Restore action
    if (widget.onRestore != null && _crudVisible(_perms?.restore) && canPerformActionSync(item, widget.config.canRestore, key: 'restore')) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Restore',
        semanticIdentifier: 'row-action-restore',
        icon: HugeIcons.strokeRoundedRestoreBin,
        color: theme.info,
        showFlat: widget.config.canRestoreFlat,
        permission: _perms?.restore,
        onDenied: _crudDenied(_perms?.restore),
        onPressed: (_) => handleRestore(item),
      ));
    }

    // Delete permanently action
    if (widget.onDelete != null && _crudVisible(_perms?.delete) && canPerformActionSync(item, widget.config.canDelete, key: 'delete')) {
      buttons.add(TButtonGroupItem(
        tooltip: 'Delete',
        semanticIdentifier: 'row-action-delete',
        icon: HugeIcons.strokeRoundedDelete02,
        color: theme.danger,
        showFlat: widget.config.canDeleteFlat,
        permission: _perms?.delete,
        onDenied: _crudDenied(_perms?.delete),
        onPressed: (_) => handleDelete(item),
      ));
    }

    // Custom actions for archive table
    for (final action in widget.config.archiveActions) {
      if (_crudVisible(action.permission, action.onDenied) && canPerformActionSync(item, action.canPerform, key: 'custom:${action.tooltip}')) {
        buttons.add(TButtonGroupItem(
          tooltip: action.tooltip,
          semanticIdentifier: 'row-action-${action.tooltip.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
          icon: action.icon,
          color: action.color,
          showFlat: action.showFlat,
          permission: action.permission,
          onDenied: _crudDenied(action.permission, action.onDenied),
          onPressed: (_) => performAction(() => action.onPressed(item)),
        ));
      }
    }

    return buttons;
  }

  TCrudPermissions? get _perms => widget.config.permissions;

  TAuthResult _crudAuth(Object? permission, [TAuthMode? onDenied]) =>
      context.authResolve(permission, target: TAuthTarget.crudAction, onDenied: onDenied ?? _perms?.onDenied);

  /// False when the action is removed by permission (denied + hide).
  bool _crudVisible(Object? permission, [TAuthMode? onDenied]) => !_crudAuth(permission, onDenied).isHidden;

  /// The explicit denied mode to hand to a widget, or null when allowed.
  TAuthMode? _crudDenied(Object? permission, [TAuthMode? onDenied]) {
    final r = _crudAuth(permission, onDenied);
    return r.isAllowed ? null : r.mode;
  }
}

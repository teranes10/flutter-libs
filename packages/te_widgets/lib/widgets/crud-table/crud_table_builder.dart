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

class _TCrudTableBuilder<T, K, F extends TFormBase> {
  final _TCrudTableState<T, K, F> parent;

  _TCrudTableBuilder({required this.parent});

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
              final isDesktop = constraints.isDesktop;
              final expandSide = parent.widget.config.expandSide;
              final isSideExpanded = expandSide && controller.hasExpansion && isDesktop;

              if (expandSide && !isDesktop && controller.hasExpansion) {
                parent.pushDetailPageIfNeeded(context, controller);
              }

              Widget body;

              if (isSideExpanded) {
                final expandedItem = controller.expandedItems.first;
                final expandedItemIndex = controller.value.displayItems.indexWhere((x) => x.key == controller.itemKey(expandedItem));
                if (expandedItemIndex != -1) {
                  final expandedListItem = controller.value.displayItems[expandedItemIndex];
                  body = Row(
                    key: const ValueKey('side_expand_layout'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: parent.widget.config.expandSideListWidth,
                        child: _buildSideList(theme, tableTheme, controller),
                      ),
                      Expanded(
                        child: TExpansionShowModeScope(
                          showMode: TExpansionShowMode.side,
                          child: parent.widget.expandedBuilder?.call(parent.context, expandedListItem, expandedItemIndex) ??
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                } else {
                  body = const SizedBox.shrink(key: ValueKey('empty_layout'));
                }
              } else {
                TTableTheme effectiveTheme = tableTheme;
                if (parent.viewMode == 1) {
                  effectiveTheme = tableTheme.copyWith(forceCardStyle: true, grid: null);
                } else if (parent.viewMode == 2) {
                  effectiveTheme = tableTheme.copyWith(
                    forceCardStyle: false,
                    grid: TGridMode.masonry,
                    gridDelegate: (context) => context.isMobile ? TGridDelegate(crossAxisCount: 1) : TGridDelegate(maxCrossAxisExtent: 350),
                  );
                } else {
                  effectiveTheme = tableTheme.copyWith(forceCardStyle: false, grid: null);
                }

                final isInlineActive = parent.widget.formPosition == TCrudFormPosition.inline && parent._activeForm != null;
                if (isInlineActive) {
                  final originalFooterBuilder = effectiveTheme.footerBuilder;
                  effectiveTheme = effectiveTheme.copyWith(
                    footerBuilder: (ctx) {
                      Widget footer = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (originalFooterBuilder != null) originalFooterBuilder(ctx),
                        ],
                      );
                      return Opacity(
                        opacity: parent.widget.config.inlineFormOverlayOpacity,
                        child: IgnorePointer(
                          child: footer,
                        ),
                      );
                    },
                  );
                }

                body = TDataTable<T, K>(
                  key: const ValueKey('table_layout'),
                  theme: effectiveTheme.copyWith(
                    dense: parent.dense,
                  ),
                  headers: headers,
                  expandedBuilder: expandSide ? (_, __, ___) => const SizedBox.shrink() : parent.widget.expandedBuilder,
                  controller: controller,
                  itemsPerPageOptions: parent.widget.config.itemsPerPageOptions,
                  dimmedOpacity: isInlineActive ? parent.widget.config.inlineFormOverlayOpacity : null,
                  expandSide: expandSide,
                  beforeItemsBuilder:
                      (parent.widget.formPosition == TCrudFormPosition.inline && parent._activeForm != null && parent._editingItem == null)
                          ? (_) => parent._buildFormCard(parent._activeForm!, isEditing: false)
                          : null,
                  rowBuilder: (ctx, item, index, row) {
                    final editingItem = parent._editingItem;
                    final isCurrentEditing = parent.widget.formPosition == TCrudFormPosition.inline &&
                        editingItem != null &&
                        controller.itemKey(editingItem) == item.key;

                    if (isCurrentEditing) {
                      return parent._buildFormCard(parent._activeForm!, isEditing: true);
                    }

                    Widget finalRow = parent.widget.rowBuilder?.call(ctx, item, index, row) ?? row;

                    if (expandSide) {
                      finalRow = InkWell(
                        onTap: () {
                          controller.toggleExpansionByKey(item.key);
                        },
                        child: finalRow,
                      );
                    }

                    // Dim the other rows when any form is active
                    if (parent.widget.formPosition == TCrudFormPosition.inline && parent._activeForm != null) {
                      finalRow = Opacity(
                        opacity: parent.widget.config.inlineFormOverlayOpacity,
                        child: IgnorePointer(
                          child: finalRow,
                        ),
                      );
                    }

                    return finalRow;
                  },
                  rowColorBuilder: parent.widget.rowColorBuilder,
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: body,
              );
            },
          );
        },
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

  Widget _buildSideList(
    TWidgetThemeExtension theme,
    TTableTheme tableTheme,
    TListController<T, K> controller,
  ) {
    return TList<T, K>(
      controller: controller,
      itemBuilder: (ctx, item, index) {
        final title = parent.widget.config.itemTitle?.call(item.data);
        final subTitle = parent.widget.config.itemSubTitle?.call(item.data);
        final imageUrl = parent.widget.config.itemImageUrl?.call(item.data);
        final isSelected = controller.isItemKeyExpanded(item.key);

        return GestureDetector(
          onTap: () {
            controller.toggleExpansionByKey(item.key);
          },
          child: TTableRowCard<T, K>(
            index: index,
            item: item,
            theme: tableTheme.rowCardTheme.copyWith(
                margin: EdgeInsets.only(right: 14, bottom: 3),
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 3),
                borderRadius: BorderRadius.circular(8)),
            isSelected: isSelected,
            headers: [
              TTableHeader<T, K>(
                "",
                builder: (context, item, index) {
                  return TImage(
                    url: imageUrl,
                    size: 45,
                    color: context.colors.surfaceContainerLow,
                    disabled: true,
                    border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    title: title,
                    subTitle: subTitle,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<TTableHeader<T, K>> _buildActiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasActiveActions) {
      if (parent.widget.config.flatActions) {
        headers.add(TTableHeader<T, K>.actions(
          (item) => _buildActiveActionButtons(theme, item.data),
          maxWidth: parent.widget.config.actionButtonWidth * _activeActionsCount(),
        ));
      } else {
        headers.add(TTableHeader<T, K>.actions(
          (item) => [
            TButtonGroupItem(
              child: _buildActionMenu(parent.context, theme, _buildActiveActionButtons(theme, item.data)),
            ),
          ],
          maxWidth: 75.0,
        ));
      }
    }

    return headers;
  }

  List<TTableHeader<T, K>> _buildArchiveHeaders(TWidgetThemeExtension theme) {
    final headers = [...parent.widget.headers];

    if (parent.widget.config.showActions && parent.hasArchiveActions) {
      if (parent.widget.config.flatActions) {
        headers.add(TTableHeader<T, K>.actions(
          (item) => _buildArchiveActionButtons(theme, item.data),
          minWidth: parent.widget.config.actionButtonWidth * _archiveActionsCount(),
        ));
      } else {
        headers.add(TTableHeader<T, K>.actions(
          (item) => [
            TButtonGroupItem(
              child: _buildActionMenu(parent.context, theme, _buildArchiveActionButtons(theme, item.data)),
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

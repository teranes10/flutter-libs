part of 'crud_table.dart';

extension _TCrudTopBarExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  Widget _buildTopBar(BuildContext ctx, BoxConstraints constraints) {
    if (!widget.config.enableBulkActions) {
      return _buildTopBarContent(ctx, hasSelection: false);
    }

    final activeController = currentTab == 0 ? _listController : _archiveListController;
    return ValueListenableBuilder<TListState<T, K>>(
      valueListenable: activeController,
      builder: (context, state, _) => _buildTopBarContent(ctx, hasSelection: activeController.hasSelection),
    );
  }

  List<Widget> _metrics(TListController<T, K> controller) {
    final builder = widget.config.topBarMetricsBuilder;
    if (builder == null) return widget.config.topBarMetrics;
    final count = builder(controller.flatItems).length;
    return [
      ...widget.config.topBarMetrics,
      for (var i = 0; i < count; i++)
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final tiles = builder(controller.flatItems);
            return i < tiles.length ? tiles[i] : const SizedBox.shrink();
          },
        ),
    ];
  }

  Widget _buildTopBarContent(BuildContext ctx, {required bool hasSelection}) {
    final activeController = currentTab == 0 ? _listController : _archiveListController;

    final config = widget.config;
    final hasHeader = config.pageTitle != null || config.pageIcon != null || config.pageInfo != null || config.pageLeading != null;

    // "Add new" is pinned to the right end of the header row; the other actions sit before it, in order, and
    // the ones that don't fit move down to the search row.
    final addButton = canCreate && _crudVisible(_perms?.create)
        ? TButton(
            key: const ValueKey('crud_table_add_button'),
            type: TButtonType.solid,
            icon: HugeIcons.strokeRoundedAdd01,
            text: config.effectiveAddButtonText,
            onPressed: (_) => handleCreate(),
            permission: _perms?.create,
            onDenied: _crudDenied(_perms?.create),
          )
        : null;
    final createAndActions = [...config.topBarActions, if (addButton != null) addButton];

    final selectionActions = [
      TButton(
        type: TButtonType.softText,
        icon: HugeIcons.strokeRoundedCancel01,
        text: activeController.selectionInfo,
        onPressed: (_) => activeController.clearSelection(),
      ),
      ...?config.bulkActionsBuilder?.call(ctx, activeController),
    ];

    final activeIsServerSide = activeController.isServerSide;
    // Large desktop three-row layout: the tabs go to the left of the filters/search row.
    final tabsLeft = showTabs && hasHeader && ctx.isLargeDesktop;
    // TAlignedRow always lays this child out at the row's own maxWidth to measure it,
    // then uses the resulting size to decide row placement. Wrapping TTabs in a
    // LayoutBuilder/ConstrainedBox that stretches to fill that width makes it measure
    // as "full row width" even when the tabs only need their natural content width,
    // which forces it onto its own row every time. Pass TTabs straight through so it
    // reports its real content size and wraps only when it actually overflows.
    final tabsBar = !showTabs
        ? null
        : TTabs(
            wrap: true,
            // Underline tabs on a baseline; the active one is bolder, in the primary color.
            selectedColor: ctx.colors.primary,
            selectedFontWeight: FontWeight.w600,
            indicatorWidth: 2,
            // Narrow screens put the tabs on their own line; let them stretch across it.
            fill: !ctx.isDesktop,
            selectedValue: isFilterTabs ? filterTab : currentTab,
            onTabChanged: (value) {
              if (isFilterTabs) {
                filterTab = value;
                _listController.selectTab(value);
                if (value is int) config.onTabChange?.call(value);
                return;
              }
              currentTab = value;
              config.onTabChange?.call(value);
            },
            tabs: tabs,
          );
    // One continuous, light line under all tabs; the active indicator (2px) is drawn over it.
    final tabsWidget = tabsBar == null
        ? null
        : Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 1,
                child: ColoredBox(color: ctx.colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              tabsBar,
            ],
          );
    final rightItems = [
      if (tabsWidget != null && !tabsLeft) tabsWidget,
      // On narrow screens search and the more-options button share one line as a single item.
      if (ctx.isDesktop) ...[
        _buildSearchBar(ctx).size(w: 300),
        if (shouldShowFilterButton) _buildFilterButton(ctx),
        if (activeIsServerSide) _buildRefreshButton(ctx),
      ] else ...[
        Row(
          spacing: 8,
          children: [Expanded(child: _buildSearchBar(ctx)), _buildMoreOptionsButton(ctx)],
        ),
        if (shouldShowFilterButton) _buildFilterButton(ctx),
      ],
      // Card layout is forced automatically once the table can't fit as a table (narrow
      // screen or overflowing columns) regardless of viewMode, so these manual toggles are
      // meaningless there — only offer them when there's room for them to matter.
      if (ctx.isDesktop) ...[
        _buildViewModeGroup(ctx),
      ],
      if (ctx.isDesktop) _buildMoreOptionsButton(ctx),
    ];

    Widget searchRow(List<Widget> left) => TAlignedRow(
          moveAllToSecondRow: true,
          crossAxisAlignment: CrossAxisAlignment.center,
          rowSpacing: 8,
          wrapperExpanded: true,
          wrapperModeThreshold: 2,
          left: left,
          right: rightItems,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: !hasHeader
          ? searchRow(hasSelection ? selectionActions : createAndActions)
          : _CrudHeaderBar(
              header: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (config.pageLeading != null) config.pageLeading!,
                  // Flexible: the pinned "Add new" never overflows, so a long title must shrink instead.
                  Flexible(
                    child: TTile.h3(
                      icon: config.pageIcon,
                      iconBackgroundColor: Colors.transparent,
                      title: config.pageTitle,
                      subtitle: config.pageInfo,
                    ),
                  ),
                ],
              ),
              // While rows are selected the selection actions take over the search row, and
              // the header row keeps only the page info.
              actions: hasSelection ? const [] : config.topBarActions,
              endAction: hasSelection ? null : addButton,
              metrics: _metrics(activeController),
              // Large desktop screens (>= kLargeDesktopBreakpoint): header + actions / metrics row / filters + search each get their own row.
              metricsOwnRow: ctx.isLargeDesktop,
              searchRowBuilder: (leading, overflow) => searchRow([
                ...leading,
                if (tabsLeft && tabsWidget != null) tabsWidget,
                ...(hasSelection ? selectionActions : overflow),
              ]),
            ),
    );
  }

  Widget _buildViewModeGroup(BuildContext ctx) {
    // Segmented mode wraps its buttons in a track with `boxedPadding: EdgeInsets.all(3)`
    // (TButtonGroupTheme.fromBaseTheme), so the track ends up 6px taller than the button's
    // own minH unless that's subtracted here — otherwise this sits taller than the search
    // bar it's aligned next to.
    final inputSize = TInputSize.sm;
    return TButtonGroup(
      type: TButtonGroupType.segmented,
      size: TButtonSize.fromInputSize(inputSize).copyWith(minH: inputSize.height - 6),
      initialIndex: viewMode == 2 ? 1 : 0,
      onIndexChanged: (index) => viewMode = index == 1 ? 2 : 0,
      items: [
        TButtonGroupItem(icon: HugeIcons.strokeRoundedTableOfContents, tooltip: 'List View'),
        TButtonGroupItem(icon: HugeIcons.strokeRoundedGridView, tooltip: 'Grid View'),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext ctx) {
    final activeController = currentTab == 0 ? _listController : _archiveListController;
    final defs = effectiveFilterDefs;

    return TDropdown(
      triggerMode: TDropdownTriggerMode.tap,
      theme: ctx.theme.dropdownTheme.copyWith(
        gap: 4.0,
        boxConstraints: const BoxConstraints(
          minWidth: 420,
          maxWidth: 640,
        ),
      ),
      builder: (dropdownCtx, close) {
        final screenWidth = MediaQuery.of(dropdownCtx).size.width;
        final panelWidth = (screenWidth * 0.9).clamp(420.0, 580.0);

        return TContainer(
          glassMode: TGlassMode.surface,
          width: panelWidth,
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: dropdownCtx.colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dropdownCtx.colors.outline.withAlpha(80)),
            boxShadow: [
              BoxShadow(
                color: dropdownCtx.colors.shadow.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ValueListenableBuilder<TListState<T, K>>(
              valueListenable: activeController,
              builder: (context, state, _) {
                return TFilterField<Map<String, dynamic>>(
                  filters: defs,
                  value: state.advancedSearch,
                  construct: (json) => json,
                  toJson: (map) => map,
                  onValueChanged: (val) => activeController.handleAdvancedSearchChange(val ?? {}),
                );
              },
            ),
          ),
        );
      },
      child: ValueListenableBuilder<TListState<T, K>>(
        valueListenable: activeController,
        builder: (context, state, _) {
          final activeCount = state.advancedSearch?.keys.length ?? 0;
          final hasActiveFilters = activeCount > 0;

          return TButton(
            type: TButtonType.surface,
            asTrigger: true,
            size: TButtonSize.fromInputSize(TInputSize.sm),
            icon: HugeIcons.strokeRoundedFilter,
            badge: hasActiveFilters ? activeCount : null,
            tooltip: hasActiveFilters ? _filterTooltip(state.advancedSearch!, defs) : 'Filter',
          );
        },
      ),
    );
  }

  /// One line per active filter, e.g. `Price >= 10` or `Category in A, B, C`, using the operator's short symbol.
  String _filterTooltip(Map<String, dynamic> filters, List<TFilterDef<T>> defs) {
    const maxLines = 8;
    const maxListItems = 5;

    String value(dynamic v) {
      if (v is List) {
        final shown = v.take(maxListItems).map((e) => '$e').join(', ');
        return v.length > maxListItems ? '$shown +${v.length - maxListItems}' : shown;
      }
      return '$v';
    }

    final lines = <String>[];
    for (final MapEntry(key: field, value: ops) in filters.entries) {
      if (ops is! Map) continue;
      final label = defs.where((d) => d.key == field).map((d) => d.label).firstOrNull ?? field;
      for (final MapEntry(key: opId, value: val) in ops.entries) {
        if (opId == 'isNull') {
          lines.add('$label ${val == false ? 'is not null' : 'is null'}');
          continue;
        }
        final op = TFilterOperator.fromId('$opId');
        lines.add('$label ${op.shortLabel ?? op.label} ${value(val)}');
      }
    }
    if (lines.length <= maxLines) return lines.join('\n');
    return '${lines.take(maxLines).join('\n')}\n+${lines.length - maxLines} more';
  }

  Widget _buildRefreshButton(BuildContext ctx) {
    return TButton(
      type: TButtonType.surface,
      size: TButtonSize.fromInputSize(TInputSize.sm),
      icon: HugeIcons.strokeRoundedRefresh01,
      tooltip: 'Refresh',
      onPressed: (_) => (currentTab == 0 ? _listController : _archiveListController).handleRefresh(),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) {
    final glass = TGlassStyle.resolve(ctx);
    final liquid = glass != null && glass.isLiquid;
    final theme = ctx.theme.textFieldTheme.copyWith(
      size: TInputSize.sm,
      labelPosition: TLabelPosition.aboveField,
      decorationType: TInputDecorationType.outline,
      // Liquid: the field is transparent and borderless; the liquid pane around it provides the surface and edge.
      backgroundColor: WidgetStatePropertyAll(liquid ? Colors.transparent : ctx.colors.surface),
      borderColor: liquid ? const WidgetStatePropertyAll(Colors.transparent) : null,
      preWidget: TIcon.raw(HugeIcons.strokeRoundedSearch01, size: 18, color: ctx.colors.onSurface),
    );
    final field = TTextField(
      key: const ValueKey('crud_table_search_field'),
      value: listController.value.search,
      theme: theme,
      placeholder: widget.config.effectiveSearchPlaceholder,
      onValueChanged: (String? input) {
        if (currentTab == 0) {
          listController.handleSearchChange(input ?? '');
        } else {
          archiveListController.handleSearchChange(input ?? '');
        }
      },
    );
    if (!liquid) return field;
    return TGlassSurface.wrap(
      ctx,
      radius: BorderRadius.circular(theme.borderRadius.resolve(const {})),
      color: ctx.colors.surface,
      child: field,
    );
  }

  Widget _buildMoreOptionsButton(BuildContext ctx) {
    return TDropdown(
      triggerMode: TDropdownTriggerMode.tap,
      items: [
        // Dense/comfortable only affects table-row spacing — meaningless in Grid View (cards)
        // or on narrow screens, so it lives in this menu instead of taking toolbar space.
        if (ctx.isDesktop && viewMode != 2)
          TDropdownItem(
            icon: dense ? HugeIcons.strokeRoundedUnfoldMore : HugeIcons.strokeRoundedUnfoldLess,
            text: dense ? 'Comfortable Rows' : 'Dense Rows',
            onTap: () => dense = !dense,
          ),
        TDropdownItem(
          icon: HugeIcons.strokeRoundedDeleteColumn,
          text: 'Column Visibility',
          children: [
            TDropdownItem(
              customContent: Listener(
                onPointerMove: (event) {
                  _lastPointerPosition = event.position;
                },
                onPointerUp: (event) {
                  _lastPointerPosition = event.position;
                },
                child: SizedBox(
                  key: _dropdownListKey,
                  width: 250,
                  height: _getColumnListHeight(),
                  child: ValueListenableBuilder<TListState<T, K>>(
                    valueListenable: _listController,
                    builder: (context, state, _) {
                      return _ColumnVisibilityMenu(
                        headers: widget.headers,
                        headerOrder: _listController.headerOrder,
                        headerVisibility: _listController.headerVisibility,
                        onVisibilityChanged: (text, visible) {
                          toggleHeaderVisibility(text, visible);
                        },
                        onReorder: (oldIndex, newIndex) {
                          final text = List<String>.from(_listController.headerOrder);
                          final moved = text.removeAt(oldIndex);
                          text.insert(newIndex, moved);
                          _listController.updateHeaderOrder(text);
                          _archiveListController.updateHeaderOrder(text);
                          _persistRouteSettings();
                        },
                        onReorderEnd: () {
                          final renderBox = _dropdownListKey.currentContext?.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            final localOffset = renderBox.globalToLocal(_lastPointerPosition);
                            final isInside = renderBox.paintBounds.contains(localOffset);
                            if (!isInside) {
                              TMenuOverlayController.hideAll();
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        // Create/Expand mode (side panel, side overlay, dialog, full page, inline bottom) are
        // desktop layout choices — on narrow/mobile screens the table already renders as cards
        // and these presentation options don't apply.
        if (ctx.isDesktop)
          TDropdownItem(
            icon: HugeIcons.strokeRoundedUnfoldMore,
            text: 'Expand Mode',
            children: [
              TDropdownItem(
                icon: HugeIcons.strokeRoundedArrowRight01,
                text: 'Side Panel',
                onTap: () {
                  expansionMode = TTableExpansionMode.side;
                },
              ),
              _buildExpandModeItemWithWidth(
                ctx: ctx,
                icon: HugeIcons.strokeRoundedArrowUpRight01,
                text: 'Side Overlay',
                isSelected: effectiveExpansionMode == TTableExpansionMode.sideOverlay,
                onSelect: () {
                  expansionMode = TTableExpansionMode.sideOverlay;
                },
                currentWidth: effectiveSideOverlayWidth.toInt(),
                onWidthChanged: (w) {
                  sideOverlayWidth = w;
                },
              ),
              _buildExpandModeItemWithWidth(
                ctx: ctx,
                icon: HugeIcons.strokeRoundedArrowUp02,
                text: 'Dialog',
                isSelected: effectiveExpansionMode == TTableExpansionMode.dialog,
                onSelect: () {
                  expansionMode = TTableExpansionMode.dialog;
                },
                currentWidth: effectiveDialogWidth.toInt(),
                onWidthChanged: (w) {
                  dialogWidth = w;
                },
              ),
              TDropdownItem(
                icon: HugeIcons.strokeRoundedLinkForward,
                text: 'Full Page',
                onTap: () {
                  expansionMode = TTableExpansionMode.page;
                },
              ),
              TDropdownItem(
                icon: HugeIcons.strokeRoundedArrowDown01,
                text: 'Inline Bottom',
                onTap: () {
                  expansionMode = TTableExpansionMode.bottom;
                },
              ),
            ],
          ),
        if (canCreate && ctx.isDesktop)
          TDropdownItem(
            icon: HugeIcons.strokeRoundedAddSquare,
            text: 'Create Mode',
            children: [
              TDropdownItem(
                icon: HugeIcons.strokeRoundedArrowRight01,
                text: 'Side Panel',
                onTap: () {
                  createMode = TTableExpansionMode.side;
                },
              ),
              _buildExpandModeItemWithWidth(
                ctx: ctx,
                icon: HugeIcons.strokeRoundedArrowUpRight01,
                text: 'Side Overlay',
                isSelected: effectiveCreateMode == TTableExpansionMode.sideOverlay,
                onSelect: () {
                  createMode = TTableExpansionMode.sideOverlay;
                },
                currentWidth: effectiveCreateSideOverlayWidth.toInt(),
                onWidthChanged: (w) {
                  createSideOverlayWidth = w;
                },
              ),
              _buildExpandModeItemWithWidth(
                ctx: ctx,
                icon: HugeIcons.strokeRoundedArrowUp02,
                text: 'Dialog',
                isSelected: effectiveCreateMode == TTableExpansionMode.dialog,
                onSelect: () {
                  createMode = TTableExpansionMode.dialog;
                },
                currentWidth: effectiveCreateDialogWidth.toInt(),
                onWidthChanged: (w) {
                  createDialogWidth = w;
                },
              ),
              TDropdownItem(
                icon: HugeIcons.strokeRoundedLinkForward,
                text: 'Full Page',
                onTap: () {
                  createMode = TTableExpansionMode.page;
                },
              ),
              TDropdownItem(
                icon: HugeIcons.strokeRoundedArrowDown01,
                text: 'Inline Bottom',
                onTap: () {
                  createMode = TTableExpansionMode.bottom;
                },
              ),
            ],
          ),
        TDropdownItem(
          icon: HugeIcons.strokeRoundedPictureInPicture,
          text: 'Export as PDF',
          permission: _perms?.export,
          onDenied: _crudDenied(_perms?.export),
          onTap: () => handleExportPdf(),
        ),
        TDropdownItem(
          icon: HugeIcons.strokeRoundedTable,
          text: 'Export as CSV',
          permission: _perms?.export,
          onDenied: _crudDenied(_perms?.export),
          onTap: () => handleExportCsv(),
        ),
      ],
      child: TButton(
        type: TButtonType.surface,
        asTrigger: true,
        size: TButtonSize.fromInputSize(TInputSize.sm),
        icon: HugeIcons.strokeRoundedSettings01,
      ),
    );
  }

  TDropdownItem _buildExpandModeItemWithWidth({
    required BuildContext ctx,
    required dynamic icon,
    required String text,
    required bool isSelected,
    required VoidCallback onSelect,
    required int currentWidth,
    required ValueChanged<double> onWidthChanged,
  }) {
    final colors = ctx.colors;
    final dropdownTheme = ctx.theme.dropdownTheme;
    return TDropdownItem(
      // `customContent` rows bypass TMenuOverlayItem entirely (no itemPadding, no hover
      // highlight), so its own padding must mirror `dropdownTheme.itemPadding` exactly —
      // otherwise this icon sits out of line with the plain text rows (Side Panel, Full
      // Page, Inline Bottom) above and below it.
      customContent: Padding(
        padding: dropdownTheme.itemPadding,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  onSelect();
                  TMenuOverlayController.hideAll();
                },
                borderRadius: dropdownTheme.itemBorderRadius,
                child: Row(
                  children: [
                    TIcon(
                      icon: icon,
                      size: dropdownTheme.iconSize,
                      color: isSelected ? colors.primary : colors.onSurface,
                    ),
                    SizedBox(width: dropdownTheme.gap),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: dropdownTheme.fontSize,
                          fontWeight: isSelected ? FontWeight.w500 : dropdownTheme.fontWeight,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 125,
              child: TNumberField<int>(
                value: currentWidth,
                label: 'Width',
                splitStepper: true,
                theme: ctx.theme.numberFieldTheme.copyWith(
                  decorationType: TInputDecorationType.outline,
                  labelPosition: TLabelPosition.inlineFloating,
                  size: TInputSize.xs,
                  increment: 50,
                  decrement: 50,
                  decimals: 0,
                ),
                onValueChanged: (val) {
                  if (val != null && val >= 100) {
                    onWidthChanged(val.toDouble());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getColumnListHeight() {
    return (widget.headers.length * 34.0).clamp(100.0, 300.0);
  }
}

class _ColumnVisibilityMenu extends StatefulWidget {
  final List<TTableHeader<dynamic, dynamic>> headers;
  final List<String> headerOrder;
  final Map<String, bool> headerVisibility;
  final Function(String, bool) onVisibilityChanged;
  final Function(int, int) onReorder;
  final VoidCallback onReorderEnd;

  const _ColumnVisibilityMenu({
    required this.headers,
    required this.headerOrder,
    required this.headerVisibility,
    required this.onVisibilityChanged,
    required this.onReorder,
    required this.onReorderEnd,
  });

  @override
  State<_ColumnVisibilityMenu> createState() => _ColumnVisibilityMenuState();
}

class _ColumnVisibilityMenuState extends State<_ColumnVisibilityMenu> {
  @override
  Widget build(BuildContext context) {
    final orderedHeaders = <TTableHeader<dynamic, dynamic>>[];
    for (final text in widget.headerOrder) {
      final idx = widget.headers.indexWhere((h) => h.text == text);
      if (idx != -1) {
        orderedHeaders.add(widget.headers[idx]);
      }
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: orderedHeaders.length,
        buildDefaultDragHandles: false,
        onReorderStart: (index) {
          TMenuOverlayController.isLocked = true;
        },
        onReorderEnd: (index) {
          TMenuOverlayController.isLocked = false;
          widget.onReorderEnd();
        },
        // ignore: deprecated_member_use
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            widget.onReorder(oldIndex, newIndex);
          });
        },
        itemBuilder: (context, index) {
          final header = orderedHeaders[index];
          return Row(
            key: ValueKey(header.text),
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: TIcon.raw(
                    HugeIcons.strokeRoundedGripVertical,
                    size: 12,
                    color: context.colors.onSurfaceVariant.withAlpha(200),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  header.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TSwitch(
                  size: TInputSize.xs,
                  value: widget.headerVisibility[header.text] ?? true,
                  onValueChanged: (val) {
                    setState(() {
                      widget.onVisibilityChanged(header.text, val ?? false);
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Page header row: [header] on the left with [actions] and, pinned at the far right, [endAction] on the same row.
///
/// Widths of the header and every action are measured once (off-stage, unconstrained) and cached;
/// from then on the split is pure arithmetic against the available width, so resizing never
/// re-measures. Actions that don't fit are handed to [searchRowBuilder] as `overflow`, which
/// places them left of the search; [endAction] never overflows. [metrics] sits between the two rows.
class _CrudHeaderBar extends StatefulWidget {
  final Widget header;
  final List<Widget> actions;

  /// Always shown at the right end of the header row (e.g. "Add new"), after [actions].
  final Widget? endAction;
  final List<Widget> metrics;

  /// Large desktop screens: show [metrics] on their own left-aligned row between the header row and the search row. When
  /// false (smaller screens) they share the search row's left group to use the space.
  final bool metricsOwnRow;

  /// [leading] are the metric tiles, placed first in the row's left group.
  final Widget Function(List<Widget> leading, List<Widget> overflow) searchRowBuilder;

  const _CrudHeaderBar({
    required this.header,
    required this.actions,
    required this.searchRowBuilder,
    this.endAction,
    this.metrics = const [],
    this.metricsOwnRow = false,
  });

  @override
  State<_CrudHeaderBar> createState() => _CrudHeaderBarState();
}

class _CrudHeaderBarState extends State<_CrudHeaderBar> {
  static const double _gap = 8;

  List<GlobalKey> _keys = [];
  List<double>? _widths; // [header, ...actions, endAction?]

  /// Width of each metric tile; they sit in the search row's left group, the controls on the right.
  static const double _tileWidth = 220;

  /// Upper bound a metric tile grows to on the metrics row.
  static const double _maxTileWidth = 300;

  @override
  void initState() {
    super.initState();
    _resetMeasure();
  }

  @override
  void didUpdateWidget(_CrudHeaderBar old) {
    super.didUpdateWidget(old);
    if (old.actions.length != widget.actions.length || (old.endAction == null) != (widget.endAction == null)) _resetMeasure();
  }

  void _resetMeasure() {
    _keys = List.generate(widget.actions.length + 1 + (widget.endAction != null ? 1 : 0), (_) => GlobalKey());
    _widths = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final widths = [for (final k in _keys) (k.currentContext?.size?.width)];
      if (widths.any((w) => w == null)) return;
      setState(() {
        _widths = widths.cast<double>();
      });
    });
  }

  Widget _buildBody(List<Widget> overflow) {
    if (!widget.metricsOwnRow || widget.metrics.isEmpty) {
      return widget.searchRowBuilder([for (final m in widget.metrics) SizedBox(width: _tileWidth, child: m)], overflow);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tiles share the row, growing from _tileWidth up to _maxTileWidth when there is room.
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = _gap + 4;
            final count = widget.metrics.length;
            final share = (constraints.maxWidth - gap * (count - 1)) / count;
            final tileWidth = share.isFinite ? share.clamp(_tileWidth, _maxTileWidth) : _tileWidth;
            return Wrap(
              alignment: WrapAlignment.start,
              spacing: gap,
              runSpacing: gap,
              children: [for (final m in widget.metrics) SizedBox(width: tileWidth, child: m)],
            );
          },
        ),
        const SizedBox(height: 16),
        widget.searchRowBuilder(const [], overflow),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final widths = _widths;
    final actions = widget.actions;

    final measure = widths != null
        ? const SizedBox.shrink()
        : Offstage(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  SizedBox(key: _keys[0], child: widget.header),
                  for (var i = 0; i < actions.length; i++) SizedBox(key: _keys[i + 1], child: actions[i]),
                  if (widget.endAction != null) SizedBox(key: _keys[actions.length + 1], child: widget.endAction),
                ],
              ),
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        var fitCount = 0;
        if (widths != null) {
          var used = widths[0];
          // The end action always stays; reserve its room first.
          if (widget.endAction != null) used += _gap + widths[actions.length + 1];
          for (var i = 0; i < actions.length; i++) {
            used += _gap + widths[i + 1];
            if (used > constraints.maxWidth) break;
            fitCount++;
          }
        } else {
          fitCount = actions.length;
        }

        final overflow = actions.sublist(fitCount);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            measure,
            Opacity(
              opacity: widths == null ? 0 : 1,
              child: Row(
                children: [
                  Expanded(child: Align(alignment: Alignment.centerLeft, child: widget.header)),
                  for (var i = 0; i < fitCount; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    actions[i],
                  ],
                  if (widget.endAction != null) ...[
                    if (fitCount > 0) const SizedBox(width: _gap),
                    widget.endAction!,
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBody(overflow),
          ],
        );
      },
    );
  }
}

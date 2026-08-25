part of 'crud_table.dart';

extension _TCrudTopBarExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  Widget _buildTopBar(BuildContext ctx, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TAlignedRow(
        moveAllToSecondRow: true,
        wrapperExpanded: true,
        wrapperModeThreshold: 2,
        left: [
          if (canCreate)
            TButton(
              type: TButtonType.tonal,
              icon: Icons.add,
              text: widget.config.addButtonText,
              onPressed: (_) => handleCreate(),
            ),
          ...widget.config.topBarActions,
        ],
        right: [
          if (showTabs)
            TTabs(
              inline: true,
              selectedValue: currentTab,
              onTabChanged: (i) {
                currentTab = i;
                widget.config.onTabChange?.call(i);
              },
              tabs: tabs,
            ),
          _buildSearchBar(ctx).size(w: 275),
          _buildMoreOptionsButton(ctx),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) {
    return TTextField(
      value: listController.value.search,
      theme: ctx.theme.textFieldTheme.copyWith(
        size: TInputSize.sm,
        labelPosition: TLabelPosition.aboveField,
        decorationType: TInputDecorationType.filled,
        postWidget: Icon(Icons.search_rounded, size: 18, color: ctx.colors.onSurface),
      ),
      placeholder: widget.config.searchPlaceholder,
      onValueChanged: (String? input) {
        if (currentTab == 0) {
          listController.handleSearchChange(input ?? '');
        } else {
          archiveListController.handleSearchChange(input ?? '');
        }
      },
    );
  }

  Widget _buildMoreOptionsButton(BuildContext ctx) {
    return TDropdown(
      items: [
        TDropdownItem(
          icon: dense ? Icons.density_small_rounded : Icons.density_medium_rounded,
          text: dense ? 'Comfortable Layout' : 'Dense Layout',
          onTap: () {
            dense = !dense;
          },
        ),
        TDropdownItem(
          icon: Icons.view_column_rounded,
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
        TDropdownItem(
          icon: Icons.grid_view_rounded,
          text: 'View Mode',
          children: [
            TDropdownItem(
              icon: Icons.view_list_rounded,
              text: 'Table View',
              onTap: () {
                viewMode = 0;
              },
            ),
            TDropdownItem(
              icon: Icons.view_agenda_rounded,
              text: 'Card View',
              onTap: () {
                viewMode = 1;
              },
            ),
            TDropdownItem(
              icon: Icons.grid_view_rounded,
              text: 'Grid View',
              onTap: () {
                viewMode = 2;
              },
            ),
          ],
        ),
        TDropdownItem(
          icon: Icons.unfold_more_rounded,
          text: 'Expand Mode',
          children: [
            TDropdownItem(
              icon: Icons.dock_rounded,
              text: 'Side Panel',
              onTap: () {
                expansionMode = TTableExpansionMode.side;
              },
            ),
            _buildExpandModeItemWithWidth(
              ctx: ctx,
              icon: Icons.view_sidebar_rounded,
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
              icon: Icons.aspect_ratio_rounded,
              text: 'Modal Dialog',
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
              icon: Icons.article_rounded,
              text: 'Full Page',
              onTap: () {
                expansionMode = TTableExpansionMode.page;
              },
            ),
            TDropdownItem(
              icon: Icons.expand_more_rounded,
              text: 'Inline Bottom',
              onTap: () {
                expansionMode = TTableExpansionMode.bottom;
              },
            ),
          ],
        ),
        if (canCreate)
          TDropdownItem(
            icon: Icons.add_box_rounded,
            text: 'Create Mode',
            children: [
              _buildExpandModeItemWithWidth(
                ctx: ctx,
                icon: Icons.aspect_ratio_rounded,
                text: 'Modal Dialog',
                isSelected: effectiveCreateMode == TTableExpansionMode.dialog,
                onSelect: () {
                  createMode = TTableExpansionMode.dialog;
                },
                currentWidth: effectiveCreateDialogWidth.toInt(),
                onWidthChanged: (w) {
                  createDialogWidth = w;
                },
              ),
              _buildExpandModeItemWithWidth(
                ctx: ctx,
                icon: Icons.view_sidebar_rounded,
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
              TDropdownItem(
                icon: Icons.dock_rounded,
                text: 'Side Panel',
                onTap: () {
                  createMode = TTableExpansionMode.side;
                },
              ),
              TDropdownItem(
                icon: Icons.article_rounded,
                text: 'Full Page',
                onTap: () {
                  createMode = TTableExpansionMode.page;
                },
              ),
              TDropdownItem(
                icon: Icons.expand_more_rounded,
                text: 'Inline Bottom',
                onTap: () {
                  createMode = TTableExpansionMode.bottom;
                },
              ),
            ],
          ),
        TDropdownItem(
          icon: Icons.picture_as_pdf_rounded,
          text: 'Export as PDF',
          onTap: () => handleExportPdf(),
        ),
        TDropdownItem(
          icon: Icons.table_chart_rounded,
          text: 'Export as CSV',
          onTap: () => handleExportCsv(),
        ),
      ],
      child: TButton(
        type: TButtonType.text,
        color: ctx.colors.onSurfaceVariant,
        size: TButtonSize.sm,
        icon: Icons.more_vert,
      ),
    );
  }

  TDropdownItem _buildExpandModeItemWithWidth({
    required BuildContext ctx,
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onSelect,
    required int currentWidth,
    required ValueChanged<double> onWidthChanged,
  }) {
    final colors = ctx.colors;
    return TDropdownItem(
      customContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  onSelect();
                  TMenuOverlayController.hideAll();
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected ? colors.primary : colors.onSurface,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
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
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: TNumberField<int>(
                value: currentWidth,
                splitStepper: true,
                theme: ctx.theme.numberFieldTheme.copyWith(
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
    return (widget.headers.length * 36.0 + 8.0).clamp(100.0, 300.0);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  size: 20,
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

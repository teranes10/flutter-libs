part of 'crud_table.dart';

class _TCrudTopBar<T, K, F extends TFormBase> {
  final _TCrudTableState<T, K, F> parent;

  _TCrudTopBar({required this.parent});

  Widget build(BuildContext ctx, BoxConstraints constraints) {
    final rows = <Widget>[];
    final maxWidth = constraints.maxWidth;
    final isMobile = constraints.isMobile;

    const spacing = 8.0;
    const rowSpacing = 12.0;
    final tabsWidth = TTab.calculateTabsWidth(parent.tabs);
    const searchWidth = 370.0; // 250 search bar width + 8 spacing + ~52 cycle button width + 8 spacing + ~52 export button width

    var currentRow = <Widget>[];
    var currentRowWidth = 0.0;

    void pushRow({MainAxisAlignment align = MainAxisAlignment.start}) {
      if (currentRow.isNotEmpty) {
        rows.add(_buildAlignedRow(currentRow, align));
        currentRow = [];
        currentRowWidth = 0.0;
      }
    }

    void addWidget(Widget widget, double width) {
      if (currentRowWidth + width + (currentRow.isNotEmpty ? spacing : 0) <= maxWidth) {
        if (currentRow.isNotEmpty) currentRowWidth += spacing;
        currentRow.add(_wrapButton(widget, isMobile));
        currentRowWidth += width;
      } else {
        pushRow();
        currentRow.add(_wrapButton(widget, isMobile));
        currentRowWidth = width;
      }
    }

    // Create button
    if (parent.canCreate) {
      final btn = TButton(
        type: TButtonType.tonal,
        icon: Icons.add,
        text: parent.widget.config.addButtonText,
        onPressed: (_) => parent.handleCreate(),
      );
      addWidget(btn, btn.estimateWidth());
    }

    // Action buttons
    for (var action in parent.widget.config.topBarActions) {
      final width = action is TButton ? action.estimateWidth() : 132.0;
      addWidget(action, width);
    }

    // Tabs + Search + View Cycle Button
    if (parent.showTabs || currentRow.isNotEmpty) {
      final tabsAndSearchWidth = (parent.showTabs ? tabsWidth + spacing : 0) + searchWidth;

      if (currentRow.isNotEmpty && currentRowWidth + spacing + tabsAndSearchWidth <= maxWidth) {
        // Same row
        currentRow.add(const Spacer());
        if (parent.showTabs) {
          currentRow.add(_buildTabs(constraints));
          currentRow.add(const SizedBox(width: spacing));
        }
        currentRow.add(_buildSearchAndCycle(ctx, constraints));
        pushRow();
      } else {
        // Push actions row
        pushRow();

        if (tabsAndSearchWidth <= maxWidth) {
          // Tabs + Search in one row
          final tabSearchRow = <Widget>[
            if (parent.showTabs) _buildTabs(constraints),
            if (parent.showTabs) const SizedBox(width: spacing),
            _buildSearchAndCycle(ctx, constraints),
          ];
          rows.add(_buildAlignedRow(tabSearchRow, MainAxisAlignment.end));
        } else {
          // Stack them
          if (parent.showTabs) {
            rows.add(_buildAlignedRow([_buildTabs(constraints)], MainAxisAlignment.center));
          }
          rows.add(_buildAlignedRow([_buildSearchAndCycle(ctx, constraints)], MainAxisAlignment.end));
        }
      }
    } else {
      pushRow();
    }

    final children = rows.expand((row) => [row, const SizedBox(height: rowSpacing)]).toList();
    if (children.isNotEmpty) {
      children.removeLast();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildAlignedRow(List<Widget> widgets, MainAxisAlignment alignment) {
    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _withSpacing(widgets, 8),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets, double spacing) {
    if (widgets.length <= 1) return widgets;
    return [
      for (var i = 0; i < widgets.length; i++) ...[
        widgets[i],
        if (i < widgets.length - 1 && widgets[i] is! Spacer && widgets[i + 1] is! Spacer) SizedBox(width: spacing),
      ]
    ];
  }

  Widget _wrapButton(Widget button, bool isMobile) {
    return isMobile && button is TButton
        ? Flexible(child: button.copyWith(size: (button.size ?? TButtonSize.md).copyWith(minW: double.infinity)))
        : button;
  }

  Widget _buildTabs(BoxConstraints constraints) {
    final tabs = TTabs(
      inline: !constraints.isMobile,
      selectedValue: parent.currentTab,
      onTabChanged: (i) {
        parent.currentTab = i;
        parent.widget.config.onTabChange?.call(i);
      },
      tabs: parent.tabs,
    );
    return !constraints.isMobile ? tabs : Flexible(child: tabs);
  }

  Widget _buildSearchBar(BuildContext ctx, BoxConstraints constraints) {
    return TTextField(
      value: parent.listController.value.search,
      theme: ctx.theme.textFieldTheme.copyWith(
        size: TInputSize.sm,
        labelPosition: TLabelPosition.aboveField,
        decorationType: TInputDecorationType.filled,
        postWidget: Icon(Icons.search_rounded, size: 18, color: ctx.colors.onSurface),
      ),
      placeholder: parent.widget.config.searchPlaceholder,
      onValueChanged: (String? input) {
        if (parent.currentTab == 0) {
          parent.listController.handleSearchChange(input ?? '');
        } else {
          parent.archiveListController.handleSearchChange(input ?? '');
        }
      },
    );
  }

  Widget _buildCycleButton(BuildContext ctx) {
    return TButtonGroup(
      type: TButtonGroupType.tonal,
      size: TButtonSize.md,
      cycle: true,
      initialIndex: parent.viewMode,
      onIndexChanged: (index) {
        parent.viewMode = index;
      },
      items: [
        TButtonGroupItem(
          icon: Icons.view_list_rounded,
          tooltip: 'Table View',
        ),
        TButtonGroupItem(
          icon: Icons.view_agenda_rounded,
          tooltip: 'Card View',
        ),
        TButtonGroupItem(
          icon: Icons.grid_view_rounded,
          tooltip: 'Grid View',
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext ctx) {
    return TDropdown(
      items: [
        TDropdownItem(
          icon: Icons.picture_as_pdf_rounded,
          text: 'Export as PDF',
          onTap: () => parent.handleExportPdf(),
        ),
        TDropdownItem(
          icon: Icons.table_chart_rounded,
          text: 'Export as CSV',
          onTap: () => parent.handleExportCsv(),
        ),
      ],
      child: TButton(
        type: TButtonType.tonal,
        size: TButtonSize.md,
        icon: Icons.download_rounded,
        tooltip: 'Export',
      ),
    );
  }

  Widget _buildSearchAndCycle(BuildContext ctx, BoxConstraints constraints) {
    final search = _buildSearchBar(ctx, constraints);
    final cycleBtn = _buildCycleButton(ctx);
    final exportBtn = _buildExportButton(ctx);

    if (constraints.isMobile) {
      return Flexible(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: search),
            const SizedBox(width: 8),
            cycleBtn,
            const SizedBox(width: 8),
            exportBtn,
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 250, child: search),
        const SizedBox(width: 8),
        cycleBtn,
        const SizedBox(width: 8),
        exportBtn,
      ],
    );
  }
}

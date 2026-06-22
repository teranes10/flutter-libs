part of 'crud_table.dart';

class _TCrudTopBar<T, K, F extends TFormBase> {
  final _TCrudTableState<T, K, F> parent;

  _TCrudTopBar({required this.parent});

  Widget build(BuildContext ctx, BoxConstraints constraints) {
    final isMobile = constraints.isMobile;
    final searchBar = _buildSearchBar(ctx);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TAlignedRow(
        left: [
          if (parent.canCreate)
            TButton(
              type: TButtonType.tonal,
              icon: Icons.add,
              text: parent.widget.config.addButtonText,
              onPressed: (_) => parent.handleCreate(),
            ),
          ...parent.widget.config.topBarActions,
        ],
        right: [
          if (parent.showTabs)
            TTabs(
              inline: !isMobile,
              selectedValue: parent.currentTab,
              onTabChanged: (i) {
                parent.currentTab = i;
                parent.widget.config.onTabChange?.call(i);
              },
              tabs: parent.tabs,
            ),
          if (isMobile) searchBar else SizedBox(width: 275, child: searchBar),
          _buildCycleButton(ctx),
          _buildExportButton(ctx),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) {
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
}

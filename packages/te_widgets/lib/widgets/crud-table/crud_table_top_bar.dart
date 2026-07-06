part of 'crud_table.dart';

class _TCrudTopBar<T, K, F extends TFormBase> {
  final _TCrudTableState<T, K, F> parent;

  _TCrudTopBar({required this.parent});

  Widget build(BuildContext ctx, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TAlignedRow(
        moveAllToSecondRow: true,
        wrapperExpanded: true,
        wrapperModeThreshold: 2,
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
              inline: true,
              selectedValue: parent.currentTab,
              onTabChanged: (i) {
                parent.currentTab = i;
                parent.widget.config.onTabChange?.call(i);
              },
              tabs: parent.tabs,
            ),
          _buildSearchBar(ctx).size(w: 275),
          _buildMoreOptionsButton(ctx),
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

  Widget _buildMoreOptionsButton(BuildContext ctx) {
    return TDropdown(
      items: [
        TDropdownItem(
          icon: parent.dense ? Icons.density_small_rounded : Icons.density_medium_rounded,
          text: parent.dense ? 'Comfortable Layout' : 'Dense Layout',
          onTap: () {
            parent.dense = !parent.dense;
          },
        ),
        TDropdownItem(
          icon: Icons.grid_view_rounded,
          text: 'View Mode',
          children: [
            TDropdownItem(
              icon: Icons.view_list_rounded,
              text: 'Table View',
              onTap: () {
                parent.viewMode = 0;
              },
            ),
            TDropdownItem(
              icon: Icons.view_agenda_rounded,
              text: 'Card View',
              onTap: () {
                parent.viewMode = 1;
              },
            ),
            TDropdownItem(
              icon: Icons.grid_view_rounded,
              text: 'Grid View',
              onTap: () {
                parent.viewMode = 2;
              },
            ),
          ],
        ),
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
        type: TButtonType.text,
        color: ctx.colors.onSurfaceVariant,
        size: TButtonSize.sm,
        icon: Icons.more_vert,
        tooltip: 'More Options',
      ),
    );
  }
}

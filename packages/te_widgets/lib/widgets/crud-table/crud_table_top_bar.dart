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
        tooltip: 'More Options',
      ),
    );
  }
}

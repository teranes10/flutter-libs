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
    const searchWidth = 300.0;

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
        type: TButtonType.softOutline,
        size: TButtonSize.lg,
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

    // Tabs + Search
    if (parent.showTabs || currentRow.isNotEmpty) {
      final tabsAndSearchWidth = (parent.showTabs ? tabsWidth + spacing : 0) + searchWidth;

      if (currentRow.isNotEmpty && currentRowWidth + spacing + tabsAndSearchWidth <= maxWidth) {
        // Same row
        currentRow.add(const Spacer());
        if (parent.showTabs) {
          currentRow.add(_buildTabs(constraints));
          currentRow.add(const SizedBox(width: spacing));
        }
        currentRow.add(_buildSearchBar(ctx, constraints));
        pushRow();
      } else {
        // Push actions row
        pushRow();

        if (tabsAndSearchWidth <= maxWidth) {
          // Tabs + Search in one row
          final tabSearchRow = <Widget>[
            if (parent.showTabs) _buildTabs(constraints),
            if (parent.showTabs) const SizedBox(width: spacing),
            _buildSearchBar(ctx, constraints),
          ];
          rows.add(_buildAlignedRow(tabSearchRow, MainAxisAlignment.end));
        } else {
          // Stack them
          if (parent.showTabs) {
            rows.add(_buildAlignedRow([_buildTabs(constraints)], MainAxisAlignment.center));
          }
          rows.add(_buildAlignedRow([_buildSearchBar(ctx, constraints)], MainAxisAlignment.end));
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
      onTabChanged: (i) => parent.currentTab = i,
      tabs: parent.tabs,
    );
    return !constraints.isMobile ? tabs : Flexible(child: tabs);
  }

  Widget _buildSearchBar(BuildContext ctx, BoxConstraints constraints) {
    final searchBar = TTextField(
      placeholder: parent.widget.config.searchPlaceholder,
      theme: ctx.theme.textFieldTheme.copyWith(
        postWidget: Icon(Icons.search_rounded, size: 18, color: ctx.colors.onSurface),
        size: TInputSize.sm,
      ),
      onValueChanged: (String? input) {
        if (parent.currentTab == 0) {
          parent.listController.handleSearchChange(input ?? '');
        } else {
          parent.archiveListController.handleSearchChange(input ?? '');
        }
      },
    );
    return !constraints.isMobile ? SizedBox(width: 250, child: searchBar) : Flexible(child: searchBar);
  }
}

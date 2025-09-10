part of 'crud_table.dart';

class _TCrudTopBar<T, F extends TFormBase> {
  final _TCrudTableState<T, F> parent;

  _TCrudTopBar({required this.parent});

  Widget build(ColorScheme theme, BoxConstraints constraints) {
    final rows = <Widget>[];
    final maxWidth = constraints.maxWidth;
    final isMobile = maxWidth < 600;

    const spacing = 8.0;
    const rowSpacing = 12.0;
    const tabsWidth = 170.0;
    const searchWidth = 250.0;

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
    if (parent.hasArchive || currentRow.isNotEmpty) {
      final tabsAndSearchWidth = (parent.hasArchive ? tabsWidth + spacing : 0) + searchWidth;

      if (currentRow.isNotEmpty && currentRowWidth + spacing + tabsAndSearchWidth <= maxWidth) {
        // Same row
        currentRow.add(const Spacer());
        if (parent.hasArchive) {
          currentRow.add(_buildTabs(constraints));
          currentRow.add(const SizedBox(width: spacing));
        }
        currentRow.add(_buildSearchBar(theme, constraints));
        pushRow();
      } else {
        // Push actions row
        pushRow();

        if (tabsAndSearchWidth <= maxWidth) {
          // Tabs + Search in one row
          final tabSearchRow = <Widget>[
            if (parent.hasArchive) _buildTabs(constraints),
            if (parent.hasArchive) const SizedBox(width: spacing),
            _buildSearchBar(theme, constraints),
          ];
          rows.add(_buildAlignedRow(tabSearchRow, MainAxisAlignment.end));
        } else {
          // Stack them
          if (parent.hasArchive) {
            rows.add(_buildAlignedRow([_buildTabs(constraints)], MainAxisAlignment.center));
          }
          rows.add(_buildAlignedRow([_buildSearchBar(theme, constraints)], MainAxisAlignment.end));
        }
      }
    } else {
      pushRow();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows.expand((row) => [row, const SizedBox(height: rowSpacing)]).toList()..removeLast(),
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
    return isMobile && button is TButton ? Flexible(child: button.copyWith(block: true)) : button;
  }

  Widget _buildTabs(BoxConstraints constraints) {
    final tabs = TTabs(
      inline: constraints.maxWidth > 600,
      selectedIndex: parent.currentTab,
      onTabChanged: (i) => parent.currentTab = i,
      tabs: [
        TTab(text: parent.widget.config.activeTabText),
        TTab(text: parent.widget.config.archiveTabText),
      ],
    );
    return constraints.maxWidth > 600 ? tabs : Flexible(child: tabs);
  }

  Widget _buildSearchBar(ColorScheme theme, BoxConstraints constraints) {
    final searchBar = TTextField(
      placeholder: parent.widget.config.searchPlaceholder,
      postWidget: Icon(Icons.search_rounded, size: 18, color: theme.onSurface),
      size: TInputSize.sm,
      valueNotifier: parent.currentTab == 0 ? parent.searchNotifier : parent.archiveSearchNotifier,
    );
    return constraints.maxWidth > 600 ? SizedBox(width: 250, child: searchBar) : Flexible(child: searchBar);
  }
}

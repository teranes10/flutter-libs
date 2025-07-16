import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final List<T> items;
  final TTableDecoration decoration;
  final bool loading;

  const TTable({
    super.key,
    required this.headers,
    required this.items,
    this.decoration = const TTableDecoration(),
    this.loading = false,
  });

  @override
  State<TTable<T>> createState() => _TTableState<T>();
}

class _TTableState<T> extends State<TTable<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  bool _isCardView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.decoration.animationDuration,
    );
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCardView = widget.decoration.forceCardStyle || constraints.maxWidth <= widget.decoration.mobileBreakpoint;

        if (shouldShowCardView != _isCardView) {
          _isCardView = shouldShowCardView;
          _animationController.reset();
          _animationController.forward();
        }

        Widget child = _isCardView ? _buildCardView(theme) : _buildTableView(theme);

        // Calculate if we need horizontal scroll based on column widths
        bool needsHorizontalScroll = false;
        double totalRequiredWidth = 0;

        if (!_isCardView) {
          totalRequiredWidth = _calculateTotalRequiredWidth();
          needsHorizontalScroll = totalRequiredWidth > constraints.maxWidth;
        }

        if (widget.decoration.minWidth != null || widget.decoration.maxWidth != null) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.decoration.minWidth ?? 0,
              maxWidth: widget.decoration.maxWidth ?? double.infinity,
            ),
            child: child,
          );
        }

        // Apply horizontal scroll if needed and set minimum width
        if (!_isCardView &&
            (needsHorizontalScroll || (widget.decoration.minWidth != null && widget.decoration.minWidth! > constraints.maxWidth))) {
          // Ensure the table has enough width to display all columns properly
          final minTableWidth = totalRequiredWidth > 0 ? totalRequiredWidth : (widget.decoration.minWidth ?? constraints.maxWidth);

          child = SizedBox(
            width: minTableWidth,
            child: child,
          );

          child = _buildScrollableWrapper(child, isHorizontal: true);
        } else if (!_isCardView) {
          // When no horizontal scroll is needed, stretch to full available width
          child = SizedBox(
            width: constraints.maxWidth,
            child: child,
          );
        }

        return SizedBox(
          width: double.infinity,
          child: child,
        );
      },
    );
  }

  double _calculateTotalRequiredWidth() {
    double totalWidth = 0;

    for (final header in widget.headers) {
      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        totalWidth += header.maxWidth!;
      } else if (header.minWidth != null && header.minWidth! > 0) {
        totalWidth += header.minWidth!;
      } else {
        // For flex columns, assume a minimum reasonable width
        totalWidth += 100; // Default minimum width for flex columns
      }
    }

    // Add some padding for table margins/padding
    totalWidth += 32; // Account for horizontal padding

    return totalWidth;
  }

  Widget _buildTableView(ColorScheme theme) {
    final defaultPadding = widget.decoration.styling?.contentPadding ?? const EdgeInsets.only(bottom: 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTableHeader(theme),
        Padding(padding: defaultPadding, child: _buildTable(theme)),
        if (widget.items.isEmpty && !widget.loading) buildTableEmptyState(theme)
      ],
    );
  }

  Widget _buildTable(ColorScheme theme) {
    return SizedBox(
      width: double.infinity,
      child: TList<T>(
        items: widget.items,
        showAnimation: widget.decoration.showStaggeredAnimation,
        animationDuration: widget.decoration.animationDuration,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, item, index) {
          return _buildTableRowCard(theme, item, index);
        },
      ),
    );
  }

  Widget _buildTableRowCard(ColorScheme theme, T item, int index) {
    final rowStyle = widget.decoration.styling?.rowStyle ?? const TRowStyle();

    return TCard(
      margin: rowStyle.margin ?? const EdgeInsets.only(bottom: 8),
      elevation: rowStyle.elevation ?? 1,
      borderRadius: rowStyle.borderRadius ?? BorderRadius.circular(8),
      backgroundColor: rowStyle.backgroundColor ?? theme.surface,
      padding: rowStyle.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      boxShadow: [
        BoxShadow(
          color: theme.shadow,
          offset: const Offset(0, 1),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
      child: Table(
        columnWidths: _getColumnWidths(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: widget.headers.map((header) {
              Widget cellContent = _buildCellContent(theme, header, item);
              return Align(
                alignment: header.alignment ?? Alignment.centerLeft,
                child: cellContent,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView(ColorScheme theme) {
    if (widget.items.isEmpty && !widget.loading) {
      return buildTableEmptyState(theme);
    }

    Widget listView = TList<T>(
      items: widget.items,
      showAnimation: widget.decoration.showStaggeredAnimation,
      animationDuration: widget.decoration.animationDuration,
      shrinkWrap: widget.decoration.shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      padding: widget.decoration.styling?.contentPadding ?? const EdgeInsets.all(0),
      itemBuilder: (context, item, index) {
        return TTableCard<T>(
          item: item,
          headers: widget.headers,
          styling: widget.decoration.styling,
          width: widget.decoration.cardWidth,
        );
      },
    );

    return widget.decoration.showScrollbars && !widget.decoration.shrinkWrap ? _buildScrollableWrapper(listView) : listView;
  }

  Map<int, TableColumnWidth> _getColumnWidths() {
    Map<int, TableColumnWidth> columnWidths = {};

    // Count fixed width columns and calculate remaining space for flex columns
    // ignore: unused_local_variable
    int flexColumnCount = 0;

    for (final header in widget.headers) {
      if (header.maxWidth != null && header.maxWidth != double.infinity) {
      } else if (header.minWidth != null && header.minWidth! > 0) {
      } else {
        flexColumnCount++;
      }
    }

    for (int i = 0; i < widget.headers.length; i++) {
      final header = widget.headers[i];

      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        // Fixed width column
        columnWidths[i] = FixedColumnWidth(header.maxWidth!);
      } else if (header.minWidth != null && header.minWidth! > 0) {
        // Use FixedColumnWidth for minWidth to ensure it's respected
        columnWidths[i] = FixedColumnWidth(header.minWidth!);
      } else {
        // Flexible column - these will stretch to fill remaining space
        columnWidths[i] = FlexColumnWidth(header.flex?.toDouble() ?? 1.0);
      }
    }

    return columnWidths;
  }

  Widget _buildTableHeader(ColorScheme theme) {
    final headerStyle = widget.decoration.styling?.headerTextStyle ??
        TextStyle(
          fontSize: 13.6,
          fontWeight: FontWeight.w400,
          color: theme.onSurfaceVariant,
        );

    final defaultPadding = widget.decoration.styling?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Container(
      width: double.infinity, // Ensure header stretches full width
      padding: widget.decoration.styling?.headerPadding ?? EdgeInsets.symmetric(vertical: 12, horizontal: defaultPadding.horizontal),
      decoration: widget.decoration.styling?.headerDecoration,
      child: Table(
        columnWidths: _getColumnWidths(),
        children: [
          TableRow(
            children: widget.headers.map((header) {
              return Container(
                  constraints: BoxConstraints(minWidth: header.minWidth ?? 0, maxWidth: header.maxWidth ?? double.infinity),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(header.text, style: headerStyle, textAlign: header.alignment?.toTextAlign() ?? TextAlign.left),
                  ));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(ColorScheme theme, TTableHeader<T> header, T item) {
    if (header.builder != null) {
      return Builder(
        builder: (context) => header.builder!(context, item),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        header.getValue(item),
        style: widget.decoration.styling?.rowTextStyle ?? TextStyle(fontSize: 13.6, fontWeight: FontWeight.w300, color: theme.onSurface),
      ),
    );
  }

  Widget _buildScrollableWrapper(Widget child, {bool isHorizontal = false}) {
    if (isHorizontal) {
      return TScrollbar(
        controller: _horizontalScrollController,
        isHorizontal: true,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: child,
        ),
      );
    }

    return TScrollbar(
      controller: _verticalScrollController,
      thumbVisibility: widget.decoration.showScrollbars,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}

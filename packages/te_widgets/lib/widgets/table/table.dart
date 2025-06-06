import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/table/table_card.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';

class TTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final List<T> items;
  final double mobileBreakpoint;
  final double? cardWidth;
  final bool showStaggeredAnimation;
  final Duration animationDuration;
  final bool forceCardStyle;
  final TTableStyling? styling;
  final void Function(T item)? onItemTap;
  final bool shrinkWrap;
  final double? minWidth;
  final double? maxWidth;
  final bool showScrollbars;

  const TTable({
    super.key,
    required this.headers,
    required this.items,
    this.mobileBreakpoint = 768,
    this.cardWidth,
    this.showStaggeredAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.forceCardStyle = false,
    this.styling,
    this.onItemTap,
    this.shrinkWrap = true,
    this.minWidth,
    this.maxWidth,
    this.showScrollbars = true,
  });

  @override
  State<TTable<T>> createState() => _TTableState<T>();
}

class _TTableState<T> extends State<TTable<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isCardView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCardView = widget.forceCardStyle || constraints.maxWidth <= widget.mobileBreakpoint;

        if (shouldShowCardView != _isCardView) {
          _isCardView = shouldShowCardView;
          _animationController.reset();
          _animationController.forward();
        }

        Widget child = _isCardView ? _buildCardView() : _buildTableView();

        if (widget.minWidth != null || widget.maxWidth != null) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minWidth ?? 0,
              maxWidth: widget.maxWidth ?? double.infinity,
            ),
            child: child,
          );
        }

        if (!_isCardView && widget.minWidth != null && widget.minWidth! > constraints.maxWidth) {
          child = _buildScrollableWrapper(child, isHorizontal: true);
        }

        return SizedBox(
          width: double.infinity,
          child: child,
        );
      },
    );
  }

  Widget _buildCardView() {
    if (widget.items.isEmpty) {
      return tableEmptyState();
    }

    Widget listView;

    if (widget.shrinkWrap) {
      listView = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: widget.styling?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.items.length,
        itemBuilder: _buildCardItem,
      );
    } else {
      listView = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.styling?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.items.length,
        itemBuilder: _buildCardItem,
      );
    }

    return widget.showScrollbars && !widget.shrinkWrap ? _buildScrollableWrapper(listView) : listView;
  }

  Widget _buildCardItem(BuildContext context, int index) {
    return _buildAnimatedItem(
      index: index,
      child: TTableCard<T>(
        item: widget.items[index],
        headers: widget.headers,
        styling: widget.styling,
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(widget.items[index]) : null,
        width: widget.cardWidth,
      ),
    );
  }

  Widget _buildTableView() {
    if (widget.items.isEmpty) {
      return tableEmptyState();
    }

    Widget content;
    final defaultPadding = widget.styling?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    if (widget.shrinkWrap) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableHeader(),
          Padding(
            padding: defaultPadding,
            child: _buildTable(),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          Expanded(
            child: widget.showScrollbars
                ? _buildScrollableWrapper(
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: defaultPadding,
                      child: _buildTable(),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: defaultPadding,
                    child: _buildTable(),
                  ),
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildTable() {
    return Column(
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return _buildAnimatedTableRow(index, item);
      }).toList(),
    );
  }

  Widget _buildAnimatedTableRow(int index, T item) {
    final rowStyle = widget.styling?.rowStyle ?? const TRowStyle();

    // Create the entire row as a single card
    Widget rowCard = Container(
      margin: rowStyle.margin ?? const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: rowStyle.elevation ?? 1,
        borderRadius: rowStyle.borderRadius ?? BorderRadius.circular(8),
        color: rowStyle.backgroundColor ?? Colors.white,
        child: InkWell(
          onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
          borderRadius: rowStyle.borderRadius ?? BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.shade50,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: rowStyle.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Table(
              columnWidths: _getColumnWidths(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: widget.headers.map((header) {
                    Widget cellContent = _buildCellContent(header, item);

                    // Apply alignment
                    return Align(
                      alignment: header.alignment ?? Alignment.centerLeft,
                      child: cellContent,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Apply animation to the entire row card
    return _buildAnimatedItem(
      index: index,
      child: rowCard,
    );
  }

  Map<int, TableColumnWidth> _getColumnWidths() {
    Map<int, TableColumnWidth> columnWidths = {};

    for (int i = 0; i < widget.headers.length; i++) {
      final header = widget.headers[i];

      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        // Fixed width column
        columnWidths[i] = FixedColumnWidth(header.maxWidth!);
      } else if (header.minWidth != null && header.minWidth! > 0) {
        // Minimum width with flex behavior
        columnWidths[i] = MinColumnWidth(
          FixedColumnWidth(header.minWidth!),
          FlexColumnWidth(header.flex?.toDouble() ?? 1.0),
        );
      } else {
        // Flexible column
        columnWidths[i] = FlexColumnWidth(header.flex?.toDouble() ?? 1.0);
      }
    }

    return columnWidths;
  }

  Widget _buildTableHeader() {
    final headerStyle = widget.styling?.headerTextStyle ??
        TextStyle(
          fontSize: 13.6,
          fontWeight: FontWeight.w400,
          color: AppColors.grey[500],
        );

    final defaultPadding = widget.styling?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return Container(
      padding: widget.styling?.headerPadding ??
          EdgeInsets.symmetric(
            vertical: 12,
            horizontal: defaultPadding.horizontal,
          ),
      decoration: widget.styling?.headerDecoration,
      child: Table(
        columnWidths: _getColumnWidths(),
        children: [
          TableRow(
            children: widget.headers.map((header) {
              return Container(
                constraints: BoxConstraints(
                  minWidth: header.minWidth ?? 0,
                  maxWidth: header.maxWidth ?? double.infinity,
                ),
                child: Text(
                  header.text,
                  style: headerStyle,
                  textAlign: header.alignment?.toTextAlign() ?? TextAlign.left,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(TTableHeader<T> header, T item) {
    if (header.builder != null) {
      return Builder(
        builder: (context) => header.builder!(context, item),
      );
    }

    return Text(
      header.getValue(item),
      style: widget.styling?.rowTextStyle ??
          TextStyle(
            fontSize: 13.6,
            fontWeight: FontWeight.w300,
            color: AppColors.grey[600],
          ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    if (!widget.showStaggeredAnimation) {
      return child;
    }

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        (0.05 * index).clamp(0.0, 0.3),
        (0.3 + (0.05 * index)).clamp(0.3, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - animation.value) * 50, 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildScrollableWrapper(Widget child, {bool isHorizontal = false}) {
    if (isHorizontal) {
      return Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.bottom,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      );
    }

    return Scrollbar(
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'table_layout_calculator.dart';
part 'table_header_builder.dart';
part 'table_row_builder.dart';
part 'table_card.dart';
part 'table_controller.dart';

class TTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final List<T> items;
  final TTableDecoration decoration;
  final bool loading;
  final TTableController<T>? controller;
  final TTableInteractionConfig interactionConfig;

  // Expandable configuration
  final bool expandable;
  final bool singleExpand;
  final Widget Function(T item, int index, bool isExpanded)? expandedBuilder;

  // Selectable configuration
  final bool selectable;
  final bool singleSelect;

  const TTable({
    super.key,
    required this.headers,
    required this.items,
    this.decoration = const TTableDecoration(),
    this.loading = false,
    this.controller,
    this.interactionConfig = const TTableInteractionConfig(),
    // Expandable
    this.expandable = false,
    this.singleExpand = true,
    this.expandedBuilder,

    // Selectable
    this.selectable = false,
    this.singleSelect = false,
  });

  @override
  State<TTable<T>> createState() => _TTableState<T>();
}

class _TTableState<T> extends State<TTable<T>> with SingleTickerProviderStateMixin {
  TTableController<T>? _controller;
  late TTableLayoutCalculator<T> _layoutCalculator;
  late TTableRowBuilder<T> _rowBuilder;
  late TTableHeaderBuilder<T> _headerBuilder;
  late ScrollController _horizontalScrollController;

  bool _isCardView = false;
  bool _needsHorizontalScroll = false;

  @override
  void initState() {
    super.initState();

    if (widget.selectable || widget.expandable) {
      _controller = widget.controller ?? TTableController<T>();
      _controller?._attach(widget);
    }

    _layoutCalculator = TTableLayoutCalculator<T>(widget: widget);
    _rowBuilder = TTableRowBuilder<T>(widget: widget, controller: _controller);
    _headerBuilder = TTableHeaderBuilder<T>(widget: widget, controller: _controller);
    _horizontalScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(TTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller?._update(widget);
    _layoutCalculator._updateWidget(widget);
    _rowBuilder._updateWidget(widget);
    _headerBuilder._updateWidget(widget);
  }

  @override
  void dispose() {
    _controller?._detach(widget);
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCardView = widget.decoration.forceCardStyle || constraints.maxWidth <= widget.decoration.mobileBreakpoint;

        _needsHorizontalScroll = _layoutCalculator._needsHorizontalScroll(constraints);

        if (shouldShowCardView != _isCardView) {
          _isCardView = shouldShowCardView;
        }

        Widget child = _isCardView ? _buildCardView(theme, constraints) : _buildTableView(theme, constraints);

        return _layoutCalculator._applyConstraints(child, constraints);
      },
    );
  }

  Widget _buildTableView(ColorScheme theme, BoxConstraints constraints) {
    Widget tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerBuilder._build(theme),
        _buildTable(theme),
        if (widget.items.isEmpty && !widget.loading) buildTableEmptyState(theme),
      ],
    );

    if (_needsHorizontalScroll) {
      tableContent = SizedBox(
        width: _layoutCalculator._calculateTotalRequiredWidth(),
        child: tableContent,
      );

      return TScrollbar(
        controller: _horizontalScrollController,
        isHorizontal: true,
        thumbVisibility: widget.decoration.showScrollbars,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: tableContent,
        ),
      );
    } else {
      return SizedBox(width: constraints.maxWidth, child: tableContent);
    }
  }

  Widget _buildTable(ColorScheme theme) {
    return SizedBox(
      width: double.infinity,
      child: _controller != null
          ? ValueListenableBuilder<Set<int>>(
              valueListenable: _controller!.expanded,
              builder: (context, expandedSet, _) {
                return ValueListenableBuilder<Set<int>>(
                  valueListenable: _controller!.selected,
                  builder: (context, selectedSet, _) {
                    return _buildTList(theme, expandedSet, selectedSet);
                  },
                );
              },
            )
          : _buildTList(theme, const {}, const {}),
    );
  }

  Widget _buildTList(ColorScheme theme, Set<int> expandedSet, Set<int> selectedSet) {
    return TList<T>(
      items: widget.items,
      showAnimation: widget.decoration.showStaggeredAnimation,
      animationDuration: widget.decoration.animationDuration,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, item, index) {
        return _rowBuilder._buildTableRow(
            theme, widget.decoration.style.rowStyle, item, index, expandedSet.contains(index), selectedSet.contains(index));
      },
    );
  }

  Widget _buildCardView(ColorScheme theme, BoxConstraints constraints) {
    if (widget.items.isEmpty && !widget.loading) {
      return buildTableEmptyState(theme);
    }

    if (_controller != null) {
      return ValueListenableBuilder<Set<int>>(
        valueListenable: _controller!.expanded,
        builder: (context, expandedSet, _) {
          return ValueListenableBuilder<Set<int>>(
            valueListenable: _controller!.selected,
            builder: (context, selectedSet, _) {
              return _buildCardList(theme, expandedSet, selectedSet);
            },
          );
        },
      );
    } else {
      return _buildCardList(theme, const {}, const {});
    }
  }

  Widget _buildCardList(ColorScheme theme, Set<int> expandedSet, Set<int> selectedSet) {
    return TList<T>(
      items: widget.items,
      showAnimation: widget.decoration.showStaggeredAnimation,
      animationDuration: widget.decoration.animationDuration,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, item, index) {
        return _rowBuilder._buildCardRow(
          theme,
          item,
          index,
          expandedSet.contains(index),
          selectedSet.contains(index),
        );
      },
    );
  }

  Widget buildTableEmptyState(ColorScheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: theme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No data available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: theme.onSurface)),
            const SizedBox(height: 8),
            Text('There are no items to display at the moment.',
                style: TextStyle(fontSize: 14, color: theme.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

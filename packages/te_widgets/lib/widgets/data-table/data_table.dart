import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDataTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final List<T>? items;
  final ItemKey<T>? itemKey;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;
  final String? search;
  final int searchDelay;
  final bool loading;
  final DataTableOnLoadListener<T>? onLoad;

  // Table styling properties
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

  const TDataTable({
    super.key,
    required this.headers,
    this.items,
    this.itemKey,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.search,
    this.searchDelay = 300,
    this.loading = false,
    this.onLoad,
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
  State<TDataTable<T>> createState() => _TDataTableState<T>();
}

class _TDataTableState<T> extends State<TDataTable<T>> {
  late List<TTableHeader<T>> _headers;
  late List<T> _items;
  late int _currentPage;
  late int _itemsPerPage;
  late bool _loading;
  late bool _serverSideRendering;

  List<T> _displayItems = [];
  int _totalItems = 0;

  int get _totalPages => (_totalItems / _itemsPerPage).ceil();

  int get _computedItemsPerPage => _totalItems < _itemsPerPage ? _displayItems.length : _itemsPerPage;

  List<int> get _computedItemsPerPageOptions {
    final options = <int>{
      _computedItemsPerPage,
      _totalItems,
      ...List.from(widget.itemsPerPageOptions),
    };

    return options.where((x) => x <= _totalItems).toList()..sort();
  }

  int get _pageStartAt => ((_currentPage - 1) * _itemsPerPage) + 1;

  int get _pageEndAt => (_currentPage * _itemsPerPage).clamp(0, _totalItems);

  String get _paginationInfo {
    if (_totalItems == 0) return 'No entries';
    return 'Showing $_pageStartAt to $_pageEndAt of $_totalItems entries';
  }

  @override
  void initState() {
    super.initState();
    _headers = List.from(widget.headers);
    _items = List.from(widget.items ?? []);
    _currentPage = 1;
    _itemsPerPage = widget.itemsPerPage;
    _loading = widget.loading;
    _serverSideRendering = widget.onLoad != null;

    _loadData();
  }

  @override
  void didUpdateWidget(TDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items ?? []);
      _loadData();
    }

    if (oldWidget.headers != widget.headers) {
      _headers = List.from(widget.headers);
    }

    if (oldWidget.loading != widget.loading) {
      _loading = widget.loading;
    }
  }

  void _loadData() {
    if (_serverSideRendering) {
      _loading = true;
      _loadDataFromServer((items, totalItems) {
        _totalItems = totalItems;
        _displayItems = items;
        setState(() {
          _loading = false;
        });
      });
    } else {
      _totalItems = _items.length;
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = (startIndex + _itemsPerPage).clamp(0, _items.length);
      _displayItems = _items.sublist(startIndex, endIndex);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    _loadData();
  }

  void _onItemsPerPageChanged(int itemsPerPage) {
    setState(() {
      _itemsPerPage = itemsPerPage;
      _currentPage = 1;
    });

    _loadData();
  }

  void _loadDataFromServer(Function(List<T>, int) callback) {
    final options = DataTableLoadOptions<T>(
      page: _currentPage,
      itemsPerPage: _itemsPerPage,
      search: widget.search,
      callback: callback,
    );

    widget.onLoad?.call(options);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Loading indicator
        if (_loading)
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

        // Table
        TTable<T>(
          headers: _headers,
          items: _displayItems,
          mobileBreakpoint: widget.mobileBreakpoint,
          cardWidth: widget.cardWidth,
          showStaggeredAnimation: widget.showStaggeredAnimation,
          animationDuration: widget.animationDuration,
          forceCardStyle: widget.forceCardStyle,
          styling: widget.styling,
          onItemTap: widget.onItemTap,
          shrinkWrap: widget.shrinkWrap,
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
          showScrollbars: widget.showScrollbars,
        ),

        // Toolbar with pagination and controls
        if (_totalItems > 0) ...[
          const SizedBox(height: 16),
          _buildToolbar(),
        ],
      ],
    );
  }

  Widget _buildToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Column(
            children: [
              TPagination(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: _onPageChanged,
              ),
              const SizedBox(height: 12),
              _buildInfoContainer(),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TPagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: _onPageChanged,
            ),
            _buildInfoContainer(),
          ],
        );
      },
    );
  }

  Widget _buildInfoContainer() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _paginationInfo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: AppColors.grey[500],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: TSelect(
            size: TInputSize.sm,
            value: _computedItemsPerPage,
            items: _computedItemsPerPageOptions,
            onValueChanged: (value) {
              _onItemsPerPageChanged(value);
            },
          ),
        ),
      ],
    );
  }
}

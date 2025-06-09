import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/pagination/pagination.dart';
import 'package:te_widgets/widgets/select/select.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/table/table.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';
import 'data_table_config.dart';

class TDataTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final List<T> items;
  final ItemKey<T>? itemKey;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;
  final String? search;
  final bool serverSideRendering;
  final int searchDelay;
  final Map<String, dynamic>? params;
  final bool loading;
  final DataTableOnLoadListener<T>? onLoad;
  final DataTableInitializeCallback<T>? onInitialize;

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
    required this.items,
    this.itemKey,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.search,
    this.serverSideRendering = false,
    this.searchDelay = 300,
    this.params,
    this.loading = false,
    this.onLoad,
    this.onInitialize,
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
  late List<T> _displayItems;
  late int _currentPage;
  late int _itemsPerPage;
  late bool _loading;
  late bool _serverSideRendering;

  int _totalItems = 0;
  DataTableOnLoadListener<T>? _loadCallback;

  @override
  void initState() {
    super.initState();
    _headers = List.from(widget.headers);
    _items = List.from(widget.items);
    _currentPage = 1;
    _itemsPerPage = widget.itemsPerPage;
    _loading = widget.loading;
    _serverSideRendering = widget.serverSideRendering;

    if (widget.onLoad != null) {
      _serverSideRendering = true;
    }

    _updateDisplayItems();
    _initializeContext();
  }

  @override
  void didUpdateWidget(TDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
      _updateDisplayItems();
    }

    if (oldWidget.headers != widget.headers) {
      _headers = List.from(widget.headers);
    }

    if (oldWidget.loading != widget.loading) {
      _loading = widget.loading;
    }
  }

  void _initializeContext() {
    final context = DataTableContext<T>(
      isServerSideRendering: () => _serverSideRendering,
      setHeaders: (headers) => setState(() => _headers = headers),
      setOnLoadListener: (callback) {
        _loadCallback = callback;
        setState(() => _serverSideRendering = true);
      },
      getItems: () => _serverSideRendering ? _displayItems : _items,
      setItems: (items) => setState(() {
        _items = items;
        _updateDisplayItems();
      }),
      addItem: (item) => setState(() {
        if (_serverSideRendering) {
          _displayItems.insert(0, item);
          _totalItems++;
        } else {
          _items.insert(0, item);
          _updateDisplayItems();
        }
      }),
      updateItem: (index, item) => setState(() {
        if (_serverSideRendering) {
          if (index >= 0 && index < _displayItems.length) {
            _displayItems[index] = item;
          }
        } else {
          if (index >= 0 && index < _items.length) {
            _items[index] = item;
            _updateDisplayItems();
          }
        }
      }),
      removeItem: (index) => setState(() {
        if (_serverSideRendering) {
          if (index >= 0 && index < _displayItems.length) {
            _displayItems.removeAt(index);
            _totalItems--;
          }
        } else {
          if (index >= 0 && index < _items.length) {
            _items.removeAt(index);
            _updateDisplayItems();
          }
        }
      }),
      notifyDataSetChanged: () => _updateDisplayItems(),
      setLoading: (loading) => setState(() => _loading = loading),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInitialize?.call(context);
    });
  }

  void _updateDisplayItems() {
    if (_serverSideRendering) {
      _totalItems = _items.length;
      _displayItems = List.from(_items);
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

    if (_serverSideRendering) {
      _loadData();
    } else {
      _updateDisplayItems();
    }
  }

  void _onItemsPerPageChanged(int itemsPerPage) {
    setState(() {
      _itemsPerPage = itemsPerPage;
      _currentPage = 1;
    });

    if (_serverSideRendering) {
      _loadData();
    } else {
      _updateDisplayItems();
    }
  }

  void _loadData() {
    final options = DataTableLoadOptions<T>(
      page: _currentPage,
      itemsPerPage: _itemsPerPage,
      search: widget.search,
      params: widget.params,
    );

    widget.onLoad?.call(options);
    _loadCallback?.call(options);
  }

  int get _totalPages => (_totalItems / _itemsPerPage).ceil();

  String get _paginationInfo {
    if (_totalItems == 0) return 'No entries';

    final start = ((_currentPage - 1) * _itemsPerPage) + 1;
    final end = (_currentPage * _itemsPerPage).clamp(0, _totalItems);
    return 'Showing $start to $end of $_totalItems entries';
  }

  List<int> get _availableItemsPerPageOptions {
    final options = Set<int>.from(widget.itemsPerPageOptions);
    options.add(_itemsPerPage);
    final remainingItems = _totalItems - ((_currentPage - 1) * _itemsPerPage);
    return options.where((option) => option <= remainingItems || option == _itemsPerPage).toList()..sort();
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
          child: TSelect<int>(
            value: _itemsPerPage,
            items: _availableItemsPerPageOptions
                .map((item) => TSimpleSelectItem<int>(
                      text: item.toString(),
                      value: item,
                      key: item.toString(),
                    ))
                .toList(),
            onValueChanged: (value) {
              if (value != null) {
                _onItemsPerPageChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}

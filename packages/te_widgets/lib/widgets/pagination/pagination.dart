import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TPagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int totalVisible;
  final ValueChanged<int> onPageChanged;

  const TPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalVisible = 9,
    required this.onPageChanged,
  }) : assert(totalVisible % 2 == 1, 'totalVisible must be an odd number');

  @override
  State<TPagination> createState() => _PaginationState();
}

class _PaginationState extends State<TPagination> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
  }

  @override
  void didUpdateWidget(TPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _currentPage = widget.currentPage;
    }
  }

  List<dynamic> get _visiblePages {
    int startPage = 1;
    int endPage = widget.totalPages;

    if (widget.totalPages > widget.totalVisible) {
      final half = widget.totalVisible ~/ 2;
      if (_currentPage <= half) {
        endPage = widget.totalVisible;
      } else if (_currentPage + half >= widget.totalPages) {
        startPage = widget.totalPages - widget.totalVisible + 1;
      } else {
        startPage = _currentPage - half;
        endPage = _currentPage + half;
      }

      if (startPage > 1) {
        startPage += 2;
      }

      if (endPage < widget.totalPages) {
        endPage -= 2;
      }
    }

    final pages = <dynamic>[];

    if (startPage > 1) {
      pages.addAll([1, '...']);
    }

    for (int i = startPage; i <= endPage; i++) {
      pages.add(i);
    }

    if (endPage < widget.totalPages) {
      pages.addAll(['...', widget.totalPages]);
    }

    return pages.isNotEmpty ? pages : [1];
  }

  bool get _hasFirstPage => _currentPage > 1;
  bool get _hasLastPage => _currentPage < widget.totalPages;
  bool get _hasNextPage => _currentPage < widget.totalPages;
  bool get _hasPreviousPage => _currentPage > 1;

  void _gotoFirstPage() {
    _updatePage(1);
  }

  void _gotoLastPage() {
    _updatePage(widget.totalPages);
  }

  void _gotoPage(int pageNumber) {
    _updatePage(pageNumber);
  }

  void _gotoNextPage() {
    _updatePage(_currentPage + 1);
  }

  void _gotoPreviousPage() {
    _updatePage(_currentPage - 1);
  }

  void _updatePage(int newPage) {
    if (newPage != _currentPage && newPage >= 1 && newPage <= widget.totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      widget.onPageChanged(newPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // First page button
        _PaginationIconButton(
          icon: Icons.first_page,
          isEnabled: _hasFirstPage,
          onPressed: _gotoFirstPage,
        ),
        // Previous page button
        _PaginationIconButton(
          icon: Icons.chevron_left,
          isEnabled: _hasPreviousPage,
          onPressed: _gotoPreviousPage,
        ),
        // Page numbers
        ..._visiblePages.map((page) {
          if (page == '...') {
            return const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('...'));
          } else {
            return _PaginationNumberButton(number: page, isActive: page == _currentPage, onPressed: () => _gotoPage(page));
          }
        }),
        // Next page button
        _PaginationIconButton(
          icon: Icons.chevron_right,
          isEnabled: _hasNextPage,
          onPressed: _gotoNextPage,
        ),
        // Last page button
        _PaginationIconButton(
          icon: Icons.last_page,
          isEnabled: _hasLastPage,
          onPressed: _gotoLastPage,
        ),
      ],
    );
  }
}

class _PaginationIconButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _PaginationIconButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: isEnabled ? onPressed : null,
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
    );
  }
}

class _PaginationNumberButton extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onPressed;

  const _PaginationNumberButton({
    required this.number,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: isActive ? BorderSide(color: colors.onPrimaryContainer.withAlpha(100)) : BorderSide.none,
      ),
      color: isActive ? colors.primaryContainer : colors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            child: Padding(
              padding: EdgeInsets.all(7.5),
              child: Center(
                  child: Text(number.toString(),
                      style: TextStyle(
                        fontSize: 13.6,
                        fontWeight: FontWeight.normal,
                        color: isActive ? colors.onPrimaryContainer : colors.onSurface,
                      ))),
            ),
          ),
        ),
      ),
    );
  }
}

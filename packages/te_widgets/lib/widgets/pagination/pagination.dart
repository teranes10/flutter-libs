import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// A pagination component for navigating through pages.
///
/// `TPagination` provides navigation controls with:
/// - First/last page buttons
/// - Previous/next page buttons
/// - Numbered page buttons
/// - Sliding window of pages around the current one (stable width)
/// - Tap the ellipsis to jump to any page
/// - Animated active-page highlight, tooltips and keyboard (arrow/Home/End) support
///
/// ## Basic Usage
///
/// ```dart
/// TPagination(
///   currentPage: 1,
///   totalPages: 10,
///   onPageChanged: (page) => print('Page: $page'),
/// )
/// ```
///
/// ## With Custom Visible Pages
///
/// ```dart
/// TPagination(
///   currentPage: currentPage,
///   totalPages: totalPages,
///   totalVisible: 7,  // Must be odd
///   onPageChanged: (page) {
///     setState(() => currentPage = page);
///     loadData(page);
///   },
/// )
/// ```
///
/// See also:
/// - [TDataTable] which uses pagination
class TPagination extends StatefulWidget {
  /// The current active page (1-indexed).
  final int currentPage;

  /// The total number of pages.
  final int totalPages;

  /// Number of page slots to show (must be odd, minimum 5).
  ///
  /// Defaults to 9.
  final int totalVisible;

  /// Callback fired when a page is selected.
  final ValueChanged<int> onPageChanged;

  /// Creates a pagination component.
  const TPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalVisible = 9,
    required this.onPageChanged,
  }) : assert(totalVisible % 2 == 1 && totalVisible >= 5, 'totalVisible must be an odd number >= 5');

  @override
  State<TPagination> createState() => _PaginationState();
}

class _PaginationState extends State<TPagination> {
  static const double _slot = 36;
  static const double _gap = 4;
  static const double _radius = 6;

  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
  }

  @override
  void didUpdateWidget(TPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) _currentPage = widget.currentPage;
  }

  /// Page numbers; `null` marks an ellipsis. Length is stable once totalPages > totalVisible.
  List<int?> get _items {
    final total = widget.totalPages;
    final slots = widget.totalVisible;
    if (total <= slots) return [for (var i = 1; i <= total; i++) i];

    final half = (slots - 4) ~/ 2;
    if (_currentPage <= half + 3) {
      return [for (var i = 1; i <= slots - 2; i++) i, null, total];
    }
    if (_currentPage >= total - half - 2) {
      return [1, null, for (var i = total - slots + 3; i <= total; i++) i];
    }
    return [1, null, for (var i = _currentPage - half; i <= _currentPage + half; i++) i, null, total];
  }

  void _goto(int page) {
    final p = page.clamp(1, widget.totalPages);
    if (p != _currentPage) {
      setState(() => _currentPage = p);
      widget.onPageChanged(p);
    }
  }

  void _promptPage() {
    TAlertService.prompt(
      context,
      title: 'Go to page',
      placeholder: '1 - ${widget.totalPages}',
      confirmButtonText: 'Go',
      width: 360,
      onConfirm: (v) {
        final page = int.tryParse(v.trim());
        if (page != null) _goto(page);
      },
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowLeft) {
      _goto(_currentPage - 1);
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _goto(_currentPage + 1);
    } else if (k == LogicalKeyboardKey.home) {
      _goto(1);
    } else if (k == LogicalKeyboardKey.end) {
      _goto(widget.totalPages);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = _items;
    final hasPrev = _currentPage > 1;
    final hasNext = _currentPage < widget.totalPages;
    final activeIndex = items.indexOf(_currentPage);

    final numbers = SizedBox(
      width: items.length * _slot + (items.length - 1) * _gap,
      height: _slot,
      child: Stack(
        children: [
          if (activeIndex >= 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              left: activeIndex * (_slot + _gap),
              width: _slot,
              top: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(_radius),
                ),
              ),
            ),
          for (var i = 0; i < items.length; i++)
            Positioned(
              left: i * (_slot + _gap),
              width: _slot,
              top: 0,
              bottom: 0,
              child: items[i] == null
                  ? _Cell(
                      tooltip: 'Jump to page',
                      onTap: _promptPage,
                      child: Text('…', style: TextStyle(color: colors.onSurface.withAlpha(150))),
                    )
                  : _Cell(
                      tooltip: 'Page ${items[i]}',
                      selected: items[i] == _currentPage,
                      onTap: () => _goto(items[i]!),
                      child: Text(
                        '${items[i]}',
                        style: TextStyle(
                          fontSize: 13.6,
                          fontWeight: items[i] == _currentPage ? FontWeight.w600 : FontWeight.normal,
                          color: items[i] == _currentPage ? colors.onPrimary : colors.onSurface,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );

    return Focus(
      onKeyEvent: _onKey,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap,
          children: [
            _ArrowButton(_Arrow(HugeIcons.strokeRoundedArrowLeftDouble, 'First page', hasPrev, () => _goto(1))),
            _ArrowButton(_Arrow(HugeIcons.strokeRoundedArrowLeft01, 'Previous page', hasPrev, () => _goto(_currentPage - 1))),
            numbers,
            _ArrowButton(_Arrow(HugeIcons.strokeRoundedArrowRight01, 'Next page', hasNext, () => _goto(_currentPage + 1))),
            _ArrowButton(_Arrow(HugeIcons.strokeRoundedArrowRightDouble, 'Last page', hasNext, () => _goto(widget.totalPages))),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;

  const _Cell({required this.child, required this.tooltip, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tooltip,
      excludeSemantics: true,
      child: TTooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(_PaginationState._radius),
          onTap: onTap,
          child: Center(
            child: DefaultTextStyle.merge(
              style: const TextStyle(height: 1),
              textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false, applyHeightToLastDescent: false, leadingDistribution: TextLeadingDistribution.even),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Arrow {
  final dynamic icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;
  const _Arrow(this.icon, this.tooltip, this.enabled, this.onTap);
}

/// Plain arrow button, same footprint and look as an inactive page number.
class _ArrowButton extends StatelessWidget {
  final _Arrow arrow;
  const _ArrowButton(this.arrow);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: arrow.enabled ? 1 : 0.35,
      child: SizedBox(
        width: _PaginationState._slot,
        height: _PaginationState._slot,
        child: TTooltip(
          message: arrow.tooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(_PaginationState._radius),
            onTap: arrow.enabled ? arrow.onTap : null,
            mouseCursor: arrow.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            child: Center(child: HugeIcon(icon: arrow.icon, size: 20, color: context.colors.onSurface)),
          ),
        ),
      ),
    );
  }
}

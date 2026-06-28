import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'tab_renderer.dart';

class TTabs<T> extends StatefulWidget {
  final List<TTab<T>> tabs;
  final TTabController<T>? controller;
  final T? selectedValue;
  final ValueChanged<T>? onTabChanged;
  final Color? borderColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? disabledColor;
  final Color? indicatorColor;
  final EdgeInsets? tabPadding;
  final double tabSpacing;
  final double tabRunSpacing;
  final double? indicatorWidth;
  final bool inline;
  final Axis axis;
  final bool scrollable;
  final bool showNavigationButtons;
  final bool wrap;
  final Widget Function(BuildContext, TTab<T>, bool, VoidCallback?)? tabBuilder;
  final Color? navigationButtonColor;
  final Color? navigationButtonBackgroundColor;

  const TTabs({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedValue,
    this.onTabChanged,
    this.borderColor,
    this.selectedColor,
    this.unselectedColor,
    this.disabledColor,
    this.indicatorColor,
    this.tabPadding,
    this.tabSpacing = 2,
    this.tabRunSpacing = 2,
    this.indicatorWidth = 1,
    this.inline = false,
    this.axis = Axis.horizontal,
    this.scrollable = false,
    this.showNavigationButtons = true,
    this.wrap = false,
    this.tabBuilder,
    this.navigationButtonColor,
    this.navigationButtonBackgroundColor,
  }) : assert(!wrap || !scrollable, 'Wrap and scrollable are mutually exclusive');

  @override
  State<TTabs<T>> createState() => _TTabsState<T>();
}

class _TTabsState<T> extends State<TTabs<T>> {
  final ScrollController _scrollController = ScrollController();
  // One key per tab — used only for ensureVisible, not for width measurement.
  final Map<T, GlobalKey> _tabKeys = {};

  bool _canScrollStart = false;
  bool _canScrollEnd = false;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    _scrollController.addListener(_updateScrollButtons);
    widget.controller?.addListener(_onControllerChanged);
    if (widget.scrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollButtons();
        _scrollToSelected();
      });
    }
  }

  @override
  void didUpdateWidget(TTabs<T> old) {
    super.didUpdateWidget(old);

    if (old.tabs != widget.tabs) _syncKeys();

    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }

    // Scroll to newly-selected tab whenever selection changes.
    final oldSel = old.controller?.value ?? old.selectedValue;
    final newSel = widget.controller?.value ?? widget.selectedValue;
    if (newSel != oldSel && widget.scrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _syncKeys() {
    // Preserve existing keys so GlobalKey identity is stable across rebuilds.
    final next = <T, GlobalKey>{};
    for (final tab in widget.tabs) {
      next[tab.value] = _tabKeys[tab.value] ?? GlobalKey();
    }
    _tabKeys
      ..clear()
      ..addAll(next);
  }

  void _onControllerChanged() {
    setState(() {});
    if (widget.scrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _updateScrollButtons() {
    if (!mounted || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    setState(() {
      _canScrollStart = pos.pixels > pos.minScrollExtent;
      _canScrollEnd = pos.pixels < pos.maxScrollExtent;
    });
  }

  /// The only scroll-to-tab logic you need.
  /// Scrollable.ensureVisible handles coordinate space, padding, and clamping.
  void _scrollToSelected() {
    final sel = widget.controller?.value ?? widget.selectedValue;
    if (sel == null) return;
    final key = _tabKeys[sel];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSelectTab(TTab<T> tab) {
    widget.controller?.selectTab(tab.value);
    widget.onTabChanged?.call(tab.value);
  }

  Widget _buildTab(BuildContext context, TTab<T> tab, ColorScheme colors, bool inline) {
    final sel = widget.controller?.value ?? widget.selectedValue;
    final isSelected = sel == tab.value;
    final key = _tabKeys[tab.value]!;
    final onTap = tab.isEnabled ? () => _onSelectTab(tab) : null;

    if (widget.tabBuilder != null) {
      return KeyedSubtree(
        key: key,
        child: widget.tabBuilder!(context, tab, isSelected, onTap),
      );
    }

    final tabWidget = TabRenderer.buildDefaultTab<T>(
      context: context,
      tab: tab,
      isSelected: isSelected,
      colors: colors,
      tabKey: key,
      axis: widget.axis,
      tabPadding: widget.tabPadding,
      indicatorWidth: widget.indicatorWidth,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
      disabledColor: widget.disabledColor,
      indicatorColor: widget.indicatorColor,
      controller: widget.controller,
      onTab: onTap,
    );

    // Only Expanded in true full-width horizontal mode.
    final fullWidth = !inline && !widget.scrollable && !widget.wrap;
    return fullWidth && widget.axis == Axis.horizontal ? Expanded(child: tabWidget) : tabWidget;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isExpandedByParent = constraints.hasBoundedWidth && constraints.minWidth == constraints.maxWidth;
      final effectiveInline = isExpandedByParent ? false : widget.inline;
      final colors = context.colors;
      final borderColor = widget.borderColor ?? Colors.transparent;
      final navColor = widget.navigationButtonColor ?? colors.onSurface;
      final navBg = widget.navigationButtonBackgroundColor ?? colors.surface.o(0.9);

      final tabWidgets = [
        for (final tab in widget.tabs) _buildTab(context, tab, colors, effectiveInline),
      ];

      Widget body;

      if (widget.scrollable) {
        Widget scrollView = SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: widget.axis,
          child: widget.axis == Axis.horizontal
              ? Row(spacing: widget.tabSpacing, children: tabWidgets)
              : Column(spacing: widget.tabSpacing, children: tabWidgets),
        );

        if (widget.showNavigationButtons && context.isDesktopPlatform) {
          body = widget.axis == Axis.horizontal
              ? Row(children: [
                  if (_canScrollStart) _NavBtn(icon: Icons.chevron_left, onPressed: () => _scrollBy(-200), color: navColor, bg: navBg),
                  Expanded(child: scrollView),
                  if (_canScrollEnd) _NavBtn(icon: Icons.chevron_right, onPressed: () => _scrollBy(200), color: navColor, bg: navBg),
                ])
              : Column(children: [
                  if (_canScrollStart) _NavBtn(icon: Icons.keyboard_arrow_up, onPressed: () => _scrollBy(-200), color: navColor, bg: navBg),
                  Expanded(child: scrollView),
                  if (_canScrollEnd) _NavBtn(icon: Icons.keyboard_arrow_down, onPressed: () => _scrollBy(200), color: navColor, bg: navBg),
                ]);
        } else {
          body = scrollView;
        }
      } else if (widget.wrap && effectiveInline) {
        body = Wrap(
          direction: widget.axis,
          spacing: widget.tabSpacing,
          runSpacing: widget.tabRunSpacing,
          children: tabWidgets,
        );
      } else if (effectiveInline) {
        body = widget.axis == Axis.horizontal
            ? Row(mainAxisSize: MainAxisSize.min, spacing: widget.tabSpacing, children: tabWidgets)
            : Column(mainAxisSize: MainAxisSize.min, spacing: widget.tabSpacing, children: tabWidgets);
      } else {
        // Full-width
        body = widget.axis == Axis.horizontal
            ? TAlignedRow(
                spacing: widget.tabSpacing,
                left: tabWidgets,
                wrapperModeThreshold: 0,
                wrapperExpanded: true,
              )
            : IntrinsicHeight(child: Column(spacing: widget.tabSpacing, children: tabWidgets));
      }

      final border =
          widget.axis == Axis.horizontal ? Border(bottom: BorderSide(color: borderColor)) : Border(right: BorderSide(color: borderColor));

      return Container(
        decoration: BoxDecoration(border: border),
        child: body,
      );
    });
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color bg;

  const _NavBtn({required this.icon, required this.onPressed, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

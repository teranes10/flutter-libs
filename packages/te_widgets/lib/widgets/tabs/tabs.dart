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
  bool _showArrows = false;

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
      _showArrows = pos.maxScrollExtent > 0;
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

  void _onSelectTab(TTab<T> tab) async {
    if (widget.controller != null) {
      await widget.controller!.selectTab(tab.value);
      if (widget.controller!.value == tab.value) {
        widget.onTabChanged?.call(tab.value);
      }
    } else {
      widget.onTabChanged?.call(tab.value);
    }
  }

  Widget _buildTab(BuildContext context, TTab<T> tab, ColorScheme colors, bool inline) {
    final sel = widget.controller?.value ?? widget.selectedValue ?? (widget.tabs.isNotEmpty ? widget.tabs.first.value : null);
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

    // Horizontal full-width mode uses TAlignedRow, which handles child expansion internally.
    // Wrapping with Expanded causes ParentDataWidget errors because TAlignedRow is not a Flex.
    return tabWidget;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isExpandedByParent = constraints.hasBoundedWidth && constraints.minWidth == constraints.maxWidth;
      final effectiveInline = isExpandedByParent ? false : widget.inline;
      final colors = context.colors;
      final borderColor = widget.borderColor ?? Colors.transparent;
      final navColor = widget.navigationButtonColor ?? colors.onSurface;
      final navBg = widget.navigationButtonBackgroundColor ?? colors.surfaceContainer;

      final tabWidgets = [
        for (final tab in widget.tabs) _buildTab(context, tab, colors, effectiveInline),
      ];

      Widget body;

      if (widget.scrollable) {
        final showButtons = widget.showNavigationButtons && context.isDesktopPlatform && _showArrows;

        Widget scrollView = NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: widget.axis,
            child: widget.axis == Axis.horizontal
                ? Padding(
                    padding: showButtons ? const EdgeInsets.symmetric(horizontal: 39) : EdgeInsets.zero,
                    child: Row(spacing: widget.tabSpacing, children: tabWidgets),
                  )
                : Padding(
                    padding: showButtons ? const EdgeInsets.symmetric(vertical: 39) : EdgeInsets.zero,
                    child: Column(spacing: widget.tabSpacing, children: tabWidgets),
                  ),
          ),
        );

        if (showButtons) {
          body = Stack(
            clipBehavior: Clip.none,
            children: [
              scrollView,
              if (widget.axis == Axis.horizontal) ...[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: TIcon(
                      shadow:
                          !_canScrollStart ? null : [BoxShadow(blurRadius: 8, spreadRadius: 4, color: colors.shadow, offset: Offset(0, 0))],
                      background: !_canScrollStart ? null : navBg,
                      icon: Icons.chevron_left,
                      size: 20,
                      onTap: !_canScrollStart ? null : () => _scrollBy(-200),
                      color: _canScrollStart ? navColor : navColor.o(0.4),
                      borderRadius: BorderRadius.circular(100)),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: TIcon(
                      shadow:
                          !_canScrollEnd ? null : [BoxShadow(blurRadius: 8, spreadRadius: 4, color: colors.shadow, offset: Offset(0, 0))],
                      background: !_canScrollEnd ? null : navBg,
                      icon: Icons.chevron_right,
                      size: 20,
                      onTap: !_canScrollEnd ? null : () => _scrollBy(200),
                      color: _canScrollEnd ? navColor : navColor.o(0.4),
                      borderRadius: BorderRadius.circular(100)),
                )
              ] else ...[
                Positioned(
                  top: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Material(
                      type: MaterialType.circle,
                      elevation: 4,
                      shadowColor: colors.shadow.o(0.35),
                      color: navBg,
                      child: TIcon(
                          icon: Icons.keyboard_arrow_up,
                          size: 20,
                          onTap: () => _scrollBy(-200),
                          color: _canScrollStart ? navColor : navColor.o(0.4),
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Material(
                      type: MaterialType.circle,
                      elevation: 4,
                      shadowColor: colors.shadow.o(0.35),
                      color: navBg,
                      child: TIcon(
                          icon: Icons.keyboard_arrow_down,
                          size: 20,
                          onTap: () => _scrollBy(200),
                          color: _canScrollEnd ? navColor : navColor.o(0.4),
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                ),
              ],
            ],
          );
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

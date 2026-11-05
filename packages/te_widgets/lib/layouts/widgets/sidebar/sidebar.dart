import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class Sidebar extends StatelessWidget {
  final List<TSidebarItem>? items;
  final double? minWidth;
  final double? maxWidth;
  final double minifiedWidth;
  final bool isMinimized;
  final TSidebarMode? mode;
  final Function(TSidebarItem)? onTap;
  final Widget? header;
  final Widget? minifiedHeader;
  final Widget? footer;
  final Widget? pinnedFooter;
  final Widget? minifiedPinnedFooter;
  final TSidebarTheme? theme;

  const Sidebar({
    super.key,
    this.items,
    this.minWidth,
    this.maxWidth,
    this.minifiedWidth = 80,
    this.isMinimized = true,
    this.mode,
    this.onTap,
    this.header,
    this.minifiedHeader,
    this.footer,
    this.pinnedFooter,
    this.minifiedPinnedFooter,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMode = mode ?? (isMinimized ? TSidebarMode.minified : TSidebarMode.full);

    if (effectiveMode == TSidebarMode.none) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topLeft,
        child: const SizedBox(width: 0, height: 0),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxWidth = maxWidth ?? (constraints.maxWidth < double.infinity ? constraints.maxWidth : null);
        bool effectiveMin = effectiveMode == TSidebarMode.minified;
        if (!effectiveMin && effectiveMaxWidth != null && items != null) {
          double maxItemWidth = 0.0;
          final textStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w300);
          const baseWidth = 56.0;

          for (var item in items!) {
            if (item.isHiddenIn(context)) continue;
            double itemWidth = baseWidth;
            if (item.icon != null) itemWidth += 30.0;
            if (item.text != null) {
              final tp = TextPainter(
                text: TextSpan(text: item.text, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout();
              itemWidth += tp.width;
            }
            if (item.hasVisibleChildrenIn(context)) itemWidth += 24.0;
            if (itemWidth > maxItemWidth) maxItemWidth = itemWidth;
          }

          if (maxItemWidth > effectiveMaxWidth) effectiveMin = true;
        }

        // Resolve which header to show: minifiedHeader when collapsed (if provided),
        // otherwise fall back to the regular header.
        final Widget? resolvedHeader = effectiveMin ? (minifiedHeader ?? header) : header;

        final Widget? resolvedPinnedFooter = effectiveMin ? (minifiedPinnedFooter ?? pinnedFooter) : pinnedFooter;

        // The scrollable body (items + footer).
        final Widget scrollChild = SingleChildScrollView(
          primary: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (items != null && items!.isNotEmpty)
                SidebarItems(
                  items: items!,
                  maxWidth: effectiveMaxWidth,
                  isMinimized: effectiveMin,
                  onTap: onTap,
                  theme: theme,
                ),
              if (footer != null) footer!,
            ],
          ),
        );

        final Widget scrollBody = ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
          ),
          child: !effectiveMin
              ? Scrollbar(
                  scrollbarOrientation: ScrollbarOrientation.left,
                  child: scrollChild,
                )
              : scrollChild,
        );

        // Header is pinned above the scroll area (not part of the scroll).
        final Widget innerContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (resolvedHeader != null) resolvedHeader,
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 0, bottom: resolvedPinnedFooter != null ? 0 : 16),
                child: _ScrollEdgeShadows(
                  child: scrollBody,
                ),
              ),
            ),
            if (resolvedPinnedFooter != null) resolvedPinnedFooter,
          ],
        );

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topLeft,
          child: Container(
            constraints: effectiveMin ? BoxConstraints.tightFor(width: minifiedWidth) : BoxConstraints(minWidth: minWidth ?? 0.0),
            child: IntrinsicWidth(child: innerContent),
          ),
        );
      },
    );
  }
}

/// Soft top/bottom shadows that fade in only while content is scrolled out of view.
class _ScrollEdgeShadows extends StatefulWidget {
  const _ScrollEdgeShadows({required this.child});

  final Widget child;

  @override
  State<_ScrollEdgeShadows> createState() => _ScrollEdgeShadowsState();
}

class _ScrollEdgeShadowsState extends State<_ScrollEdgeShadows> {
  bool _top = false;
  bool _bottom = false;

  bool _onMetrics(ScrollMetrics m) {
    final top = m.pixels > 1;
    final bottom = m.maxScrollExtent - m.pixels > 1;
    if (top != _top || bottom != _bottom) {
      setState(() {
        _top = top;
        _bottom = bottom;
      });
    }
    return false;
  }

  Widget _shadow(bool visible, {required bool atTop}) {
    // A thin strip just outside the edge, clipped by the parent, casts a short contact shadow inward.
    return Positioned(
      top: atTop ? -2 : null,
      bottom: atTop ? null : -2,
      left: 0,
      right: 0,
      height: 2,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: visible ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withAlpha(15),
                  blurRadius: 16.0,
                  spreadRadius: -2.0,
                  offset: Offset(0, atTop ? 4 : -4),
                ),
                BoxShadow(
                  color: context.colors.shadow.withAlpha(30),
                  blurRadius: 8.0,
                  spreadRadius: -2.0,
                  offset: Offset(0, atTop ? 2 : -2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (n) => _onMetrics(n.metrics),
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (n) => _onMetrics(n.metrics),
            child: widget.child,
          ),
        ),
        _shadow(_top, atTop: true),
        _shadow(_bottom, atTop: false),
      ],
    ));
  }
}

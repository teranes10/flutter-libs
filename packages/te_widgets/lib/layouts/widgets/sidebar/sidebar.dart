import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class Sidebar extends StatelessWidget {
  final List<TSidebarItem>? items;
  final double? minWidth;
  final double? maxWidth;
  final double minifiedWidth;
  final bool isMinimized;
  final Function(TSidebarItem)? onTap;
  final Widget? header;
  final Widget? minifiedHeader;
  final Widget? footer;
  final TSidebarTheme? theme;

  const Sidebar({
    super.key,
    this.items,
    this.minWidth,
    this.maxWidth,
    this.minifiedWidth = 80,
    this.isMinimized = true,
    this.onTap,
    this.header,
    this.minifiedHeader,
    this.footer,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxWidth = maxWidth ?? (constraints.maxWidth < double.infinity ? constraints.maxWidth : null);
        bool effectiveMin = isMinimized;
        if (!effectiveMin && effectiveMaxWidth != null && items != null) {
          double maxItemWidth = 0.0;
          final textStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w300);
          const baseWidth = 56.0;

          for (var item in items!) {
            if (item.isHidden) continue;
            double itemWidth = baseWidth;
            if (item.icon != null) itemWidth += 30.0;
            if (item.text != null) {
              final tp = TextPainter(
                text: TextSpan(text: item.text, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout();
              itemWidth += tp.width;
            }
            if (item.hasVisibleChildren) itemWidth += 24.0;
            if (itemWidth > maxItemWidth) maxItemWidth = itemWidth;
          }

          if (maxItemWidth > effectiveMaxWidth) effectiveMin = true;
        }

        // Resolve which header to show: minifiedHeader when collapsed (if provided),
        // otherwise fall back to the regular header.
        final Widget? resolvedHeader = effectiveMin ? (minifiedHeader ?? header) : header;

        // The scrollable body (items + footer).
        final Widget scrollBody = SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
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
            ),
          ),
        );

        // Header is pinned above the scroll area (not part of the scroll).
        final Widget innerContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (resolvedHeader != null) resolvedHeader,
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 32, bottom: 16),
                child: scrollBody,
              ),
            ),
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

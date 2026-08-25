import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class SidebarItems extends StatelessWidget {
  final List<TSidebarItem> items;
  final double? maxWidth;
  final bool isMinimized;
  final TSidebarTheme? theme;
  final Function(TSidebarItem)? onTap;

  const SidebarItems({super.key, required this.items, this.maxWidth, this.isMinimized = false, this.theme, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final sidebarTheme = theme ?? TSidebarTheme.defaultTheme(context);

    final child = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      reverse: true,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildAnimatedItems(sidebarTheme),
        ),
      ),
    );

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        overscroll: false,
      ),
      child: !isMinimized
          ? Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.left,
              child: child,
            )
          : child,
    );
  }

  List<Widget> _buildAnimatedItems(TSidebarTheme sidebarTheme) {
    final visibleItems = items.where((item) => !item.isHidden).toList();
    return List.generate(visibleItems.length, (index) {
      return TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(
          begin: Offset(isMinimized ? -0.5 : 0.25, 0),
          end: Offset.zero,
        ),
        duration: Duration(milliseconds: 300 + (index * 80)),
        curve: Curves.easeInOutCubic,
        builder: (context, offset, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 80)),
            curve: Curves.easeInOutCubic,
            builder: (context, opacity, child) {
              return Transform.translate(
                offset: Offset(offset.dx * (isMinimized ? 30 : 100), 0),
                child: Opacity(opacity: opacity, child: child),
              );
            },
            child: child,
          );
        },
        child: TSidebarItemWidget(
          item: visibleItems[index],
          maxWidth: maxWidth,
          isMinimized: isMinimized,
          level: 0,
          theme: sidebarTheme,
          onTap: onTap,
        ),
      );
    });
  }
}

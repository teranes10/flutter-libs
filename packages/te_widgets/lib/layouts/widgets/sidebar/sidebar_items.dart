import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class SidebarItems extends StatelessWidget {
  final List<TSidebarItem> items;
  final bool isMinimized;
  final TSidebarTheme? theme;
  final Function(TSidebarItem)? onTap;

  const SidebarItems({super.key, required this.items, this.isMinimized = false, this.theme, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final sidebarTheme = theme ?? TSidebarTheme.defaultTheme(context);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: !isMinimized,
        overscroll: false,
      ),
      child: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildAnimatedItems(sidebarTheme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedItems(TSidebarTheme sidebarTheme) {
    return List.generate(items.length, (index) {
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
          item: items[index],
          isMinimized: isMinimized,
          level: 0,
          theme: sidebarTheme,
          onTap: () => onTap?.call(items[index]),
        ),
      );
    });
  }
}

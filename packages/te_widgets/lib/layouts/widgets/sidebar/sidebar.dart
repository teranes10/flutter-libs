import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class Sidebar extends StatelessWidget {
  final List<TSidebarItem>? items;
  final double width;
  final double minifiedWidth;
  final bool isMinimized;
  final Function(TSidebarItem)? onTap;
  final Widget? footer;

  const Sidebar({
    super.key,
    this.items,
    this.width = 275,
    this.minifiedWidth = 80,
    this.isMinimized = true,
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: isMinimized ? minifiedWidth : width,
      child: Material(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                color: colors.surface,
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (items != null && items!.isNotEmpty)
                          SidebarItems(
                            items: items!,
                            isMinimized: isMinimized,
                            onTap: onTap,
                          ),
                        if (footer != null) footer!,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

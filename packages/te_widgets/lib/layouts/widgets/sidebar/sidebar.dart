import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:te_widgets/te_widgets.dart';

class Sidebar extends StatelessWidget {
  final List<TSidebarItem>? items;
  final double width;
  final double minifiedWidth;
  final bool isMinimized;

  const Sidebar({
    super.key,
    this.items,
    this.width = 275,
    this.minifiedWidth = 80,
    this.isMinimized = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.isMobile) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: isMinimized ? minifiedWidth : width,
          child: Material(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Container(
                    color: theme.surface,
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
                              ),
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
      },
    );
  }
}

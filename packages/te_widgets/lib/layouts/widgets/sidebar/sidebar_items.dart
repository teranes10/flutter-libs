import 'package:flutter/material.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_item.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_item_group.dart';

class SidebarItems extends StatelessWidget {
  final List<dynamic>? items; // Can contain SidebarItem or SidebarItemGroup
  final double heightOffset;

  const SidebarItems({
    super.key,
    this.items,
    this.heightOffset = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    if (items == null || items!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
        height: MediaQuery.of(context).size.height - heightOffset,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: true,
            overscroll: false,
          ),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(items!.length, (index) {
                  final item = items![index];
                  return TweenAnimationBuilder<Offset>(
                    tween: Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeInOut,
                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: Offset(offset.dx * 100, 0), // scale x translation
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          opacity: 1.0,
                          curve: Curves.easeInOut,
                          child: child,
                        ),
                      );
                    },
                    child: item is SidebarItemGroup
                        ? item
                        : SidebarItem(
                            icon: item.icon,
                            text: item.text,
                            routeName: item.routeName,
                            onTap: item.onTap,
                          ),
                  );
                }),
              ),
            ),
          ),
        ));
  }
}

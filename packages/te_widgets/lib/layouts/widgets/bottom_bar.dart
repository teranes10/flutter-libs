import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class LayoutBottomBar extends StatelessWidget {
  const LayoutBottomBar({super.key, required this.items, required this.onOpenMore, this.logo});

  final List<TSidebarItem> items;
  final Widget? logo;
  final VoidCallback onOpenMore;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (items.length == 1) return _buildSingleItemBar(context, currentRoute);

    var currentIndex = -1;
    for (var i = 0; i < items.length; i++) {
      if (items[i].containsRoute(currentRoute)) {
        currentIndex = i;
        break;
      }
    }

    return TBottomBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index < items.length) {
          items[index].tap(context);
        } else {
          onOpenMore();
        }
      },
      items: [
        for (final item in items) TBottomBarItem(icon: item.icon ?? HugeIcons.strokeRoundedCircle, label: item.text ?? ''),
        const TBottomBarItem(icon: HugeIcons.strokeRoundedMoreHorizontal, label: 'More'),
      ],
    );
  }

  /// One qualified item: logo on the left, item in the center, "More" on the right.
  Widget _buildSingleItemBar(BuildContext context, String currentRoute) {
    final colors = context.colors;
    final item = items.first;
    final isActive = item.containsRoute(currentRoute);
    final contentColor = isActive ? colors.primary : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (logo != null)
                    SizedBox(
                      height: 32,
                      child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: logo),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () => item.tap(context),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TIcon.raw(item.icon ?? HugeIcons.strokeRoundedCircle, color: contentColor, size: 24),
                    const SizedBox(height: 4),
                    Text(item.text ?? '',
                        style: TextStyle(color: contentColor, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onOpenMore,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TIcon.raw(HugeIcons.strokeRoundedMoreHorizontal, color: colors.onSurfaceVariant, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

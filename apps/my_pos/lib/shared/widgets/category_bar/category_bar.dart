import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pos/features/category/categories.dart';
import 'package:my_pos/models/category.dart';
import 'package:te_widgets/te_widgets.dart';

class TCategoryBar extends ConsumerWidget {
  const TCategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final categoryMap = ref.watch(categoriesProvider).value;
    final selectedId = ref.watch(currentCategoryProvider);
    final categories = categoryMap?.values.toList() ?? [];
    final selected = selectedId != null && categoryMap != null ? categoryMap[selectedId] : null;

    return Container(
      decoration: BoxDecoration(color: colors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: selected != null ? 'Selected Category: ' : 'Choose Category',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
                  children: [
                    if (selected != null)
                      TextSpan(
                        text: selected.name,
                        style: TextStyle(color: colors.primary),
                      ),
                  ],
                ),
              ),

              TButton(
                type: TButtonType.softText,
                shape: TButtonShape.pill,
                size: TButtonSize.sm,
                color: colors.onSurface,
                text: 'View All',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 5,
              children: categories
                  .map(
                    (x) => TButton(
                      baseTheme: TWidgetTheme.surfaceTheme(colors, active: selectedId == x.id),
                      shape: TButtonShape.pill,
                      size: TButtonSize.md.copyWith(icon: 35, vPad: 5, hPad: 5, spacing: 6),
                      text: x.name,
                      imageUrl: x.image ?? '',
                      onTap: () => ref.read(currentCategoryProvider.notifier).selectCategory(x.id),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

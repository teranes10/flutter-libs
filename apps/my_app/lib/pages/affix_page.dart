import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class AffixPage extends StatefulWidget {
  const AffixPage({super.key});

  @override
  State<AffixPage> createState() => _AffixPageState();
}

class _AffixPageState extends State<AffixPage> {
  int _filterIndex = 0;

  static const _filters = ['All', 'Active', 'Archived'];
  static const _barHeight = 56.0;

  String get _filter => _filters[_filterIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAffix Showcase', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Pins a toolbar/summary bar to the top of a CustomScrollView once scrolling reaches it '
            '(Ant Design\'s Affix). Scroll the list below — the filter bar sticks to the top instead of '
            'scrolling away with the content.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          TCard(
            title: 'Sticky Filter Bar Above a Scrolling List',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 360,
                decoration: BoxDecoration(border: Border.all(color: colors.outlineVariant)),
                child: CustomScrollView(
                  slivers: [
                    TAffix(
                      height: _barHeight,
                      child: Container(
                        color: colors.surfaceContainerHigh,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        child: TButtonGroup(
                          initialIndex: _filterIndex,
                          onIndexChanged: (i) => setState(() => _filterIndex = i),
                          items: [for (final f in _filters) TButtonGroupItem(text: f)],
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: 40,
                      itemBuilder: (context, i) => ListTile(
                        leading: CircleAvatar(child: Text('${i + 1}')),
                        title: Text('Item ${i + 1} — $_filter'),
                        subtitle: const Text('Scroll to see the filter bar stay pinned'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

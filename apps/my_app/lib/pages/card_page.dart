import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.theme;

    Widget section(String title, String desc, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(desc, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );

    Widget sample(String label, Widget card, {double width = 220}) => SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              card,
            ],
          ),
        );

    Widget body(String text) => Text(text, style: theme.textTheme.bodyMedium);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TCard & .card() Showcase', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Any widget can be wrapped with .card(). Default to no shadow; add TCardShadow.sm only when elevation is needed. md and lg are for rare floating emphasis.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          section(
            'Shadow levels',
            'TCardShadow.none / sm / md / lg via .card(shadow:) or the .cardSm() .cardMd() .cardLg() shortcuts.',
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final level in TCardShadow.values)
                  sample(
                    'TCardShadow.${level.name}',
                    body('Shadow level ${level.name}').card(shadow: level, padding: const EdgeInsets.all(20)),
                  ),
              ],
            ),
          ),

          section(
            'Shortcuts',
            'cardSm(), cardMd(), cardLg() are shorthand for .card(shadow: ...).',
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                sample('.cardSm()', body('Small').cardSm(padding: const EdgeInsets.all(20))),
                sample('.cardMd()', body('Medium').cardMd(padding: const EdgeInsets.all(20))),
                sample('.cardLg()', body('Large').cardLg(padding: const EdgeInsets.all(20))),
              ],
            ),
          ),

          section(
            'Colors & radius',
            'backgroundColor, borderColor and borderRadius are overridable.',
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                sample(
                  'Tinted background',
                  body('Info surface').card(
                    shadow: TCardShadow.sm,
                    backgroundColor: t.info.withAlpha(20),
                    borderColor: t.info.withAlpha(90),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                sample(
                  'Large radius',
                  body('Radius 20').card(
                    shadow: TCardShadow.sm,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                sample(
                  'Square',
                  body('Radius 0').card(
                    shadow: TCardShadow.sm,
                    borderRadius: BorderRadius.zero,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                sample(
                  'Dark surface',
                  Text('Contrast', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onInverseSurface)).card(
                    shadow: TCardShadow.none,
                    backgroundColor: colors.inverseSurface,
                    borderColor: Colors.transparent,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            ),
          ),

          section(
            'Interactive',
            'onTap adds an ink ripple.',
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final level in [TCardShadow.none, TCardShadow.sm])
                  sample(
                    'Tap me (${level.name})',
                    body('Tappable card').card(
                      shadow: level,
                      padding: const EdgeInsets.all(20),
                      onTap: () => TToastService.info(context, 'Tapped ${level.name} card'),
                    ),
                  ),
              ],
            ),
          ),

          section(
            'With tiles',
            'TTile has no card of its own; wrap it. Without trailing the tile shrinks to fit.',
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                sample(
                  'Compact tile',
                  TTile.h5(icon: Icons.analytics_outlined, iconColor: t.info, title: 'Analytics', subtitle: 'Updated 2m ago')
                      .card(),
                  width: 260,
                ),
                sample(
                  'Tile with trailing',
                  TTile.h5(
                    icon: Icons.cloud_done_rounded,
                    iconColor: t.success,
                    title: 'Backup complete',
                    subtitle: '5.2 GB synced',
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  ).card(),
                  width: 320,
                ),
                sample(
                  'Hub tile (iconOnTop)',
                  TTile.h4(
                    iconOnTop: true,
                    icon: Icons.inventory_2_outlined,
                    iconColor: t.primary,
                    title: 'Stocktake',
                    subtitle: '12 open counts',
                    trailing: TBadge(label: '12', color: t.primary),
                  ).card(padding: const EdgeInsets.all(16)),
                  width: 220,
                ),
                sample(
                  'Task row',
                  TTile.task(
                    icon: Icons.local_shipping_outlined,
                    title: 'DO-90312 · Dispatch',
                    subtitle: 'Dock 4',
                    status: 'Urgent',
                    statusColor: t.danger,
                    done: 1,
                    total: 6,
                  ).card(padding: EdgeInsets.zero),
                  width: 340,
                ),
              ],
            ),
          ),

          section(
            'TCard with native header',
            'TCard(title:, subtitle:, icon:, trailing:, shadowLevel:) for full cards with headers.',
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final level in TCardShadow.values)
                  SizedBox(
                    width: 280,
                    child: TCard(
                      title: 'Card ${level.name}',
                      subtitle: 'shadowLevel: ${level.name}',
                      icon: Icons.layers_outlined,
                      trailing: TBadge(label: level.name, color: t.primary),
                      shadowLevel: level,
                      margin: EdgeInsets.zero,
                      child: body('Card body content'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

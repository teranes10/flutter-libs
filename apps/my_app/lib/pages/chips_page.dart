import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Chip widgets.
class ChipsPage extends StatelessWidget {
  const ChipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Chips',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Compact elements that represent an attribute, text, entity, or action.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Chip Sizing (sm, md, lg)
          WidgetDocCard(
            title: 'Chip Sizing (sm, md, lg)',
            description: 'Three standardized sizes with auto-resolved padding, radius, and font sizes',
            icon: Icons.photo_size_select_small,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TChip(
                  size: TChipSize.sm,
                  type: TVariant.tonal,
                  icon: Icons.filter_alt,
                  text: 'Small Chip (sm)',
                  trailing: TIcon.close(size: 11, padding: EdgeInsets.zero, onTap: () {}),
                ),
                TChip(
                  size: TChipSize.md,
                  type: TVariant.tonal,
                  icon: Icons.filter_alt,
                  text: 'Medium Chip (md - Default)',
                  trailing: TIcon.close(size: 12, padding: EdgeInsets.zero, onTap: () {}),
                ),
                TChip(
                  size: TChipSize.lg,
                  type: TVariant.tonal,
                  icon: Icons.filter_alt,
                  text: 'Large Chip (lg)',
                  trailing: TIcon.close(size: 14, padding: EdgeInsets.zero, onTap: () {}),
                ),
              ],
            ),
            code: '''TChip(size: TChipSize.sm, text: 'Small Chip')
TChip(size: TChipSize.md, text: 'Medium Chip (Default)')
TChip(size: TChipSize.lg, text: 'Large Chip')
// With hoverable close button:
TChip(
  size: TChipSize.sm,
  text: 'Filter',
  trailing: TIcon.close(size: 11, padding: EdgeInsets.zero, onTap: () {}),
)''',
            properties: const [
              PropertyDoc(
                name: 'size',
                type: 'TChipSize',
                defaultValue: 'TChipSize.md',
                description: 'Size metric configuration (TChipSize.sm, TChipSize.md, TChipSize.lg)',
              ),
              PropertyDoc(
                name: 'trailing',
                type: 'Widget?',
                description:
                    'Optional trailing widget, e.g. TIcon.close(size: 11, padding: EdgeInsets.zero, onTap: ...) for onhover close effect',
              ),
            ],
          ),

          // Variants (solid, tonal, outline, softOutline, text)
          WidgetDocCard(
            title: 'Chip Variants (TVariant)',
            description: 'All visual variants supported by TChip (solid, tonal, outline, softOutline, text)',
            icon: Icons.style,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solid Variant:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const TChip.solid(text: 'Primary'),
                    TChip.solid(text: 'Secondary', color: context.theme.secondary),
                    TChip.solid(text: 'Success', color: context.theme.success),
                    TChip.solid(text: 'Danger', color: context.theme.danger),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Tonal Variant (Default):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const TChip.tonal(icon: Icons.face, text: 'User'),
                    TChip.tonal(icon: Icons.settings, text: 'Settings', color: context.theme.secondary),
                    TChip.tonal(icon: Icons.check_circle, text: 'Active', color: context.theme.success),
                    TChip.tonal(icon: Icons.warning, text: 'Warning', color: context.theme.warning),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Outline Variant:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const TChip.outline(text: 'Primary'),
                    TChip.outline(text: 'Info', color: context.theme.info),
                    TChip.outline(text: 'Success', color: context.theme.success),
                    TChip.outline(text: 'Danger', color: context.theme.danger),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Soft Outline Variant:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const TChip.softOutline(text: 'Soft Primary'),
                    TChip.softOutline(text: 'Soft Info', color: context.theme.info),
                    TChip.softOutline(text: 'Soft Success', color: context.theme.success),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Text / Ghost Variant:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const TChip.text(icon: Icons.tag, text: 'Tag'),
                    TChip.text(icon: Icons.bolt, text: 'Action', color: context.theme.warning),
                    TChip.text(icon: Icons.favorite, text: 'Favorite', color: context.theme.danger),
                  ],
                ),
              ],
            ),
            code: '''// Named constructors:
TChip.solid(text: 'Solid Chip')
TChip.tonal(text: 'Tonal Chip (Default)')
TChip.outline(text: 'Outline Chip')
TChip.softOutline(text: 'Soft Outline Chip')
TChip.text(text: 'Text Chip')

// Or using variant / type parameter:
TChip(variant: TVariant.solid, text: 'Solid')
TChip(variant: TVariant.tonal, text: 'Tonal')
TChip(variant: TVariant.outline, text: 'Outline')
TChip(variant: TVariant.softOutline, text: 'Soft Outline')
TChip(variant: TVariant.text, text: 'Text')''',
            properties: const [
              PropertyDoc(
                name: 'variant',
                type: 'TVariant?',
                defaultValue: 'TVariant.tonal',
                description: 'The visual variant of the chip: solid, tonal, outline, softOutline, text (or use type alias)',
              ),
              PropertyDoc(name: 'text', type: 'String?', description: 'The text to display'),
              PropertyDoc(
                name: 'color',
                type: 'Color?',
                description: 'Primary theme color used for background/borders/text based on variant',
              ),
            ],
          ),

          // Custom Chips
          WidgetDocCard(
            title: 'Custom Chips',
            description: 'Fully customizable appearance with custom backgrounds, text colors, and tap callbacks',
            icon: Icons.palette,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TChip(
                  text: 'Custom Gradient',
                  background: Colors.purple.shade50,
                  textColor: Colors.purple,
                  icon: Icons.star,
                  borderRadius: BorderRadius.circular(20),
                ),
                TChip.tonal(text: 'Click Me', color: context.theme.info, onTap: () {}),
              ],
            ),
            code: '''TChip(
  text: 'Custom',
  background: Colors.purple.shade50,
  textColor: Colors.purple,
  icon: Icons.star,
  borderRadius: BorderRadius.circular(20),
)''',
            properties: const [
              PropertyDoc(name: 'background', type: 'Color?', description: 'Custom background color'),
              PropertyDoc(name: 'textColor', type: 'Color?', description: 'Custom text and icon color'),
              PropertyDoc(name: 'borderRadius', type: 'BorderRadius?', description: 'Custom border radius'),
              PropertyDoc(name: 'onTap', type: 'VoidCallback?', description: 'Callback when chip is tapped'),
            ],
          ),

          // Chips with Icons & Text Variants
          WidgetDocCard(
            title: 'Chips with Icons & Text Variants',
            description: 'Chips with leading icons, customizable accent colors, and TVariant styles',
            icon: Icons.stars,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TChip(icon: Icons.star_rounded, text: 'Pro Member', color: Colors.amber.shade700, type: TVariant.solid),
                TChip(icon: Icons.verified_rounded, text: 'Verified', color: Colors.blue, type: TVariant.tonal),
                TChip(icon: Icons.local_shipping_rounded, text: 'Fast Delivery', color: Colors.green, type: TVariant.outline),
                TChip(icon: Icons.admin_panel_settings_rounded, text: 'Superadmin', color: Colors.red, type: TVariant.softOutline),
              ],
            ),
            code: '''// Solid with icon:
TChip(
  icon: Icons.star_rounded,
  text: 'Pro Member',
  color: Colors.amber,
  type: TVariant.solid,
)

// Tonal with icon:
TChip(
  icon: Icons.verified_rounded,
  text: 'Verified',
  color: Colors.blue,
  type: TVariant.tonal,
)

// Outline with icon:
TChip(
  icon: Icons.local_shipping_rounded,
  text: 'Fast Delivery',
  color: Colors.green,
  type: TVariant.outline,
)

// In Table Column with auto width estimation & common config fallback:
TTableHeader.chips(
  'Features',
  (x) => [
    if (x.isPro) const TChip.solid(text: 'Pro', icon: Icons.star_rounded, color: Colors.amber),
    if (x.isVerified) const TChip.tonal(text: 'Verified', icon: Icons.verified_rounded, color: Colors.blue),
    if (x.isFastShip) const TChip(text: 'Fast Delivery'), // inherits header fallback type & color
  ],
  type: TVariant.outline,
  spacing: 4.0,
)''',
            properties: const [
              PropertyDoc(name: 'icon', type: 'dynamic', description: 'Leading icon (IconData, HugeIcon, or Widget)'),
              PropertyDoc(
                name: 'type / variant',
                type: 'TVariant?',
                description: 'Visual style: TVariant.solid, TVariant.tonal, TVariant.outline, TVariant.softOutline, TVariant.text',
              ),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Theme color applied to background/border/text based on variant'),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

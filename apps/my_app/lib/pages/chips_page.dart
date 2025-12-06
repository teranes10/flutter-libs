import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Chip widgets.
class ChipsPage extends StatelessWidget {
  const ChipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Chips',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Compact elements that represent an attribute, text, entity, or action.',
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),

          // Solid Chips
          WidgetDocCard(
            title: 'Solid Chips',
            description: 'Filled chips with solid background colors',
            icon: Icons.label,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TChip(type: TVariant.solid, text: 'Primary', color: AppColors.primary),
                TChip(type: TVariant.solid, text: 'Secondary', color: AppColors.secondary),
                TChip(type: TVariant.solid, text: 'Success', color: AppColors.success),
                TChip(type: TVariant.solid, text: 'Danger', color: AppColors.danger),
              ],
            ),
            code: '''TChip(
  type: TVariant.solid,
  text: 'Primary',
  color: AppColors.primary,
)''',
            properties: const [
              PropertyDoc(
                name: 'type',
                type: 'TVariant?',
                defaultValue: 'TVariant.tonal',
                description: 'The visual variant of the chip',
              ),
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'The text to display',
              ),
            ],
          ),

          // Tonal Chips
          WidgetDocCard(
            title: 'Tonal Chips',
            description: 'Chips with subtle background tint (Default)',
            icon: Icons.label_outline,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TChip(type: TVariant.tonal, icon: Icons.face, text: 'User', color: AppColors.primary),
                TChip(type: TVariant.tonal, icon: Icons.settings, text: 'Settings', color: AppColors.secondary),
                TChip(type: TVariant.tonal, icon: Icons.check_circle, text: 'Active', color: AppColors.success),
                TChip(type: TVariant.tonal, icon: Icons.warning, text: 'Warning', color: AppColors.warning),
              ],
            ),
            code: '''TChip(
  type: TVariant.tonal,
  icon: Icons.check_circle,
  text: 'Active',
  color: AppColors.success,
)''',
            properties: const [
              PropertyDoc(
                name: 'icon',
                type: 'IconData?',
                description: 'Optional icon to display before text',
              ),
            ],
          ),

          // Outline Chips
          WidgetDocCard(
            title: 'Outline Chips',
            description: 'Chips with border and transparent background',
            icon: Icons.border_style,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TChip(type: TVariant.outline, text: 'Outline Primary', color: AppColors.primary),
                TChip(type: TVariant.outline, text: 'Outline Info', color: AppColors.info),
                TChip(type: TVariant.outline, text: 'Outline Danger', color: AppColors.danger),
              ],
            ),
            code: '''TChip(
  type: TVariant.outline,
  text: 'Outline',
  color: AppColors.primary,
)''',
          ),

          // Custom Chips
          WidgetDocCard(
            title: 'Custom Chips',
            description: 'Fully customizable appearance',
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
                TChip(
                  text: 'Click Me',
                  color: AppColors.info,
                  type: TVariant.tonal,
                  onTap: () {},
                ),
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
              PropertyDoc(
                name: 'background',
                type: 'Color?',
                description: 'Custom background color',
              ),
              PropertyDoc(
                name: 'textColor',
                type: 'Color?',
                description: 'Custom text and icon color',
              ),
              PropertyDoc(
                name: 'borderRadius',
                type: 'BorderRadius?',
                description: 'Custom border radius',
              ),
              PropertyDoc(
                name: 'onTap',
                type: 'VoidCallback?',
                description: 'Callback when chip is tapped',
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

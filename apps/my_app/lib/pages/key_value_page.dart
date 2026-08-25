import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class KeyValuePage extends StatelessWidget {
  const KeyValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleValues = [
      TKeyValue.text('Order ID', 'ORD-2024-8910', icon: const Icon(Icons.receipt_long, size: 14)),
      TKeyValue.text('Customer Name', 'Jane Doe'),
      TKeyValue.text('Contact Email', 'jane.doe@example.com'),
      TKeyValue(
        'Status',
        widget: const TChip(text: 'In Transit', icon: Icons.local_shipping, type: TVariant.tonal),
      ),
      TKeyValue.text('Total Amount', '\$1,450.00'),
      TKeyValue.datetime('Order Placed', DateTime.now().toIso8601String()),
      TKeyValue.text('Payment Terms', 'Net 30 Days'),
      TKeyValue.text('Shipping Method', 'Express Priority (Next Day Air)'),
    ];

    Widget buildCard({required String title, required String subtitle, required Widget child}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: context.colors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: context.colors.outlineVariant.withAlpha(80)),
            ),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
          const SizedBox(height: 28),
        ],
      );
    }

    return TPageWrapper(
      title: 'Key Value Section',
      description:
          'Demonstrates row-flow manner (dynamic packing) and columnar manner (aligned columns) for both inline and stacked key-values.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Flow Inline (Dynamic Wrap)
          buildCard(
            title: '1. Inline Flow (Dynamic Wrap)',
            subtitle: 'TKeyValueSection.flowInline() — inline Key: Value items wrap dynamically into rows based on natural content width.',
            child: TKeyValueSection.flow(values: sampleValues),
          ),

          // 2. Columns Inline (Aligned Grid)
          buildCard(
            title: '2. Inline Columns (Aligned Grid)',
            subtitle: 'TKeyValueSection.columnsInline() — multi-column grid with vertically aligned key columns and width-based flex.',
            child: TKeyValueSection.columnsInline(values: sampleValues),
          ),

          // 3. Flow Stacked (Dynamic Wrap)
          buildCard(
            title: '3. Stacked Flow (Dynamic Wrap)',
            subtitle: 'TKeyValueSection.flowStacked() — keys stacked above values, dynamically flowing into rows.',
            child: TKeyValueSection.flowStacked(values: sampleValues),
          ),

          // 4. Columns Stacked (Aligned Grid)
          buildCard(
            title: '4. Stacked Columns (Aligned Grid)',
            subtitle: 'TKeyValueSection.columnsStacked() — multi-column grid with width-based proportional flex.',
            child: TKeyValueSection.columnsStacked(values: sampleValues, gap: 4, hSpacing: 20, vSpacing: 14),
          ),

          // 5. Split (Key Left, Value Right List)
          buildCard(
            title: '5. Split List (Key Left, Value Right)',
            subtitle: 'TKeyValueSection.split() — single-column vertical list with Key on far left and Value on far right.',
            child: TKeyValueSection.split(values: sampleValues),
          ),
        ],
      ),
    );
  }
}

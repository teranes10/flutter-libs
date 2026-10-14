import 'package:flutter/material.dart';
import 'package:my_app/widgets/widget_doc_card.dart';
import 'package:te_widgets/te_widgets.dart';

class KeyValuePage extends StatelessWidget {
  const KeyValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleValues = [
      TKeyValue.text('Order ID', 'ORD-2024-8910', icon: const Icon(Icons.receipt_long, size: 14)),
      TKeyValue.text('Customer Name', 'Jane Doe'),
      TKeyValue.text('Contact Email', 'jane.doe@example.com'),
      TKeyValue.chip('Status', 'Shipped', color: Colors.green),
      TKeyValue.text('Total Amount', '\$1,450.00'),
      TKeyValue.datetime('Order Placed', DateTime.now().toIso8601String()),
      TKeyValue.text('Payment Terms', 'Net 30 Days'),
      TKeyValue.text('Shipping Method', 'Express Priority (Next Day Air)'),
    ];

    final specializedValues = [
      TKeyValue.text('Product Name', 'Pro Wireless Headphones', icon: const Icon(Icons.headphones_rounded, size: 14)),
      TKeyValue.image('Thumbnail', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100', size: 36, borderRadius: BorderRadius.circular(6)),
      TKeyValue.chip('Stock Status', 'In Stock', color: Colors.green),
      TKeyValue.chips('Tags', ['Wireless', 'Noise-Cancelling', 'USB-C'], color: Colors.blue),
      TKeyValue.rating('User Rating', 4.5),
      TKeyValue.progress('Target Sales', 0.78, color: Colors.indigo),
      TKeyValue.toggle('Active Listing', true),
      TKeyValue.color('Primary Accent', '#6366F1'),
      TKeyValue.datetime('Created At', DateTime.now().toIso8601String()),
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
          // 0. Specialized Value Factories
          WidgetDocCard(
            title: 'Specialized Value Factories (TKeyValue.*)',
            description:
                'Mirroring TTableHeader, TKeyValue provides dedicated factory constructors for datetime, image, chip, chips, rating, progress, toggle, and color without manual widget boilerplate.',
            icon: Icons.auto_awesome_rounded,
            preview: TKeyValueSection.columnsInline(
              values: specializedValues,
              columns: 2,
              hSpacing: 24,
              vSpacing: 14,
            ),
            code: '''final values = [
  TKeyValue.text('Product Name', 'Pro Wireless Headphones', icon: const Icon(Icons.headphones_rounded, size: 14)),
  TKeyValue.image('Thumbnail', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100', size: 36, borderRadius: BorderRadius.circular(6)),
  TKeyValue.chip('Stock Status', 'In Stock', color: Colors.green),
  TKeyValue.chips('Tags', ['Wireless', 'Noise-Cancelling', 'USB-C'], color: Colors.blue),
  TKeyValue.rating('User Rating', 4.5),
  TKeyValue.progress('Target Sales', 0.78, color: Colors.indigo),
  TKeyValue.toggle('Active Listing', true),
  TKeyValue.color('Primary Accent', '#6366F1'),
  TKeyValue.datetime('Created At', DateTime.now().toIso8601String()),
];

TKeyValueSection.columnsInline(values: values, columns: 2);''',
            properties: const [
              PropertyDoc(name: 'TKeyValue.text', type: 'factory', description: 'Displays simple or icon-adorned text.'),
              PropertyDoc(name: 'TKeyValue.datetime', type: 'factory', description: 'Formats UTC/ISO dates with TDateTimeText.'),
              PropertyDoc(name: 'TKeyValue.image', type: 'factory', description: 'Renders remote or memory images with TImage.'),
              PropertyDoc(name: 'TKeyValue.chip', type: 'factory', description: 'Displays a single status chip with TChip.'),
              PropertyDoc(name: 'TKeyValue.chips', type: 'factory', description: 'Displays multiple chips wrapped with custom colors/icons.'),
              PropertyDoc(name: 'TKeyValue.rating', type: 'factory', description: 'Renders star ratings using TRating.'),
              PropertyDoc(name: 'TKeyValue.progress', type: 'factory', description: 'Renders progress bars using TProgressBar.'),
              PropertyDoc(name: 'TKeyValue.toggle', type: 'factory', description: 'Interactive or read-only switch using TSwitch.'),
              PropertyDoc(name: 'TKeyValue.color', type: 'factory', description: 'Displays color swatch circle and hex code.'),
            ],
          ),
          const SizedBox(height: 28),

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

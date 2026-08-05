import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class KeyValuePage extends StatelessWidget {
  const KeyValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleValues = [
      TKeyValue.text('Order ID', 'ORD-2023-8910'),
      TKeyValue.text('Customer', 'John Doe'),
      TKeyValue.text('Email', 'john.doe@example.com'),
      TKeyValue.text('Status', 'Processing'),
      TKeyValue.text('Amount', '\$1,250.00'),
      TKeyValue.datetime('Date', DateTime.now().toIso8601String()),
    ];

    TKeyValueTheme getTheme({bool forceKeyValue = false, bool gridInline = false}) {
      return TKeyValueTheme(
        keyStyle: context.theme.keyValueTheme.keyStyle,
        labelStyle: context.theme.keyValueTheme.labelStyle,
        valueStyle: context.theme.keyValueTheme.valueStyle,
        forceKeyValue: forceKeyValue,
        gridInline: gridInline,
      );
    }

    return TPageWrapper(
      title: 'Key Value Section',
      description: 'Demonstrates TKeyValueSection, TSummaryList, and TBreakdownCard.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Narrow Layout Mode
          const Text(
            '1. Narrow Layout Mode (forceKeyValue: true)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: context.colors.surfaceContainerLowest,
            child: TKeyValueSection(
              values: sampleValues,
              theme: getTheme(forceKeyValue: true),
            ),
          ),
          const SizedBox(height: 32),

          // 2. Grid Layout Stacked Mode
          const Text(
            '2. Grid Layout Stacked Mode (Default Grid)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: context.colors.surfaceContainerLowest,
            child: TKeyValueSection(
              values: sampleValues,
              theme: getTheme(forceKeyValue: false, gridInline: false),
            ),
          ),
          const SizedBox(height: 32),

          // 3. Grid Layout Inline Mode
          const Text(
            '3. Grid Layout Inline Mode (gridInline: true)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: context.colors.surfaceContainerLowest,
            child: TKeyValueSection(
              values: sampleValues,
              theme: getTheme(forceKeyValue: false, gridInline: true),
            ),
          ),
          const SizedBox(height: 32),

          // 4. Summary List
          const Text(
            '4. Summary List (TSummaryList)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TSummaryList(
            title: 'Package Summary',
            titleIcon: Icons.inventory_2,
            items: const [
              TSummaryItem(icon: Icons.category_outlined, text: 'Type: Parcel (5 kg)'),
              TSummaryItem(icon: Icons.notes_outlined, text: 'Description: Electronics and documents'),
              TSummaryItem(icon: Icons.download_outlined, text: 'Quantity: 1'),
              TSummaryItem(icon: Icons.straighten_outlined, text: 'Dimensions: 15 x 10 x 5 cm'),
              TSummaryItem(icon: Icons.wine_bar_outlined, text: 'Fragile: Yes'),
            ],
          ),
          const SizedBox(height: 32),

          // 5. Breakdown Card
          const Text(
            '5. Breakdown Card (TBreakdownCard)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const TBreakdownCard(
            title: 'Order Summary',
            headerIcon: Icons.lock_outline,
            trailingIcon: Icons.lock_outline,
            trailingLabel: 'Secure',
            items: [
              TBreakdownItem(label: 'Base Charge', value: 'LKR 250.00'),
              TBreakdownItem(label: 'Distance Fee (30.5 km)', value: 'LKR 2850.00'),
              TBreakdownItem(label: 'Service Tax', value: 'LKR 310.00'),
            ],
            totalLabel: 'Total Delivery Charge:',
            totalValue: 'LKR 3410.00',
          ),
        ],
      ),
    );
  }
}

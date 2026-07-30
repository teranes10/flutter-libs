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
      description: 'Demonstrates the different layout modes of TKeyValueSection.',
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
        ],
      ),
    );
  }
}

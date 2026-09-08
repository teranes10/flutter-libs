import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class SampleProduct {
  final String name;
  final List<String> tags;

  SampleProduct({required this.name, required this.tags});
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TTableHeader.chips tests', () {
    final product = SampleProduct(
      name: 'Widget A',
      tags: ['Flutter', 'Dart', 'Widgets'],
    );

    test('TTableHeader.chips computes auto widthEstimator correctly from TChip list', () {
      final header = TTableHeader<SampleProduct, int>.chips(
        'Tags',
        (p) => TChip.fromStrings(p.tags),
        spacing: 6.0,
      );

      expect(header.widthEstimator, isNotNull);
      final estimatedWidth = header.widthEstimator!(product);

      final wFlutter = TTableTheme.measureTextWidth('Flutter') + 24.0;
      final wDart = TTableTheme.measureTextWidth('Dart') + 24.0;
      final wWidgets = TTableTheme.measureTextWidth('Widgets') + 24.0;
      final expected = wFlutter + wDart + wWidgets + 12.0;

      expect(estimatedWidth, equals(expected));
    });

    test('TTableHeader.chips computes auto widthEstimator with custom chip config and header fallbacks', () {
      final header = TTableHeader<SampleProduct, int>.chips(
        'Badges',
        (p) => [
          const TChip.solid(text: 'Pro', icon: Icons.star_rounded, color: Colors.amber),
          const TChip.tonal(text: 'Verified', icon: Icons.verified_rounded, color: Colors.blue),
          const TChip(text: 'Item'), // no icon on chip, but common fallback can provide one
        ],
        spacing: 4.0,
      );

      final estimatedWidth = header.widthEstimator!(product);
      final wPro = TTableTheme.measureTextWidth('Pro') + 24.0 + 18.0;
      final wVerified = TTableTheme.measureTextWidth('Verified') + 24.0 + 18.0;
      final wItem = TTableTheme.measureTextWidth('Item') + 24.0;
      final expected = wPro + wVerified + wItem + 8.0;

      expect(estimatedWidth, equals(expected));
    });

    test('TTableHeader.chips maps tags to comma-separated string for getValue', () {
      final header = TTableHeader<SampleProduct, int>.chips(
        'Tags',
        (p) => TChip.fromStrings(p.tags),
      );

      expect(header.getValue(product), equals('Flutter, Dart, Widgets'));
    });

    testWidgets('TTableHeader.chips renders TChip widgets with per-chip configs and merged fallbacks', (tester) async {
      final header = TTableHeader<SampleProduct, int>.chips(
        'Badges',
        (p) => [
          const TChip.solid(text: 'Pro', icon: Icons.star_rounded, color: Colors.amber),
          const TChip.tonal(text: 'Verified', color: Colors.blue),
          const TChip(text: 'Fallback Item'), // inherits header fallback type
        ],
        type: TVariant.outline,
        color: (data, text) => text == 'Fallback Item' ? Colors.grey : null,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final item = TListItem<SampleProduct, int>(data: product, key: 1);
                return header.builder!(context, item, 0);
              },
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(TChip), findsNWidgets(3));
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Fallback Item'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });
  });
}

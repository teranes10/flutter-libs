import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TSize / TChipSize Class Tests', () {
    test('TSize presets and copyWith work as expected', () {
      expect(TSize.xs.hPad, 6.0);
      expect(TSize.xs.vPad, 2.0);
      expect(TSize.xs.radius, 4.0);
      expect(TSize.xs.fontSize, 11.0);

      expect(TSize.sm.hPad, 10.0);
      expect(TSize.sm.vPad, 4.0);
      expect(TSize.sm.radius, 5.0);
      expect(TSize.sm.fontSize, 12.0);

      expect(TSize.md.hPad, 12.0);
      expect(TSize.md.vPad, 6.0);
      expect(TSize.md.radius, 6.0);

      expect(TSize.lg.hPad, 16.0);
      expect(TSize.lg.vPad, 8.0);
      expect(TSize.lg.radius, 8.0);

      final custom = TSize.sm.copyWith(radius: 12.0, hPad: 14.0);
      expect(custom.radius, 12.0);
      expect(custom.hPad, 14.0);
      expect(custom.vPad, 4.0);
      expect(custom.padding, const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0));
      expect(custom.borderRadius, BorderRadius.circular(12.0));
    });
  });

  group('TChip Widget Tests', () {
    testWidgets('TChip renders with auto-resolved primary color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TChip(text: 'Primary Auto'),
            ),
          ),
        ),
      );

      expect(find.text('Primary Auto'), findsOneWidget);
    });

    testWidgets('TChip with size TChipSize.sm, md, lg renders correct sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  const TChip(size: TChipSize.sm, text: 'Small', icon: Icons.star),
                  const TChip(size: TChipSize.md, text: 'Medium', icon: Icons.star),
                  const TChip(size: TChipSize.lg, text: 'Large', icon: Icons.star),
                  TChip(
                    size: TChipSize.sm.copyWith(radius: 16),
                    text: 'Custom Sized',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
      expect(find.text('Custom Sized'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(3));
    });

    testWidgets('TChip renders trailing TIcon.close and handles callback', (WidgetTester tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TChip(
                size: TChipSize.sm,
                text: 'Removable',
                trailing: TIcon.close(
                  size: 11,
                  padding: EdgeInsets.zero,
                  onTap: () {
                    deleted = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Removable'), findsOneWidget);
      expect(find.byType(TIcon), findsOneWidget);

      await tester.tap(find.byType(TIcon));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });
  });
}

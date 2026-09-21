import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TTileSize scale & presets (TSize)', () {
    test('verifies TTileSize constants are TSize instances with decreasing hierarchy', () {
      expect(TTileSize.h1, isA<TSize>());
      expect(TTileSize.h2, isA<TSize>());
      expect(TTileSize.h3, isA<TSize>());
      expect(TTileSize.h4, isA<TSize>());
      expect(TTileSize.h5, isA<TSize>());
      expect(TTileSize.h6, isA<TSize>());

      // Verify strict decreasing hierarchy of font sizes
      expect(TTileSize.h1.font, greaterThan(TTileSize.h2.font));
      expect(TTileSize.h2.font, greaterThan(TTileSize.h3.font));
      expect(TTileSize.h3.font, greaterThan(TTileSize.h4.font));
      expect(TTileSize.h4.font, greaterThan(TTileSize.h5.font));
      expect(TTileSize.h5.font, greaterThan(TTileSize.h6.font));

      // Verify icon sizes
      expect(TTileSize.h1.icon, greaterThan(TTileSize.h2.icon));
      expect(TTileSize.h2.icon, greaterThan(TTileSize.h3.icon));
      expect(TTileSize.h3.icon, greaterThan(TTileSize.h4.icon));
      expect(TTileSize.h4.icon, greaterThan(TTileSize.h5.icon));
      expect(TTileSize.h5.icon, greaterThan(TTileSize.h6.icon));

      // Verify default h5 values match standard tile dimensions
      expect(TTileSize.h5.font, 14.0);
      expect(TTileSize.h5.icon, 20.0);
      expect(TTileSize.h5.spacing, 12.0);
    });
  });

  group('TTile Size Widget Rendering', () {
    testWidgets('renders TTile with named constructors h1 to h6', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                TTile.h1(title: 'Heading 1', subtitle: 'Sub 1', icon: Icons.looks_one),
                TTile.h2(title: 'Heading 2', subtitle: 'Sub 2', icon: Icons.looks_two),
                TTile.h3(title: 'Heading 3', subtitle: 'Sub 3', icon: Icons.looks_3),
                TTile.h4(title: 'Heading 4', subtitle: 'Sub 4', icon: Icons.looks_4),
                TTile.h5(title: 'Heading 5', subtitle: 'Sub 5', icon: Icons.looks_5),
                TTile.h6(title: 'Heading 6', subtitle: 'Sub 6', icon: Icons.looks_6),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
      expect(find.text('Heading 3'), findsOneWidget);
      expect(find.text('Heading 4'), findsOneWidget);
      expect(find.text('Heading 5'), findsOneWidget);
      expect(find.text('Heading 6'), findsOneWidget);

      final h1Text = tester.widget<Text>(find.text('Heading 1'));
      final h6Text = tester.widget<Text>(find.text('Heading 6'));
      expect(h1Text.style?.fontSize, 24.0);
      expect(h6Text.style?.fontSize, 12.5);
    });

    testWidgets('renders TTile with TSize via size property', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TTile(
                size: TTileSize.h2,
                title: 'H2 Via Prop',
                subtitle: 'H2 Subtitle',
                icon: Icons.star,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('H2 Via Prop'));
      expect(textWidget.style?.fontSize, 20.0);
    });

    testWidgets('renders TTile with custom TSize', (tester) async {
      const customSize = TSize(font: 28.0, icon: 36.0, spacing: 18.0);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TTile(
                size: customSize,
                title: 'Custom TSize Title',
                subtitle: 'Custom TSize Subtitle',
                icon: Icons.star,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Custom TSize Title'));
      expect(textWidget.style?.fontSize, 28.0);
    });

    testWidgets('custom titleStyle overrides font size while keeping other defaults', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TTile.h1(
                title: 'Custom Title',
                titleStyle: TextStyle(fontSize: 30.0, color: Colors.purple),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Custom Title'));
      expect(textWidget.style?.fontSize, 30.0);
      expect(textWidget.style?.color, Colors.purple);
    });
  });
}

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

      // Verify product/image tile sizes
      expect(TTileSize.sm.icon, 50.0);
      expect(TTileSize.sm.font, 14.0);
      expect(TTileSize.md.icon, 75.0);
      expect(TTileSize.md.font, 16.0);
      expect(TTileSize.lg.icon, 100.0);
      expect(TTileSize.lg.font, 18.0);
    });
  });

  group('TTile Size Widget Rendering', () {
    testWidgets('renders TTile with named constructors h1 to h6 and sm, md, lg', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TTile.h1(title: 'Heading 1', subtitle: 'Sub 1', icon: HugeIcons.strokeRoundedOneSquare),
                  TTile.h2(title: 'Heading 2', subtitle: 'Sub 2', icon: HugeIcons.strokeRoundedTwoSquare),
                  TTile.h3(title: 'Heading 3', subtitle: 'Sub 3', icon: HugeIcons.strokeRoundedBook03),
                  TTile.h4(title: 'Heading 4', subtitle: 'Sub 4', icon: HugeIcons.strokeRoundedBook04),
                  TTile.h5(title: 'Heading 5', subtitle: 'Sub 5', icon: HugeIcons.strokeRoundedBlocks),
                  TTile.h6(title: 'Heading 6', subtitle: 'Sub 6', icon: HugeIcons.strokeRoundedBlocks),
                  TTile.sm(title: 'Product SM', subtitle: '50px img', icon: HugeIcons.strokeRoundedShoppingBag01),
                  TTile.md(title: 'Product MD', subtitle: '75px img', icon: HugeIcons.strokeRoundedShoppingBag01),
                  TTile.lg(title: 'Product LG', subtitle: '100px img', icon: HugeIcons.strokeRoundedShoppingBag01),
                ],
              ),
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
      expect(find.text('Product SM'), findsOneWidget);
      expect(find.text('Product MD'), findsOneWidget);
      expect(find.text('Product LG'), findsOneWidget);

      final h1Text = tester.widget<Text>(find.text('Heading 1'));
      final h6Text = tester.widget<Text>(find.text('Heading 6'));
      final smText = tester.widget<Text>(find.text('Product SM'));
      final mdText = tester.widget<Text>(find.text('Product MD'));
      final lgText = tester.widget<Text>(find.text('Product LG'));

      expect(h1Text.style?.fontSize, 24.0);
      expect(h6Text.style?.fontSize, 12.5);
      expect(smText.style?.fontSize, 14.0);
      expect(mdText.style?.fontSize, 16.0);
      expect(lgText.style?.fontSize, 18.0);
    });

    testWidgets('renders TTile with desc below subtitle when text height fits in image height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: TTile(
                size: TTileSize.lg,
                leading: SizedBox(key: Key('large-img'), width: 100, height: 100),
                title: 'Product Title',
                subtitle: 'Product Subtitle',
                desc: 'Short note fitting beside image',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Product Title'), findsOneWidget);
      expect(find.text('Product Subtitle'), findsOneWidget);
      expect(find.text('Short note fitting beside image'), findsOneWidget);

      final imgRight = tester.getTopRight(find.byKey(const Key('large-img'))).dx;
      final descTopLeft = tester.getTopLeft(find.text('Short note fitting beside image'));
      final imgBottom = tester.getBottomLeft(find.byKey(const Key('large-img'))).dy;

      // When it fits within image height, desc is beside the image (below subtitle)
      expect(descTopLeft.dx, greaterThan(imgRight));
      expect(descTopLeft.dy, lessThan(imgBottom));
    });

    testWidgets('renders TTile with desc below image when text height exceeds image height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: TTile(
                size: TTileSize.h6,
                leading: SizedBox(key: Key('small-img'), width: 20, height: 20),
                title: 'Product Title',
                subtitle: 'Product Subtitle',
                desc: 'Detailed product description exceeding small image height and moving below',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Product Title'), findsOneWidget);
      expect(find.text('Product Subtitle'), findsOneWidget);
      expect(find.text('Detailed product description exceeding small image height and moving below'), findsOneWidget);

      final imgBottom = tester.getBottomLeft(find.byKey(const Key('small-img'))).dy;
      final descTop = tester.getTopLeft(find.text('Detailed product description exceeding small image height and moving below'));
      final tileTopLeft = tester.getTopLeft(find.byType(TTile));

      // When text exceeds image height, desc is placed below the image spanning full width
      expect(descTop.dy, greaterThanOrEqualTo(imgBottom));
      expect(descTop.dx, equals(tileTopLeft.dx));
    });

    testWidgets('renders TTile with descWidget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TTile(
                title: 'Custom Desc Title',
                descWidget: Text('Custom Desc Widget'),
                icon: HugeIcons.strokeRoundedInformationCircle,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Desc Title'), findsOneWidget);
      expect(find.text('Custom Desc Widget'), findsOneWidget);
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
                icon: HugeIcons.strokeRoundedStar,
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
                icon: HugeIcons.strokeRoundedStar,
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

    testWidgets('verifies crossAxisAlignment defaults to CrossAxisAlignment.center', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: TTile(
                leading: SizedBox(key: Key('tile-img'), width: 50, height: 50),
                title: 'Product Title',
                subtitle: 'Product Subtitle',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('verifies TTile accepts explicit CrossAxisAlignment.start', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: TTile(
                crossAxisAlignment: CrossAxisAlignment.start,
                leading: SizedBox(key: Key('product-img'), width: 50, height: 50),
                title: 'Product Title',
                subtitle: 'Product Subtitle',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final imgTop = tester.getTopLeft(find.byKey(const Key('product-img'))).dy;
      final titleTop = tester.getTopLeft(find.text('Product Title')).dy;
      // In CrossAxisAlignment.start, the top coordinates of leading image and title text match
      expect(titleTop, equals(imgTop));
    });

    testWidgets('renders TTile with custom TTileSize instance overriding metrics', (tester) async {
      const customTileSize = TTileSize(
        font: 22.0,
        subtitleFont: 17.0,
        subtitleGap: 6.0,
        descFont: 15.0,
        descGap: 10.0,
      );

      // Verify custom TTileSize extends TSize
      expect(customTileSize, isA<TSize>());

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TTile(
                size: customTileSize,
                title: 'Custom Title',
                subtitle: 'Custom Subtitle',
                desc: 'Custom Desc',
                icon: HugeIcons.strokeRoundedStar,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleWidget = tester.widget<Text>(find.text('Custom Title'));
      final subWidget = tester.widget<Text>(find.text('Custom Subtitle'));
      final descWidget = tester.widget<Text>(find.text('Custom Desc'));

      expect(titleWidget.style?.fontSize, 22.0);
      expect(subWidget.style?.fontSize, 17.0);
      expect(descWidget.style?.fontSize, 15.0);
    });
  });

  group('TTileSize class methods and equality', () {
    test('verifies copyWith, equality and hashCode', () {
      const size1 = TTileSize(
        font: 16.0,
        subtitleFont: 13.0,
        subtitleGap: 3.0,
        descFont: 12.0,
        descGap: 5.0,
      );

      final size2 = size1.copyWith(subtitleFont: 14.0);
      expect(size2.subtitleFont, 14.0);
      expect(size2.descFont, 12.0);
      expect(size1 == size2, isFalse);

      final size3 = size1.copyWith();
      expect(size1 == size3, isTrue);
      expect(size1.hashCode == size3.hashCode, isTrue);
    });

    test('verifies resolution fallbacks for plain TSize vs TTileSize', () {
      const plainSize = TSize(font: 20.0, spacing: 10.0);
      // Plain TSize should fall back to switch/formula logic
      expect(plainSize.resolveSubtitleFontSize(), (20.0 * 0.85).clamp(10.0, 16.0));
      expect(plainSize.resolveSubtitleGap(), (20.0 * 0.15).clamp(1.5, 4.0));
      expect(plainSize.resolveDescFontSize(), (20.0 * 0.8).clamp(10.0, 15.0));
      expect(plainSize.resolveDescGap(), (10.0 * 0.5).clamp(4.0, 8.0));

      const customTileSize = TTileSize(
        font: 20.0,
        subtitleFont: 18.0,
        subtitleGap: 5.0,
        descFont: 16.0,
        descGap: 9.0,
      );
      expect(customTileSize.resolveSubtitleFontSize(), 18.0);
      expect(customTileSize.resolveSubtitleGap(), 5.0);
      expect(customTileSize.resolveDescFontSize(), 16.0);
      expect(customTileSize.resolveDescGap(), 9.0);
    });
  });
}

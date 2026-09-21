import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _SampleItem {
  final String id;
  final String title;
  final String subtitle;
  final double progress;

  const _SampleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
  });
}

void main() {
  final appTheme = TAppTheme.defaultTheme();
  final theme = appTheme.lightTheme;

  group('TTableScope contentTextStyle and header cell styles', () {
    testWidgets('TTableScope.contentTextStyle returns rowCardTheme in row mode and mobileCardTheme in card mode',
        (WidgetTester tester) async {
      final colors = ColorScheme.fromSeed(seedColor: Colors.blue);
      final customRowStyle = const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w300, color: Colors.blueGrey);
      final customCardStyle = const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400, color: Colors.teal);

      final tableTheme = TTableTheme.defaultTheme(colors).copyWith(
        rowCardTheme: TTableRowCardTheme.defaultTheme(colors).copyWith(
          contentTextStyle: customRowStyle,
        ),
        mobileCardTheme: TTableMobileCardTheme.defaultTheme(colors).copyWith(
          valueStyle: customCardStyle,
        ),
      );

      final controller = TListController<_SampleItem, String>(
        items: const [_SampleItem(id: '1', title: 'T', subtitle: 'S', progress: 0.5)],
        itemKey: (x) => x.id,
      );

      TextStyle? extractedRowStyle;
      TextStyle? extractedCardStyle;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TTableScope(
                  controller: controller,
                  dense: false,
                  isCardView: false,
                  theme: tableTheme,
                  child: Builder(
                    builder: (ctx) {
                      extractedRowStyle = TTableScope.maybeOf(ctx)?.contentTextStyle;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                TTableScope(
                  controller: controller,
                  dense: false,
                  isCardView: true,
                  theme: tableTheme,
                  child: Builder(
                    builder: (ctx) {
                      extractedCardStyle = TTableScope.maybeOf(ctx)?.contentTextStyle;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(extractedRowStyle, equals(customRowStyle));
      expect(extractedCardStyle, equals(customCardStyle));
    });

    testWidgets('TTableHeader.keyValues uses contentTextStyle with key font weight one step thicker and adaptive contrast 0.1',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final customContentStyle = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: Color(0xFF222222));
      final colors = ColorScheme.fromSeed(seedColor: Colors.blue);
      final tableTheme = TTableTheme.defaultTheme(colors).copyWith(
        rowCardTheme: TTableRowCardTheme.defaultTheme(colors).copyWith(
          contentTextStyle: customContentStyle,
        ),
      );

      final headers = [
        TTableHeader<_SampleItem, String>.keyValues(
          'Details',
          (item) => [
            TKeyValue('Status', value: 'Active'),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TTable<_SampleItem, String>(
                theme: tableTheme,
                headers: headers,
                items: const [_SampleItem(id: '1', title: 'T', subtitle: 'S', progress: 0.75)],
                itemKey: (x) => x.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final keyTextFinder = find.text('Status: ');
      expect(keyTextFinder, findsOneWidget);
      final Text keyText = tester.widget(keyTextFinder);
      expect(keyText.style?.fontWeight, equals(FontWeight.w400)); // w300 -> one step thicker = w400

      final valueTextFinder = find.text('Active');
      expect(valueTextFinder, findsOneWidget);
      final Text valueText = tester.widget(valueTextFinder);
      expect(valueText.style?.fontWeight, equals(FontWeight.w300));
      expect(valueText.style?.fontSize, equals(14.0));
    });

    testWidgets('TTableHeader.tile uses contentTextStyle for title and muted adaptive contrast for subtitle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final customContentStyle = const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Color(0xFF111111));
      final colors = ColorScheme.fromSeed(seedColor: Colors.blue);
      final tableTheme = TTableTheme.defaultTheme(colors).copyWith(
        rowCardTheme: TTableRowCardTheme.defaultTheme(colors).copyWith(
          contentTextStyle: customContentStyle,
        ),
      );

      final headers = [
        TTableHeader<_SampleItem, String>.tile(
          'Item',
          (x) => x.title,
          subtitle: (x) => x.subtitle,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TTable<_SampleItem, String>(
                theme: tableTheme,
                headers: headers,
                items: const [_SampleItem(id: '1', title: 'Main Title', subtitle: 'Sub Title', progress: 0.5)],
                itemKey: (x) => x.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final titleFinder = find.text('Main Title');
      expect(titleFinder, findsOneWidget);
      final Text titleText = tester.widget(titleFinder);
      expect(titleText.style?.fontSize, equals(15.0 * 1.015));

      final subtitleFinder = find.text('Sub Title');
      expect(subtitleFinder, findsOneWidget);
      final Text subtitleText = tester.widget(subtitleFinder);
      expect(subtitleText.style?.fontSize, equals(15.0 * 0.85));
    });

    testWidgets('TTableHeader.progress uses contentTextStyle for value text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final customContentStyle = const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400, color: Colors.indigo);
      final colors = ColorScheme.fromSeed(seedColor: Colors.blue);
      final tableTheme = TTableTheme.defaultTheme(colors).copyWith(
        rowCardTheme: TTableRowCardTheme.defaultTheme(colors).copyWith(
          contentTextStyle: customContentStyle,
        ),
      );

      final headers = [
        TTableHeader<_SampleItem, String>.progress(
          'Completion',
          (x) => x.progress,
          showPercentage: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TTable<_SampleItem, String>(
                theme: tableTheme,
                headers: headers,
                items: const [_SampleItem(id: '1', title: 'T', subtitle: 'S', progress: 0.5)],
                itemKey: (x) => x.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final percentFinder = find.text('50%');
      expect(percentFinder, findsOneWidget);
      final Text percentText = tester.widget(percentFinder);
      expect(percentText.style?.fontSize, equals(13.5 * 0.8));
      expect(percentText.style?.color, equals(theme.colorScheme.primary.toMaterial().shade400));
    });
  });
}

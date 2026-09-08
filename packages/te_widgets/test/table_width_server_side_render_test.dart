import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _Product {
  final String id;
  final String description;

  const _Product({required this.id, required this.description});
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TTable & TDataTable server-side column width calculation on items', () {
    testWidgets('TTable recalculates column widths on items when onLoad data arrives asynchronously', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<TLoadResult<_Product>>();

      final headers = [
        TTableHeader<_Product, String>.map('ID', (p) => p.id),
        TTableHeader<_Product, String>.map('Description', (p) => p.description),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TTable<_Product, String>(
                headers: headers,
                itemKey: (p) => p.id,
                onLoad: (options) => completer.future,
              ),
            ),
          ),
        ),
      );

      // Initial frame: data has not arrived yet.
      await tester.pump();

      // Find the header Table widget
      final headerTableFinder = find.byType(Table).first;
      Table headerTable = tester.widget(headerTableFinder);
      final initialWidths = headerTable.columnWidths!;
      final initialIdWidth = (initialWidths[0] as FixedColumnWidth).value;
      final initialDescWidth = (initialWidths[1] as FixedColumnWidth).value;

      expect(initialIdWidth, isPositive);
      expect(initialDescWidth, isPositive);

      // Now server response arrives with items having a moderately long description
      completer.complete(
        const TLoadResult<_Product>(
          [
            _Product(
              id: '1',
              description: 'Standard product description text',
            ),
            _Product(
              id: '2',
              description: 'Another product with detailed description',
            ),
          ],
          2,
          hasNextPage: false,
        ),
      );

      // Wait for future and rebuild
      await tester.pumpAndSettle();

      // Verify items are displayed in table view
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Standard product description text'), findsOneWidget);

      // Find header table again after items loaded
      expect(find.byType(Table), findsWidgets);
      headerTable = tester.widget(headerTableFinder);
      final updatedWidths = headerTable.columnWidths!;
      final updatedIdWidth = (updatedWidths[0] as FixedColumnWidth).value;
      final updatedDescWidth = (updatedWidths[1] as FixedColumnWidth).value;

      // Description column should now be significantly wider than ID column
      // because calculation on items correctly updated upon data arrival.
      expect(updatedDescWidth, greaterThan(updatedIdWidth * 2));
    });

    testWidgets('TTable switches to card view if async loaded items exceed available width', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<TLoadResult<_Product>>();

      final headers = [
        TTableHeader<_Product, String>.map('ID', (p) => p.id),
        TTableHeader<_Product, String>.map('Description', (p) => p.description),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 600,
              child: TTable<_Product, String>(
                headers: headers,
                itemKey: (p) => p.id,
                onLoad: (options) => completer.future,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      // Initially, with only headers, fits within 500px -> table view
      expect(find.byType(Table), findsWidgets);

      completer.complete(
        const TLoadResult<_Product>(
          [
            _Product(
              id: '1',
              description: 'This is an extraordinarily lengthy product explanation that demands enormous width way beyond five hundred pixels',
            ),
          ],
          1,
          hasNextPage: false,
        ),
      );

      await tester.pumpAndSettle();

      // Now with items, requiredWidth > 500px -> automatically switches to card view!
      expect(find.byType(TTableMobileCard<_Product, String>), findsOneWidget);
    });

    testWidgets('TDataTable recalculates column widths on items when onLoad data arrives asynchronously', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<TLoadResult<_Product>>();

      final headers = [
        TTableHeader<_Product, String>.map('ID', (p) => p.id),
        TTableHeader<_Product, String>.map('Description', (p) => p.description),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TDataTable<_Product, String>(
                headers: headers,
                itemKey: (p) => p.id,
                itemsPerPage: 10,
                onLoad: (options) => completer.future,
              ),
            ),
          ),
        ),
      );

      // Initial frame: data is loading
      await tester.pump();

      completer.complete(
        const TLoadResult<_Product>(
          [
            _Product(
              id: '10',
              description: 'Enterprise deployment specification documentation',
            ),
          ],
          1,
          hasNextPage: false,
        ),
      );

      await tester.pumpAndSettle();

      final headerTableFinder = find.byType(Table).first;
      final Table headerTable = tester.widget(headerTableFinder);
      final widths = headerTable.columnWidths!;
      final idWidth = (widths[0] as FixedColumnWidth).value;
      final descWidth = (widths[1] as FixedColumnWidth).value;

      // Description should have received much more width than ID column based on item content
      expect(descWidth, greaterThan(idWidth * 2));
    });

    testWidgets('TTableHeader widthEstimator takes priority over map and defaults', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final headers = [
        TTableHeader<_Product, String>.map(
          'Custom',
          (p) => 'short',
          widthEstimator: (p) => 300.0,
        ),
        TTableHeader<_Product, String>(
          'Fallback',
          widthEstimator: (p) => 250.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TTable<_Product, String>(
                headers: headers,
                items: const [
                  _Product(id: '1', description: 'desc'),
                ],
                itemKey: (p) => p.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final headerTableFinder = find.byType(Table).first;
      final Table headerTable = tester.widget(headerTableFinder);
      final widths = headerTable.columnWidths!;
      final customWidth = (widths[0] as FixedColumnWidth).value;
      final fallbackWidth = (widths[1] as FixedColumnWidth).value;

      // Both should be sized according to widthEstimator (plus padding/breathing room)
      expect(customWidth, greaterThanOrEqualTo(324.0));
      expect(fallbackWidth, greaterThanOrEqualTo(274.0));
    });

    testWidgets('TTableHeader.values and TTableHeader.keyValues calculate column widths via default widthEstimator',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final headers = [
        TTableHeader<_Product, String>.values(
          'Values Column',
          (p) => [
            TKeyValue('Key 1', value: 'First line short'),
            TKeyValue('Key 2', value: 'Secondary line description value'),
          ],
        ),
        TTableHeader<_Product, String>.keyValues(
          'KeyValues Column',
          (p) => [
            TKeyValue('Param', value: 'Configuration value text'),
          ],
        ),
      ];

      final product = const _Product(id: '1', description: 'desc');

      // Test widthEstimator functions directly
      expect(headers[0].widthEstimator, isNotNull);
      expect(headers[1].widthEstimator, isNotNull);

      final valuesEstimatedWidth = headers[0].widthEstimator!(product);
      final keyValuesEstimatedWidth = headers[1].widthEstimator!(product);

      expect(valuesEstimatedWidth, greaterThan(50.0));
      expect(keyValuesEstimatedWidth, greaterThan(50.0));

      final columnWidths = TTableTheme.calculateColumnWidths<_Product, String>(
        headers,
        false,
        false,
        sampleItems: [product],
        availableWidth: 1000,
      );

      final valuesColWidth = (columnWidths[0] as FixedColumnWidth).value;
      final keyValuesColWidth = (columnWidths[1] as FixedColumnWidth).value;

      expect(valuesColWidth, greaterThanOrEqualTo(valuesEstimatedWidth + 24.0));
      expect(keyValuesColWidth, greaterThanOrEqualTo(keyValuesEstimatedWidth + 24.0));

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TTable<_Product, String>(
                headers: headers,
                items: [product],
                itemKey: (p) => p.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final headerTableFinder = find.byType(Table).first;
      final Table headerTable = tester.widget(headerTableFinder);
      final widths = headerTable.columnWidths!;
      expect((widths[0] as FixedColumnWidth).value, greaterThan(50.0));
      expect((widths[1] as FixedColumnWidth).value, greaterThan(50.0));
    });

    testWidgets('TTableMobileCard maintains horizontal gap between progress bar cell and adjacent rating cell',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final headers = [
        TTableHeader<_Product, String>.progress(
          'Fulfillment',
          (p) => 0.66,
          valueText: (p) => '99/150',
          showPercentage: true,
        ),
        TTableHeader<_Product, String>.rating(
          'Rating',
          (p) => 2.0,
        ),
      ];

      final product = const _Product(id: '1', description: 'desc');

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              height: 400,
              child: TTableMobileCard<_Product, String>(
                index: 0,
                item: TListItem(key: product.id, data: product),
                headers: headers,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final fulfillmentFinder = find.text('Fulfillment');
      final ratingFinder = find.textContaining('Rating');

      expect(fulfillmentFinder, findsOneWidget);
      expect(ratingFinder, findsOneWidget);

      final fulfillmentRect = tester.getRect(fulfillmentFinder);
      final ratingRect = tester.getRect(ratingFinder);

      if (fulfillmentRect.top == ratingRect.top) {
        // Verify that the rating label is strictly to the right of fulfillment with a positive gap
        expect(ratingRect.left, greaterThan(fulfillmentRect.right));
      } else {
        expect(ratingRect.top, greaterThanOrEqualTo(fulfillmentRect.bottom));
      }
    });
  });
}

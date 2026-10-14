import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/pages/selection_controls_page.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('SelectionControlsPage renders all sections and handles interaction', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final theme = TAppTheme.defaultTheme().lightTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: SelectionControlsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify page header
    expect(find.text('Selection Controls & Option Tiles'), findsOneWidget);

    // Verify TOptionTile elements
    expect(find.text('Credit / Debit Card'), findsOneWidget);
    expect(find.text('Digital Wallet'), findsOneWidget);
    expect(find.text('Package Insurance'), findsOneWidget);
    expect(find.text('Real-time GPS Tracking'), findsOneWidget);
    expect(find.text('Order Status Alerts'), findsOneWidget);

    // Verify Tile Mode groups
    expect(find.text('Express Delivery'), findsOneWidget);
    expect(find.text('Fragile Handling'), findsOneWidget);
    expect(find.text('Economy (5-7 business days)'), findsOneWidget);
    expect(find.text('Offline Data Sync'), findsOneWidget);
    expect(find.text('Biometric Authentication'), findsOneWidget);

    // Verify standard controls
    expect(find.text('I agree to the terms and conditions'), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Enable Notifications'), findsOneWidget);

    // Tap on an option tile
    await tester.tap(find.text('Digital Wallet'));
    await tester.pumpAndSettle();

    // Tap on an option tile with check
    await tester.tap(find.text('Package Insurance'));
    await tester.pumpAndSettle();

    // Tap on a tile-mode switch
    await tester.tap(find.text('Offline Data Sync'));
    await tester.pumpAndSettle();
  });
}

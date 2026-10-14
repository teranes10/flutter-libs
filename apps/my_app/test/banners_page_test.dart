import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/pages/banners_page.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('BannersPage renders all sections including TBanner.offline and icon size samples', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
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
          body: BannersPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and doc cards
    expect(find.text('Alert Banners & Callouts'), findsOneWidget);
    expect(find.text('Semantic Types (Info, Success, Warning, Error, Neutral)'), findsOneWidget);
    expect(find.text('Visual Variants (tonal, softOutline, outline, solid)'), findsOneWidget);
    expect(find.text('Action Button & Dismiss Action'), findsOneWidget);
    expect(find.text('Offline & Sync Status Banner (TBanner.offline)'), findsOneWidget);
    expect(find.text('Icon Sizing & Vertical Centering Alignment'), findsOneWidget);

    // Verify offline state switcher buttons
    expect(find.text('Offline Notice'), findsOneWidget);
    expect(find.text("You're offline"), findsOneWidget);

    // Switch to Actively Syncing (use pump instead of pumpAndSettle due to indeterminate CircularProgressIndicator)
    await tester.tap(find.text('Actively Syncing'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Syncing 6 changes…'), findsOneWidget);

    // Switch to Pending Sync
    await tester.tap(find.text('Pending Sync'));
    await tester.pumpAndSettle();
    expect(find.text('5 changes waiting to sync'), findsOneWidget);

    // Switch to Sync Error
    await tester.tap(find.text('Sync Error'));
    await tester.pumpAndSettle();
    expect(find.text('Sync failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Switch to Fully Synced
    await tester.tap(find.text('Fully Synced (Hidden)'));
    await tester.pumpAndSettle();
    expect(find.text('TBanner.offline returns SizedBox.shrink() when fully synced.'), findsOneWidget);

    // Test sticky toggle
    await tester.tap(find.byType(TSwitch));
    await tester.pumpAndSettle();
  });
}

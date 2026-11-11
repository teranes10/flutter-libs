import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

// 1x1 transparent PNG.
final _png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  testWidgets('preview opens a zoomable viewer; double-tap zooms in and back out', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: TImage(bytes: _png, size: 80))),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TImage));
    await tester.pumpAndSettle();

    final viewer = find.byType(InteractiveViewer);
    expect(viewer, findsOneWidget);
    InteractiveViewer widget() => tester.widget<InteractiveViewer>(viewer);
    double scale() => widget().transformationController!.value.getMaxScaleOnAxis();
    expect(scale(), 1.0);

    final center = tester.getCenter(viewer);
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center);
    await tester.pumpAndSettle();
    expect(scale(), closeTo(2.5, 0.01));

    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center);
    await tester.pumpAndSettle();
    expect(scale(), 1.0);
  });
}

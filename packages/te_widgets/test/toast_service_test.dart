import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  Future<BuildContext> pumpApp(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })),
    ));
    return ctx;
  }

  testWidgets('shows stacked toasts and auto-dismisses', (tester) async {
    final ctx = await pumpApp(tester);

    TToastService.success(ctx, 'First', 'T1');
    TToastService.error(ctx, 'Second');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('close button dismisses and hover pauses auto-close', (tester) async {
    final ctx = await pumpApp(tester);

    TToastService.info(ctx, 'Hello', null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Hello')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Hello'), findsOneWidget);

    await mouse.removePointer();
    await tester.tap(find.byType(TButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('hover resumes the countdown instead of restarting it', (tester) async {
    final ctx = await pumpApp(tester);

    TToastService.info(ctx, 'Resume me');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 2)); // ~2.3s of 3s elapsed

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Resume me')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Resume me'), findsOneWidget);

    await mouse.moveTo(const Offset(1, 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // only ~0.7s were left
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Resume me'), findsNothing);
  });

  testWidgets('identical toasts merge into one with a count badge', (tester) async {
    final ctx = await pumpApp(tester);

    TToastService.info(ctx, 'Same');
    TToastService.info(ctx, 'Same');
    TToastService.info(ctx, 'Same');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Same'), findsOneWidget);
    expect(find.text('×3'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('caps visible toasts, dismissing the oldest', (tester) async {
    final ctx = await pumpApp(tester);

    for (var i = 1; i <= 6; i++) {
      TToastService.info(ctx, 'Msg $i');
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Msg 1'), findsNothing);
    expect(find.text('Msg 2'), findsNothing);
    expect(find.text('Msg 3'), findsOneWidget);
    expect(find.text('Msg 6'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('swiping a toast dismisses it', (tester) async {
    final ctx = await pumpApp(tester);

    TToastService.info(ctx, 'Swipe me');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.drag(find.text('Swipe me'), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Swipe me'), findsNothing);
  });
}

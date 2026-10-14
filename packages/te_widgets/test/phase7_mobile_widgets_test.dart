import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:te_widgets/te_widgets.dart';

/// Mobile / handheld widget behaviour. All tests run on a 360x760 phone
/// viewport and assert touch targets are at least 48dp.
void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  Future<void> pumpMobile(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('sizes', () {
    test('TSize.xl is a 56dp handheld size', () {
      expect(TSize.xl.minH, 56);
      expect(TSize.xl.font, 18);
    });

    testWidgets('TChipSize.xl chip is at least 48dp tall', (tester) async {
      await pumpMobile(tester, const TChip(text: 'Damaged', size: TChipSize.xl));
      expect(tester.getSize(find.byType(TChip)).height, greaterThanOrEqualTo(48));
    });

    testWidgets('default TChip height is unchanged by xl support', (tester) async {
      await pumpMobile(tester, const TChip(text: 'Small'));
      expect(tester.getSize(find.byType(TChip)).height, lessThan(30));
    });
  });

  group('TNumberField quantity', () {
    testWidgets('steps with 64dp buttons and clamps to min/max', (tester) async {
      int? latest;
      await pumpMobile(
        tester,
        SizedBox(
          width: 320,
          child: TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            value: 2,
            min: 0,
            max: 3,
            onValueChanged: (v) => latest = v,
          ),
        ),
      );

      final plus = find.byIcon(Icons.add_rounded);
      final minus = find.byIcon(Icons.remove_rounded);
      expect(tester.getSize(find.ancestor(of: plus, matching: find.byType(Container)).first).shortestSide, greaterThanOrEqualTo(48));

      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect(latest, 3);

      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect(latest, 3, reason: 'clamped to max');

      await tester.tap(minus);
      await tester.pumpAndSettle();
      expect(latest, 2);
    });

    testWidgets('preset chips add and Max jumps to the limit', (tester) async {
      int? latest;
      await pumpMobile(
        tester,
        SizedBox(
          width: 320,
          child: TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            value: 0,
            max: 12,
            presets: const [5],
            onValueChanged: (v) => latest = v,
          ),
        ),
      );

      await tester.tap(find.text('+5'));
      await tester.pumpAndSettle();
      expect(latest, 5);

      await tester.tap(find.text('Max'));
      await tester.pumpAndSettle();
      expect(latest, 12);
    });

    testWidgets('quantity mode button size uses TInputSize -> TSize.fromInputSize and preset chip is 0.8 scale', (tester) async {
      await pumpMobile(
        tester,
        SizedBox(
          width: 320,
          child: TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            size: TInputSize.lg,
            value: 5,
            max: 10,
            presets: const [1],
          ),
        ),
      );

      final plusIcon = find.byIcon(Icons.add_rounded);
      final buttonContainer = find.ancestor(of: plusIcon, matching: find.byType(Container)).first;
      final btnSize = tester.getSize(buttonContainer);
      expect(btnSize.width, 56.0);
      expect(btnSize.height, 56.0);

      final chipFinder = find.byType(TChip).first;
      final chipSize = tester.getSize(chipFinder);
      expect(chipSize.height, closeTo(56.0 * 0.8, 1.0));
    });

    testWidgets('quantity mode label aligns to start and center value text uses onSurface color', (tester) async {
      await pumpMobile(
        tester,
        const SizedBox(
          width: 320,
          child: TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            label: 'Picked items',
            value: 7,
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Picked items'));
      expect(labelText.textAlign, TextAlign.start);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.color, theme.colorScheme.onSurface);
    });

    testWidgets('typing value exceeding max is blocked, typing below min clamps on enter', (tester) async {
      int? latest;
      await pumpMobile(
        tester,
        SizedBox(
          width: 320,
          child: TNumberField<int>(
            variant: TNumberFieldVariant.quantity,
            value: 2,
            min: 2,
            max: 5,
            onValueChanged: (v) => latest = v,
          ),
        ),
      );

      final textField = find.byType(TextField);
      // Attempting to type 9 (exceeds max: 5) is blocked
      await tester.enterText(textField, '9');
      await tester.pumpAndSettle();
      expect(find.text('9'), findsNothing);

      // Typing 4 (within min 2, max 5) is accepted
      await tester.enterText(textField, '4');
      await tester.pumpAndSettle();
      expect(latest, 4);

      // Typing 1 (below min 2) then pressing enter clamps to min (2)
      await tester.enterText(textField, '1');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(latest, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('standard TNumberField blocks out of bounds chars and clamps on submit', (tester) async {
      int? latest;
      await pumpMobile(
        tester,
        SizedBox(
          width: 320,
          child: TNumberField<int>(
            value: 5,
            min: 3,
            max: 10,
            onValueChanged: (v) => latest = v,
          ),
        ),
      );

      final textField = find.byType(TextField);
      // Typing '-' when min is 3 (>= 0) is blocked
      await tester.enterText(textField, '-');
      await tester.pumpAndSettle();
      expect(find.text('-'), findsNothing);

      // Typing 99 when max is 10 is blocked
      await tester.enterText(textField, '99');
      await tester.pumpAndSettle();
      expect(find.text('99'), findsNothing);

      // Typing 1 (< min 3) then pressing Enter clamps to 3
      await tester.enterText(textField, '1');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(latest, 3);
      expect(find.text('3'), findsOneWidget);
    });
  });
  group('TTextField.scan', () {
    testWidgets('submit fires onScan, clears the field and keeps focus', (tester) async {
      final scans = <String>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await pumpMobile(
        tester,
        SizedBox(width: 320, child: TTextField.scan(label: 'Scan', focusNode: focusNode, onScan: scans.add)),
      );

      await tester.enterText(find.byType(TextField), ' 12345 ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(scans, ['12345'], reason: 'trimmed barcode delivered once');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('camera button is at least 48dp and fires onCameraTap', (tester) async {
      var cameraTaps = 0;
      await pumpMobile(
        tester,
        SizedBox(width: 320, child: TTextField.scan(onScan: (_) {}, onCameraTap: () => cameraTaps++)),
      );

      final button = find.byIcon(Icons.qr_code_scanner_rounded);
      expect(tester.getSize(find.ancestor(of: button, matching: find.byType(IconButton))).shortestSide, greaterThanOrEqualTo(48));
      await tester.tap(button);
      expect(cameraTaps, 1);
    });
  });

  group('TActionBar', () {
    testWidgets('primary action is 56dp tall, full width and fires', (tester) async {
      var confirmed = 0;
      var skipped = 0;
      await pumpMobile(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: TActionBar(
            primaryText: 'Confirm',
            onPrimary: () => confirmed++,
            secondaryText: 'Skip',
            onSecondary: () => skipped++,
          ),
        ),
      );

      final primary = find.byKey(const ValueKey('t-action-bar-primary'));
      expect(tester.getSize(primary).height, greaterThanOrEqualTo(56));
      expect(tester.getSize(find.byKey(const ValueKey('t-action-bar-secondary'))).height, greaterThanOrEqualTo(56));

      await tester.tap(primary);
      await tester.tap(find.byKey(const ValueKey('t-action-bar-secondary')));
      expect(confirmed, 1);
      expect(skipped, 1);
    });

    testWidgets('works as TPageWrapper footer without overflow', (tester) async {
      await pumpMobile(
        tester,
        SizedBox(
          width: 360,
          height: 700,
          child: TPageWrapper(
            title: 'Confirm quantity',
            footer: TActionBar(primaryText: 'Confirm', onPrimary: () {}),
            child: const SizedBox(height: 900),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('stacks onto two lines with primary first (0.9h) and secondary below (0.75h) when space constrained', (tester) async {
      var primaryPressed = 0;
      var secondaryPressed = 0;

      await pumpMobile(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: TActionBar(
            primaryText: 'View next order',
            onPrimary: () => primaryPressed++,
            secondaryText: 'Back to tasks',
            onSecondary: () => secondaryPressed++,
          ),
        ),
      );

      final primaryFinder = find.byKey(const ValueKey('t-action-bar-primary'));
      final secondaryFinder = find.byKey(const ValueKey('t-action-bar-secondary'));

      expect(tester.takeException(), isNull);

      final primaryRect = tester.getRect(primaryFinder);
      final secondaryRect = tester.getRect(secondaryFinder);

      // Primary action is first on top, secondary action is below
      expect(secondaryRect.top, greaterThanOrEqualTo(primaryRect.bottom), reason: 'secondary action is below primary on two lines');
      // Height scaling: primary is 0.9 (50.4), secondary is 0.75 (42.0)
      expect(primaryRect.height, closeTo(56 * 0.9, 1.0), reason: 'primary height scaled to 0.9');
      expect(secondaryRect.height, closeTo(56 * 0.75, 1.0), reason: 'secondary height scaled to 0.75');

      // Both actions span the available width (360 - 32 = 328)
      expect(primaryRect.width, closeTo(328, 1));
      expect(secondaryRect.width, closeTo(328, 1));

      // Both buttons are interactive
      await tester.tap(primaryFinder);
      await tester.tap(secondaryFinder);
      expect(primaryPressed, 1);
      expect(secondaryPressed, 1);
    });

    testWidgets('stays on single row on wide viewport even with longer labels', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: TActionBar(
                primaryText: 'View next order',
                onPrimary: () {},
                secondaryText: 'Back to tasks',
                onSecondary: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final primaryRect = tester.getRect(find.byKey(const ValueKey('t-action-bar-primary')));
      final secondaryRect = tester.getRect(find.byKey(const ValueKey('t-action-bar-secondary')));

      // Both buttons are side-by-side (same vertical position)
      expect(primaryRect.top, equals(secondaryRect.top), reason: 'side-by-side on wide viewport');
      expect(primaryRect.left, greaterThan(secondaryRect.right));
    });
  });

  group('TTile.task', () {
    testWidgets('renders status, progress and is a tappable 72dp+ card', (tester) async {
      var taps = 0;
      await pumpMobile(
        tester,
        SizedBox(
          width: 340,
          child: TTile.task(
            title: 'SO-10452',
            subtitle: '12 lines · 5 items',
            meta: 'Due today 3:00 PM',
            status: 'Picking',
            done: 4,
            total: 12,
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('SO-10452'), findsOneWidget);
      expect(find.text('Picking'), findsOneWidget);
      expect(find.text('4 / 12'), findsOneWidget);
      expect(tester.getSize(find.byType(InkWell).first).height, greaterThanOrEqualTo(72));

      await tester.tap(find.text('SO-10452'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('TBanner.offline', () {
    testWidgets('renders nothing when fully synced', (tester) async {
      await pumpMobile(tester, TBanner.offline(online: true));
      expect(find.byType(TBanner), findsNothing);
    });

    testWidgets('offline shows pending count and View pending (48dp) action', (tester) async {
      var viewed = 0;
      await pumpMobile(
        tester,
        SizedBox(
          width: 340,
          child: TBanner.offline(online: false, pendingCount: 7, onViewPending: () => viewed++),
        ),
      );

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.textContaining('7 pending'), findsOneWidget);
      final action = find.text('View pending');
      expect(tester.getSize(find.ancestor(of: action, matching: find.byType(TButton)).first).height, greaterThanOrEqualTo(48));
      await tester.tap(action);
      expect(viewed, 1);
    });

    testWidgets('error shows Retry', (tester) async {
      var retried = 0;
      await pumpMobile(
        tester,
        SizedBox(width: 340, child: TBanner.offline(online: true, error: 'Server unreachable', onRetry: () => retried++)),
      );
      expect(find.text('Sync failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, 1);
    });
  });

  group('TBottomBar', () {
    testWidgets('shows badge count, taps with 48dp+ targets and supports an emphasised Scan item', (tester) async {
      var selected = -1;
      await pumpMobile(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: TBottomBar(
            currentIndex: 0,
            haptic: false,
            textPosition: TBottomBarTextPosition.bottomAlways,
            onTap: (i) => selected = i,
            items: const [
              TBottomBarItem(icon: Icons.home_rounded, label: 'Home'),
              TBottomBarItem(icon: Icons.checklist_rounded, label: 'Tasks', badge: 4),
              TBottomBarItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan', emphasized: true),
              TBottomBarItem(icon: Icons.more_horiz_rounded, label: 'More'),
            ],
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget, reason: 'tasks badge count');
      expect(tester.getSize(find.ancestor(of: find.text('Tasks'), matching: find.byType(AnimatedContainer)).first).height, greaterThanOrEqualTo(48));

      await tester.tap(find.text('Scan'));
      expect(selected, 2);
      await tester.tap(find.text('Tasks'));
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('TTabs', () {
    testWidgets('shows count pills, 48dp tabs on mobile and switches value', (tester) async {
      String selected = 'all';
      await pumpMobile(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: TTabs<String>(
              selectedValue: selected,
              onTabChanged: (v) => setState(() => selected = v),
              tabs: const [
                TTab(value: 'all', text: 'All', count: 12),
                TTab(value: 'progress', text: 'In Progress', count: 2),
                TTab(value: 'overdue', text: 'Overdue', count: 1),
              ],
            ),
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(tester.getSize(find.ancestor(of: find.text('All'), matching: find.byType(InkWell)).first).height, greaterThanOrEqualTo(48));

      await tester.tap(find.text('In Progress'));
      await tester.pumpAndSettle();
      expect(selected, 'progress');
      expect(tester.takeException(), isNull);
    });
  });

  group('tile mode inputs', () {
    testWidgets('TRadioGroup(tile) renders 56dp rows and selects on tap', (tester) async {
      String? picked;
      await pumpMobile(
        tester,
        SizedBox(
          width: 340,
          child: TRadioGroup<String>(
            tile: true,
            onValueChanged: (v) => picked = v,
            items: const [
              TRadioGroupItem(value: 'unavailable', label: 'Customer unavailable'),
              TRadioGroupItem(value: 'refused', label: 'Customer refused'),
            ],
          ),
        ),
      );

      expect(find.byType(TOptionTile), findsNWidgets(2));
      expect(tester.getSize(find.byType(TOptionTile).first).height, greaterThanOrEqualTo(56));

      await tester.tap(find.text('Customer refused'));
      await tester.pumpAndSettle();
      expect(picked, 'refused');
    });

    testWidgets('TCheckboxGroup(tile) toggles multiple options', (tester) async {
      List<String>? picked;
      await pumpMobile(
        tester,
        SizedBox(
          width: 340,
          child: TCheckboxGroup<String>(
            tile: true,
            onValueChanged: (v) => picked = v,
            items: const [
              TCheckboxGroupItem(value: 'a', label: 'Package 1'),
              TCheckboxGroupItem(value: 'b', label: 'Package 2'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Package 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Package 2'));
      await tester.pumpAndSettle();
      expect(picked, containsAll(['a', 'b']));
    });

    testWidgets('TSwitch(tile) is a 56dp row that toggles', (tester) async {
      bool? on;
      await pumpMobile(
        tester,
        SizedBox(
          width: 340,
          child: TSwitch(tile: true, label: 'Urgent delivery', description: 'Deliver first', onValueChanged: (v) => on = v),
        ),
      );

      expect(tester.getSize(find.byType(TOptionTile)).height, greaterThanOrEqualTo(56));
      await tester.tap(find.text('Urgent delivery'));
      await tester.pumpAndSettle();
      expect(on, isTrue);
    });
  });

  group('TResult docked', () {
    testWidgets('full-page docked result keeps actions in a bottom bar', (tester) async {
      var next = 0;
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TResult.success(
            title: 'Picking completed!',
            subtitle: 'SO-10452',
            fullPage: true,
            docked: true,
            extra: const Text('12 / 12 lines'),
            primaryAction: TButton(text: 'View next order', size: TSize.xl, onTap: () => next++),
            secondaryAction: TButton(text: 'Back to tasks', type: TButtonType.outline, size: TSize.xl, onTap: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('12 / 12 lines'), findsOneWidget);
      final buttonRect = tester.getRect(find.text('View next order'));
      expect(buttonRect.bottom, greaterThan(600), reason: 'action sits near the bottom of a 760dp screen');
      await tester.tap(find.text('View next order'));
      expect(next, 1);
    });
  });

  group('TSignaturePad', () {
    testWidgets('drawing marks the pad signed, clear resets, PNG exports', (tester) async {
      final controller = TSignaturePadController();
      final changes = <bool>[];
      await pumpMobile(
        tester,
        SizedBox(width: 320, child: TSignaturePad(controller: controller, onChanged: changes.add)),
      );

      expect(controller.isEmpty, isTrue);
      expect(find.text('Sign here'), findsOneWidget);

      final pad = find.byType(TSignaturePad);
      final gesture = await tester.startGesture(tester.getCenter(pad) - const Offset(80, 0));
      await gesture.moveBy(const Offset(40, 30));
      await gesture.moveBy(const Offset(40, -30));
      await gesture.moveBy(const Offset(40, 20));
      await gesture.up();
      await tester.pump();

      expect(controller.isNotEmpty, isTrue);
      expect(controller.strokeCount, 1);
      expect(changes, [true]);
      expect(find.text('Sign here'), findsNothing);

      final png = await tester.runAsync(() => controller.toPngBytes());
      expect(png, isNotNull);
      expect(png!.sublist(1, 4), [0x50, 0x4E, 0x47], reason: 'PNG signature');

      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(controller.isEmpty, isTrue);
      expect(changes, [true, false]);
      expect(await tester.runAsync(() => controller.toPngBytes()), isNull);
    });
  });

  group('TFilePicker camera', () {
    testWidgets('camera source captures a photo with the configured downscale', (tester) async {
      double? usedDimension;
      int? usedQuality;
      TFilePicker.debugCameraCapture = (dim, quality) async {
        usedDimension = dim;
        usedQuality = quality;
        return XFile.fromData(Uint8List.fromList([1, 2, 3, 4]), name: 'proof.jpg');
      };
      addTearDown(() => TFilePicker.debugCameraCapture = null);

      List<TFile>? picked;
      await pumpMobile(
        tester,
        SizedBox(
          width: 320,
          child: TFilePicker(
            label: 'Proof photo',
            fileType: TFileType.image,
            source: TFilePickerSource.camera,
            maxImageDimension: 1280,
            imageQuality: 70,
            isGalleryMode: true,
            onValueChanged: (files) => picked = files,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.photo_camera_outlined));
      await tester.pumpAndSettle();

      expect(usedDimension, 1280);
      expect(usedQuality, 70);
      expect(picked, isNotNull);
      expect(picked!.single.extension, 'jpg');
      expect(picked!.single.bytes, [1, 2, 3, 4]);
    });
  });
}

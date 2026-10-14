import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TKeyValue factory constructors', () {
    testWidgets('TKeyValue.datetime renders TDateTimeText for ISO string and DateTime', (tester) async {
      final now = DateTime(2026, 9, 28, 10, 30);
      final kv1 = TKeyValue.datetime('Created', '2026-09-28T10:30:00Z');
      final kv2 = TKeyValue.datetime('Updated', now);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv1, kv2],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TDateTimeText), findsNWidgets(2));
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Updated'), findsOneWidget);
    });

    testWidgets('TKeyValue.image renders TImage widget', (tester) async {
      final kv = TKeyValue.image('Avatar', 'https://example.com/avatar.png', size: 50.0);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TImage), findsOneWidget);
      expect(find.text('Avatar'), findsOneWidget);
    });

    testWidgets('TKeyValue.chip renders TChip widget', (tester) async {
      final kv = TKeyValue.chip('Status', 'Active', color: Colors.green);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TChip), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('TKeyValue.chips renders Wrap of TChip widgets for strings and TChip instances', (tester) async {
      final kv = TKeyValue.chips('Tags', [
        'Flutter',
        'Dart',
        const TChip(text: 'Firebase', color: Colors.amber),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TChip), findsNWidgets(3));
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);
      expect(kv.value, 'Flutter, Dart, Firebase');
    });

    testWidgets('TKeyValue.rating renders TRating widget', (tester) async {
      final kv = TKeyValue.rating('Score', 4.5, allowHalfRating: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TRating), findsOneWidget);
      expect(find.text('Score'), findsOneWidget);
    });

    testWidgets('TKeyValue.progress renders TProgressBar widget', (tester) async {
      final kv = TKeyValue.progress('Completion', 0.75, showPercentage: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TProgressBar), findsOneWidget);
      expect(find.text('Completion'), findsOneWidget);
      expect(kv.value, '75%');
    });

    testWidgets('TKeyValue.toggle renders TSwitch widget and handles value change', (tester) async {
      bool? toggledValue;
      final kv = TKeyValue.toggle(
        'Enabled',
        false,
        onValueChanged: (val) => toggledValue = val,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection(
              values: [kv],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TSwitch), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);

      await tester.tap(find.byType(TSwitch));
      await tester.pumpAndSettle();

      expect(toggledValue, isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TButton Minimal Elevation & Subtle Gradient', () {
    testWidgets('default solid button has minimal elevation and subtle gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              text: 'Save Changes',
              onTap: () {},
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final elevation = elevatedButton.style?.elevation?.resolve({});
      expect(elevation, equals(1.0));

      final ink = tester.widget<Ink>(
        find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Ink)),
      );
      final decoration = ink.decoration as ShapeDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.gradient, isA<LinearGradient>());

      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors.length, 2);
      expect(gradient.colors[0], isNot(equals(gradient.colors[1])));
    });

    testWidgets('outline button has 0 elevation and no gradient fill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              type: TButtonType.outline,
              text: 'Cancel',
              onTap: () {},
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final elevation = elevatedButton.style?.elevation?.resolve({});
      expect(elevation, equals(0.0));

      final ink = tester.widget<Ink>(
        find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Ink)),
      );
      expect(ink.decoration, isNull);
    });

    testWidgets('text button has 0 elevation and no gradient fill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              type: TButtonType.text,
              text: 'Learn more',
              onTap: () {},
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final elevation = elevatedButton.style?.elevation?.resolve({});
      expect(elevation, equals(0.0));

      final ink = tester.widget<Ink>(
        find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Ink)),
      );
      expect(ink.decoration, isNull);
    });

    testWidgets('respects custom elevation and gradient overrides', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.purple, Colors.pink],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              text: 'Custom',
              elevation: 4.0,
              gradient: customGradient,
              onTap: () {},
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedButton.style?.elevation?.resolve({}), equals(4.0));

      final ink = tester.widget<Ink>(
        find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Ink)),
      );
      final decoration = ink.decoration as ShapeDecoration?;
      expect(decoration?.gradient, equals(customGradient));
    });

    testWidgets('elevation reacts to hover and pressed states', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              text: 'Click Me',
              onTap: () {},
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style!;

      // Normal resting
      expect(style.elevation?.resolve({}), equals(1.0));
      // Hovered lifts
      expect(style.elevation?.resolve({WidgetState.hovered}), equals(2.0));
      // Pressed depresses
      expect(style.elevation?.resolve({WidgetState.pressed}), equals(0.5));
      // Disabled is flat
      expect(style.elevation?.resolve({WidgetState.disabled}), equals(0.0));
    });

    testWidgets('stadium pill and circle shapes format ShapeDecoration correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TButton(
                  shape: TButtonShape.pill,
                  text: 'Pill Button',
                  onTap: () {},
                ),
                TButton(
                  shape: TButtonShape.circle,
                  icon: Icons.add,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final inks = tester.widgetList<Ink>(
        find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Ink)),
      ).toList();

      expect(inks.length, 2);
      final pillDec = inks[0].decoration as ShapeDecoration?;
      expect(pillDec?.shape, isA<StadiumBorder>());

      final circleDec = inks[1].decoration as ShapeDecoration?;
      expect(circleDec?.shape, isA<CircleBorder>());
    });

    testWidgets('tapping button triggers press animation and onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              text: 'Tap Me',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('button does not grow to full width unless TButtonSize.block is used', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TButton(
                      key: const ValueKey('normal-btn'),
                      text: 'Normal',
                      onTap: () {},
                    ),
                    TButton(
                      key: const ValueKey('block-btn'),
                      size: TButtonSize.block,
                      text: 'Block',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final normalWidth = tester.getSize(find.byKey(const ValueKey('normal-btn'))).width;
      final blockWidth = tester.getSize(find.byKey(const ValueKey('block-btn'))).width;

      expect(normalWidth, lessThan(150));
      expect(blockWidth, equals(500));
    });

    testWidgets('button with gradient fills full expanded width in a Row without centered shrinking', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Row(
                  children: [
                    Expanded(
                      child: TButton(
                        key: const ValueKey('row-btn'),
                        text: 'Save',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final ink = tester.widget<Ink>(
        find.descendant(of: find.byKey(const ValueKey('row-btn')), matching: find.byType(Ink)),
      );
      expect(ink.decoration, isNotNull);
      final inkSize = tester.getSize(find.descendant(of: find.byKey(const ValueKey('row-btn')), matching: find.byType(Ink)));
      expect(inkSize.width, equals(320.0), reason: 'gradient Container fills the full expanded row width');
    });
  });
}

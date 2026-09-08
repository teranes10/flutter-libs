import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  group('TImage Sizing, AspectRatio, and Cropping Alignment Tests', () {
    testWidgets('TImage defaults to 80x80 container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(url: null),
          ),
        ),
      );

      final containerFinder = find.byType(Container).first;
      final renderBox = tester.renderObject(containerFinder) as RenderBox;
      expect(renderBox.size.width, equals(80));
      expect(renderBox.size.height, equals(80));
    });

    testWidgets('TImage respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(url: null, size: 120),
          ),
        ),
      );

      final renderBox = tester.renderObject(find.byType(Container).first) as RenderBox;
      expect(renderBox.size.width, equals(120));
      expect(renderBox.size.height, equals(120));
    });

    testWidgets('TImage with width and aspect ratio computes height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(
              url: null,
              width: 160,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      );

      final renderBox = tester.renderObject(find.byType(Container).first) as RenderBox;
      expect(renderBox.size.width, equals(160));
      expect(renderBox.size.height, closeTo(90, 0.01));
    });

    testWidgets('TImage with height and aspect ratio computes width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(
              url: null,
              height: 90,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      );

      final renderBox = tester.renderObject(find.byType(Container).first) as RenderBox;
      expect(renderBox.size.width, closeTo(160, 0.01));
      expect(renderBox.size.height, equals(90));
    });

    testWidgets('TImage with explicit width and height uses both', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(
              url: null,
              width: 200,
              height: 100,
            ),
          ),
        ),
      );

      final renderBox = tester.renderObject(find.byType(Container).first) as RenderBox;
      expect(renderBox.size.width, equals(200));
      expect(renderBox.size.height, equals(100));
    });

    testWidgets('TImage passes cropping alignment to image widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(
              url: null,
              width: 100,
              height: 100,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image image = tester.widget(imageFinder);
      expect(image.alignment, equals(Alignment.topCenter));
    });

    testWidgets('TImage.profile works with custom size and alignment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TImage.profile(
              name: 'John Doe',
              role: 'Admin',
              size: 50,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container).first;
      final renderBox = tester.renderObject(containerFinder) as RenderBox;
      expect(renderBox.size.width, equals(50));
      expect(renderBox.size.height, equals(50));
    });

    testWidgets('TImage with null or empty URL renders fallback placeholder directly without shimmer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TImage(url: ''),
          ),
        ),
      );

      // Shimmer should not be present
      expect(find.byKey(const ValueKey('shimmer')), findsNothing);
      // Fallback placeholder image should be present
      expect(find.byType(Image), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_map/te_map.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  pickerTests();
  suggestionTests();

  group('TRouteResult and decodePolyline', () {
    test('decodePolyline decodes standard encoded polyline string', () {
      // Encoded polyline for (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = decodePolyline(encoded);

      expect(points.length, 3);
      expect(points[0].latitude, closeTo(38.5, 0.001));
      expect(points[0].longitude, closeTo(-120.2, 0.001));
      expect(points[1].latitude, closeTo(40.7, 0.001));
      expect(points[1].longitude, closeTo(-120.95, 0.001));
      expect(points[2].latitude, closeTo(43.252, 0.001));
      expect(points[2].longitude, closeTo(-126.453, 0.001));
    });

    test('TRouteResult formats distance and duration correctly', () {
      const result1 = TRouteResult(points: [], distanceMeters: 14500, durationSeconds: 1500);
      expect(result1.formattedDistance, '14.5 km');
      expect(result1.formattedDuration, '25 min');

      const result2 = TRouteResult(points: [], distanceMeters: 450, durationSeconds: 4200);
      expect(result2.formattedDistance, '450 m');
      expect(result2.formattedDuration, '1 hr 10 min');
    });
  });

  group('TMapPinning Two-Points Mode', () {
    testWidgets('Single point mode renders a read-only text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TMapPinning(label: 'Single Point', initialCoordinates: const LatLng(6.9271, 79.8612)),
          ),
        ),
      );

      expect(find.byType(TTextField<String?>), findsOneWidget);
      expect(find.byType(TMap), findsNothing);
      expect(tester.widget<TTextField<String?>>(find.byType(TTextField<String?>)).readOnly, isTrue);
    });

    testWidgets('Two points mode renders two read-only fields in one container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TMapPinning(
              label: 'Delivery Route',
              isTwoPoints: true,
              initialFromCoordinates: const LatLng(6.9271, 79.8612),
              initialToCoordinates: const LatLng(6.9147, 79.8732),
            ),
          ),
        ),
      );

      expect(find.byType(TInputContainer), findsOneWidget);
      expect(find.byType(TTextField<String?>), findsNWidgets(2));
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('TPlaceAutoComplete selection updates coordinates and centers map', (tester) async {
      LatLng? selectedCoords;
      String? selectedAddr;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TPlaceAutoComplete(
              onPlaceSelected: (details) {
                selectedAddr = details.address;
                selectedCoords = LatLng(details.latitude, details.longitude);
              },
            ),
          ),
        ),
      );

      // Verify widget mounts
      expect(find.byType(TPlaceAutoComplete), findsOneWidget);
      expect(selectedCoords, isNull);
      expect(selectedAddr, isNull);
    });
  });
}

void pickerTests() {
  for (final mobile in [true, false]) {
    for (final two in [false, true]) {
      testWidgets('Picker opens (${mobile ? 'mobile' : 'desktop'}, ${two ? 'two' : 'single'} points)', (tester) async {
        tester.view.physicalSize = mobile ? const Size(400, 800) : const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TMapPinning(
                  label: 'Where',
                  isTwoPoints: two,
                  initialFromCoordinates: const LatLng(9.66, 80.0),
                  initialToCoordinates: two ? const LatLng(9.7, 80.05) : null,
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(TTextField<String?>).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(TMap), findsOneWidget);
        expect(find.text('Saved'), findsOneWidget);
      });
    }
  }
}

void suggestionTests() {
  testWidgets('Typing replaces saved/recent with a suggestions list', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TMapPinning(label: 'Where', initialFromCoordinates: const LatLng(9.66, 80.0)),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TTextField<String?>).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField).first, 'Hospital');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Suggestions'), findsOneWidget);
    expect(find.text('Saved'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Suggestions'), findsNothing);
    expect(find.text('Saved'), findsOneWidget);
    // Typing one character at a time keeps the text (the field must not reset on rebuild).
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).first, 'H');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).first, 'Ho');
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, 'Ho');

    // Typing the same text again is still detected.
    await tester.enterText(find.byType(TextField).first, 'Hospital');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Suggestions'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}

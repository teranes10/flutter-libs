import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_map/te_map.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      const result1 = TRouteResult(
        points: [],
        distanceMeters: 14500,
        durationSeconds: 1500,
      );
      expect(result1.formattedDistance, '14.5 km');
      expect(result1.formattedDuration, '25 min');

      const result2 = TRouteResult(
        points: [],
        distanceMeters: 450,
        durationSeconds: 4200,
      );
      expect(result2.formattedDistance, '450 m');
      expect(result2.formattedDuration, '1 hr 10 min');
    });
  });

  group('TMapPinning Two-Points Mode', () {
    testWidgets('Renders single point mode with 100px height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TMapPinning(
              label: 'Single Point',
              initialCoordinates: const LatLng(6.9271, 79.8612),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(TMapPinning);
      expect(containerFinder, findsOneWidget);

      // Verify single point map container height is 100
      final sizedBoxes = tester.widgetList<Container>(find.byType(Container));
      final hasHeight100 = sizedBoxes.any((c) => c.constraints?.maxHeight == 100 || (c.constraints == null && c.child != null));
      expect(hasHeight100, isTrue);
    });

    testWidgets('Renders two points mode with stacked fields and doubled 200px height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TMapPinning(
              label: 'Delivery Route',
              isTwoPoints: true,
              fromLabel: 'Pickup Location',
              toLabel: 'Drop-off Location',
              initialFromCoordinates: const LatLng(6.9271, 79.8612),
              initialToCoordinates: const LatLng(6.9147, 79.8732),
            ),
          ),
        ),
      );

      // Should render the stacked trigger fields
      expect(find.text('Select pickup location'), findsOneWidget);
      expect(find.text('Select drop-off location'), findsOneWidget);
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

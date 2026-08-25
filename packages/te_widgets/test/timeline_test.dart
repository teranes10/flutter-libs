import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TTimeline renders items with direct colors and TVariant', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTimeline(
            variant: TVariant.tonal,
            items: [
              TTimelineItem(
                titleText: 'Step 1',
                subtitleText: 'Description for step 1',
                color: Colors.green,
                isCompleted: true,
                variant: TVariant.solid,
              ),
              TTimelineItem(
                titleText: 'Step 2',
                subtitleText: 'In progress',
                color: Colors.blue,
                isActive: true,
                variant: TVariant.tonal,
              ),
              TTimelineItem(
                titleText: 'Step 3',
                subtitleText: 'Pending',
                color: Colors.grey,
                variant: TVariant.outline,
              ),
              TTimelineItem(
                titleText: 'Step 4',
                indicator: const TTimelineIndicator.dot(color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Step 3'), findsOneWidget);
    expect(find.text('Step 4'), findsOneWidget);
    expect(find.text('Description for step 1'), findsOneWidget);
    expect(find.byType(TTimelineIndicator), findsNWidgets(4));
  });

  testWidgets('TTimelineIndicator.dot renders properly with TVariant', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: TTimelineIndicator.dot(
            color: Colors.purple,
            variant: TVariant.tonal,
          ),
        ),
      ),
    );

    expect(find.byType(TTimelineIndicator), findsOneWidget);
  });
}

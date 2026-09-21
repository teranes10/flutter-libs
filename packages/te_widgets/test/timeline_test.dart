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

  testWidgets('TTimeline horizontal scrollable mode renders with custom item widths and scrollbar', (WidgetTester tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: TTimeline(
              direction: Axis.horizontal,
              scrollable: true,
              itemWidth: 220,
              showScrollbar: true,
              scrollController: controller,
              items: [
                const TTimelineItem(titleText: 'Week 1', width: 260),
                const TTimelineItem(titleText: 'Week 2'),
                const TTimelineItem(titleText: 'Week 3'),
                const TTimelineItem(titleText: 'Week 4'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.text('Week 1'), findsOneWidget);
    expect(find.text('Week 2'), findsOneWidget);

    // Verify first item custom width was respected
    final week1Box = tester.renderObject(find
        .ancestor(
          of: find.text('Week 1'),
          matching: find.byType(SizedBox),
        )
        .first) as RenderBox;
    expect(week1Box.size.width, 260.0);

    // Verify second item fallback width was respected
    final week2Box = tester.renderObject(find
        .ancestor(
          of: find.text('Week 2'),
          matching: find.byType(SizedBox),
        )
        .first) as RenderBox;
    expect(week2Box.size.width, 220.0);
  });

  testWidgets('TTimeline horizontal non-scrollable mode expands items evenly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: SizedBox(
            width: 600,
            child: TTimeline(
              direction: Axis.horizontal,
              scrollable: false,
              items: [
                TTimelineItem(titleText: 'Phase 1'),
                TTimelineItem(titleText: 'Phase 2'),
                TTimelineItem(titleText: 'Phase 3'),
              ],
            ),
          ),
        ),
      ),
    );

    // Should not have SingleChildScrollView in non-scrollable mode
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Phase 1'), findsOneWidget);
    expect(find.text('Phase 2'), findsOneWidget);
    expect(find.text('Phase 3'), findsOneWidget);
  });
}

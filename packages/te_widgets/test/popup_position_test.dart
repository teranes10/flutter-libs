import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/helpers/popup_position.dart';

void main() {
  testWidgets('TPopupConstraints.calculate handles minHeight larger than available height without throwing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              // Target is placed so available height below or above is limited
              final constraints = TPopupConstraints.calculate(
                context,
                targetSize: const Size(100, 40),
                transform: Matrix4.translationValues(0, 300, 0),
                inputConstraints: const BoxConstraints(
                  minWidth: 436,
                  minHeight: 436,
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                popupAlignment: TPopupAlignment.bottomLeft,
              );

              expect(constraints.contentBox.minHeight, lessThanOrEqualTo(constraints.contentBox.maxHeight));
              expect(constraints.contentBox.minWidth, lessThanOrEqualTo(constraints.contentBox.maxWidth));
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  });

  testWidgets('PopupPositionDelegate safely clamps when content size exceeds screen size', (tester) async {
    const delegate = PopupPositionDelegate(
      constraints: TPopupConstraints(
        screenSize: Size(400, 600),
        targetSize: Size(100, 40),
        targetOffset: Offset(50, 50),
        contentBox: BoxConstraints(),
        contentAlignment: Alignment.center,
      ),
      alignment: TPopupAlignment.bottomLeft,
      offset: 8.0,
    );

    // Child larger than screen
    final offset = delegate.getPositionForChild(const Size(400, 600), const Size(500, 800));
    expect(offset.dx, 0.0);
    expect(offset.dy, 0.0);
  });
}

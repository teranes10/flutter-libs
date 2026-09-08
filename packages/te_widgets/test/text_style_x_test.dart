import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  group('FontWeightX', () {
    test('steps font weights correctly within bounds', () {
      expect(FontWeight.w100.step(1), equals(FontWeight.w200));
      expect(FontWeight.w100.step(2), equals(FontWeight.w300));
      expect(FontWeight.w300.step(1), equals(FontWeight.w400));
      expect(FontWeight.w400.step(1), equals(FontWeight.w500));
      expect(FontWeight.w800.step(1), equals(FontWeight.w900));
      // Clamping upper bound
      expect(FontWeight.w900.step(1), equals(FontWeight.w900));
      expect(FontWeight.w900.step(5), equals(FontWeight.w900));

      // Stepping lighter
      expect(FontWeight.w400.step(-1), equals(FontWeight.w300));
      expect(FontWeight.w200.step(-1), equals(FontWeight.w100));
      // Clamping lower bound
      expect(FontWeight.w100.step(-1), equals(FontWeight.w100));
      expect(FontWeight.w100.step(-5), equals(FontWeight.w100));
    });

    test('thicker and lighter getters', () {
      expect(FontWeight.w300.thicker, equals(FontWeight.w400));
      expect(FontWeight.w500.lighter, equals(FontWeight.w400));
    });
  });

  group('TextStyleX', () {
    test('adjust size multiplier and weight step', () {
      const baseStyle = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w100, color: Colors.black);

      final scaledAndStepped = baseStyle.adjust(sizeMultiplier: 1.5, weightStep: 1);
      expect(scaledAndStepped.fontSize, equals(21.0));
      expect(scaledAndStepped.fontWeight, equals(FontWeight.w200));
      expect(scaledAndStepped.color, equals(Colors.black));

      const w300Style = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300);
      final thickerStyle = w300Style.adjust(weightStep: 1);
      expect(thickerStyle.fontWeight, equals(FontWeight.w400));
    });

    test('adjust with null fontSize or fontWeight', () {
      const emptyStyle = TextStyle();
      final adjusted = emptyStyle.adjust(sizeMultiplier: 1.5, weightStep: 1);
      expect(adjusted.fontSize, isNull);
      // Default FontWeight.normal (w400) + 1 step -> w500
      expect(adjusted.fontWeight, equals(FontWeight.w500));
    });

    test('scale, stepWeight, thicker, and lighter methods', () {
      const style = TextStyle(fontSize: 10.0, fontWeight: FontWeight.w400);

      expect(style.scale(2.0).fontSize, equals(20.0));
      expect(style.stepWeight(2).fontWeight, equals(FontWeight.w600));
      expect(style.thicker.fontWeight, equals(FontWeight.w500));
      expect(style.lighter.fontWeight, equals(FontWeight.w300));
    });
  });
}

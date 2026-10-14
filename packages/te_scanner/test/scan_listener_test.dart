import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_scanner/te_scanner.dart';

KeyDownEvent _key(LogicalKeyboardKey key, String? char, int ms) => KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyA,
      logicalKey: key,
      character: char,
      timeStamp: Duration(milliseconds: ms),
    );

void main() {
  group('TScanBuffer', () {
    test('fast keys ending with Enter produce one scan', () {
      final buffer = TScanBuffer();
      var t = 0;
      String? result;
      for (final c in '4006381333931'.split('')) {
        expect(buffer.feed(_key(LogicalKeyboardKey.digit1, c, t += 10)), isNull);
      }
      result = buffer.feed(_key(LogicalKeyboardKey.enter, '\n', t += 10));
      expect(result, '4006381333931');
    });

    test('slow human typing is discarded', () {
      final buffer = TScanBuffer();
      var t = 0;
      for (final c in 'abcd'.split('')) {
        buffer.feed(_key(LogicalKeyboardKey.keyA, c, t += 500));
      }
      expect(buffer.feed(_key(LogicalKeyboardKey.enter, '\n', t += 500)), isNull);
    });

    test('shorter than minLength is ignored and buffer is cleared', () {
      final buffer = TScanBuffer(minLength: 4);
      var t = 0;
      buffer.feed(_key(LogicalKeyboardKey.digit1, '1', t += 10));
      buffer.feed(_key(LogicalKeyboardKey.digit2, '2', t += 10));
      expect(buffer.feed(_key(LogicalKeyboardKey.enter, '\n', t += 10)), isNull);
      for (final c in 'WXYZ'.split('')) {
        buffer.feed(_key(LogicalKeyboardKey.keyA, c, t += 10));
      }
      expect(buffer.feed(_key(LogicalKeyboardKey.enter, '\n', t += 10)), 'WXYZ');
    });
  });

  group('TScanListener', () {
    testWidgets('delivers a wedge scan when no text field is focused', (tester) async {
      final scans = <String>[];
      await tester.pumpWidget(
        MaterialApp(home: TScanListener(onScan: scans.add, child: const Scaffold(body: Text('screen')))),
      );

      for (final c in 'SKU12345'.split('')) {
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: c);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(scans, ['SKU12345']);
    });

    testWidgets('leaves the scan to a focused text field', (tester) async {
      final scans = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: TScanListener(
            onScan: scans.add,
            child: const Scaffold(body: TextField(autofocus: true)),
          ),
        ),
      );
      await tester.pump();

      for (final c in 'SKU12345'.split('')) {
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA, character: c);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(scans, isEmpty);
    });
  });
}

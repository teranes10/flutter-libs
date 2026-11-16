import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

enum _S { a, b }

void main() {
  enumTests();
  rejectTest();
  testWidgets('status chip opens dropdown and reports change', (tester) async {
    var current = _S.a;
    _S? changed;
    await tester.pumpWidget(MaterialApp(
      theme: TAppTheme.defaultTheme().lightTheme,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (ctx, setState) => TTable<int, int>(
            shrinkWrap: true,
            items: const [1],
            headers: [
              TTableHeader.statusChip<int, int, _S>(
                'Status',
                (_) => current,
                const [TStatusOption(_S.a, 'Alpha', color: Colors.green), TStatusOption(_S.b, 'Beta', color: Colors.red)],
                onChanged: (_, v) {
                  setState(() => changed = current = v);
                  return true;
                },
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);
    final w = tester.getSize(find.ancestor(of: find.text('Beta'), matching: find.byType(Column)).first).width;
    expect(w, lessThan(120));
    expect(w, greaterThan(60));
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(changed, _S.b);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });
}

void enumTests() {
  test('humanize', () {
    expect(TStatusOption.humanize('inProgress'), 'In Progress');
    expect(TStatusOption.humanize('done'), 'Done');
    expect(TStatusOption.humanize('on_hold'), 'On hold');
  });
}

void rejectTest() {
  testWidgets('status chip keeps old value when onChanged returns false', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: TAppTheme.defaultTheme().lightTheme,
      home: Scaffold(
        body: TTable<int, int>(
          shrinkWrap: true,
          items: const [1],
          headers: [
            TTableHeader.statusEnum<int, int, _S>('Status', (_) => _S.a, _S.values, onChanged: (_, __) async => false),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int ticks = 0;

  /// Live data arriving: the popover's owner rebuilds.
  void tick() => setState(() => ticks++);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text('ticks $ticks'),
          TPopover(
            builder: (context, close) => const SizedBox(width: 200, child: TextField(key: ValueKey('inner'))),
            child: const Text('open'),
          ),
        ],
      );
}

void main() {
  testWidgets('a field inside an open popover keeps focus when the owner rebuilds; Escape still closes it', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: _Host())));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('inner')));
    await tester.enterText(find.byKey(const ValueKey('inner')), 'abc');
    await tester.pump();

    final host = tester.state<_HostState>(find.byType(_Host));
    for (var i = 0; i < 3; i++) {
      host.tick();
      await tester.pump();
    }
    final field =
        tester.widget<EditableText>(find.descendant(of: find.byKey(const ValueKey('inner')), matching: find.byType(EditableText)));
    expect(field.focusNode.hasFocus, isTrue);
    expect(field.controller.text, 'abc');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('inner')), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  buttonTests();
  group('TPermissionSet', () {
    test('exact, wildcard, deny', () {
      final s = TPermissionSet(['orders.*', 'users.view', '!orders.delete']);
      expect(s.has('orders.edit'), true);
      expect(s.has('orders.items.edit'), true);
      expect(s.has('orders.delete'), false);
      expect(s.has('users.view'), true);
      expect(s.has('users.edit'), false);
      expect(TPermissionSet(['*']).has('anything.at.all'), true);
    });
  });

  group('TPermission', () {
    test('any / all', () {
      final s = TPermissionSet(['a']);
      expect(const TPermission.any(['a', 'b']).evaluate(s.has), true);
      expect(const TPermission.all(['a', 'b']).evaluate(s.has), false);
    });
  });

  group('TAuthController', () {
    test('unconfigured allows everything; supplied list (even empty) denies the rest', () {
      final c = TAuthController();
      expect(c.check('x', target: TAuthTarget.button).isAllowed, true);
      c.update([]);
      expect(c.check('x', target: TAuthTarget.button).isAllowed, false);
      c.update(['x']);
      expect(c.check('x', target: TAuthTarget.button).isAllowed, true);
      expect(c.check('y', target: TAuthTarget.button).isAllowed, false);
    });

    test('mode resolution: override > target > global', () {
      final c = TAuthController(permissions: const []);
      expect(c.check('x', target: TAuthTarget.button).mode, TAuthMode.disable);
      expect(c.check('x', target: TAuthTarget.sidebarItem).mode, TAuthMode.hide);
      expect(c.check('x', target: TAuthTarget.sidebarItem, onDenied: TAuthMode.disable).mode, TAuthMode.disable);
      expect(c.check(null, target: TAuthTarget.button).isAllowed, true);
    });
  });

  group('TAuthGate', () {
    Widget host(TAuthController? c, Widget gate) {
      final app = MaterialApp(home: gate);
      return c == null ? app : TAuthScope(controller: c, child: app);
    }

    testWidgets('no scope allows', (t) async {
      await t.pumpWidget(host(null, const TAuthGate(permission: 'x', child: Text('hi'))));
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('hide / disable and live update', (t) async {
      final c = TAuthController(permissions: const []);
      await t.pumpWidget(host(c, const TAuthGate(permission: 'x', onDenied: TAuthMode.hide, child: Text('hi'))));
      expect(find.text('hi'), findsNothing);
      c.update(['x']);
      await t.pump();
      expect(find.text('hi'), findsOneWidget);
    });
  });
}

void buttonTests() {
  group('TButton permission', () {
    testWidgets('denied disables tap, hide removes, granted taps', (t) async {
      var taps = 0;
      final c = TAuthController(permissions: const []);
      Widget app(TAuthMode? mode) => TAuthScope(
            controller: c,
            child: MaterialApp(
              theme: ThemeData(extensions: [TWidgetThemeExtension.defaultTheme(const ColorScheme.light())]),
              home: Scaffold(body: TButton(text: 'Go', permission: 'x', onDenied: mode, onTap: () => taps++)),
            ),
          );
      await t.pumpWidget(app(null));
      await t.tap(find.text('Go'));
      await t.pump(const Duration(milliseconds: 500));
      expect(taps, 0);
      await t.pumpWidget(app(TAuthMode.hide));
      expect(find.text('Go'), findsNothing);
      c.update(['x']);
      await t.pumpWidget(app(null));
      await t.tap(find.text('Go'));
      await t.pump(const Duration(milliseconds: 500));
      expect(taps, 1);
    });
  });
}

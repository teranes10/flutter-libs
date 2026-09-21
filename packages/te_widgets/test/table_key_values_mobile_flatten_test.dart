import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;

  const _User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'Engineer',
    this.department = 'Mobile',
  });
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TTableHeader.keyValues mobile flattening tests', () {
    testWidgets('TKeyValue.mapHeaders flattens TTableHeader.keyValues by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(builder: (context) {
            final headers = [
              TTableHeader<_User, String>.map('Name', (u) => u.name),
              TTableHeader<_User, String>.keyValues(
                  'Contact Info',
                  (u) => [
                        TKeyValue('Email', value: u.email),
                        TKeyValue('Phone', value: u.phone),
                      ]),
            ];

            final item = TListItem(
              data: const _User(id: '1', name: 'John Doe', email: 'john@example.com', phone: '+123456789'),
              key: '1',
            );

            final mapped = TKeyValue.mapHeaders(context, headers, item, 0);

            // Should be flattened to 3 items: Name, Email, Phone
            expect(mapped.length, equals(3));
            expect(mapped[0].key, equals('Name'));
            expect(mapped[0].value, equals('John Doe'));
            expect(mapped[1].key, equals('Email'));
            expect(mapped[1].value, equals('john@example.com'));
            expect(mapped[2].key, equals('Phone'));
            expect(mapped[2].value, equals('+123456789'));

            return const Placeholder();
          }),
        ),
      );
    });

    testWidgets('TTableHeader.keyValues with flattenOnMobile: false keeps single parent item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(builder: (context) {
            final headers = [
              TTableHeader<_User, String>.map('Name', (u) => u.name),
              TTableHeader<_User, String>.keyValues(
                'Contact Info',
                (u) => [
                  TKeyValue('Email', value: u.email),
                  TKeyValue('Phone', value: u.phone),
                ],
                flattenOnMobile: false,
              ),
            ];

            final item = TListItem(
              data: const _User(id: '1', name: 'John Doe', email: 'john@example.com', phone: '+123456789'),
              key: '1',
            );

            final mapped = TKeyValue.mapHeaders(context, headers, item, 0);

            // Stays as 2 items: Name and Contact Info
            expect(mapped.length, equals(2));
            expect(mapped[0].key, equals('Name'));
            expect(mapped[1].key, equals('Contact Info'));

            return const Placeholder();
          }),
        ),
      );
    });

    testWidgets('TTableHeader.keyValues with mobileKeyPrefixBuilder prefixes flattened keys', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(builder: (context) {
            final headers = [
              TTableHeader<_User, String>.keyValues(
                'Contact',
                (u) => [
                  TKeyValue('Email', value: u.email),
                  TKeyValue('Phone', value: u.phone),
                ],
                mobileKeyPrefixBuilder: (header, key) => '$header • $key',
              ),
            ];

            final item = TListItem(
              data: const _User(id: '1', name: 'John Doe', email: 'john@example.com', phone: '+123456789'),
              key: '1',
            );

            final mapped = TKeyValue.mapHeaders(context, headers, item, 0);

            expect(mapped.length, equals(2));
            expect(mapped[0].key, equals('Contact • Email'));
            expect(mapped[0].value, equals('john@example.com'));
            expect(mapped[1].key, equals('Contact • Phone'));
            expect(mapped[1].value, equals('+123456789'));

            return const Placeholder();
          }),
        ),
      );
    });

    testWidgets('TTable renders flattened keyValues on small screen card mode', (WidgetTester tester) async {
      final headers = [
        TTableHeader<_User, String>.map('Name', (u) => u.name),
        TTableHeader<_User, String>.keyValues(
            'Contact Info',
            (u) => [
                  TKeyValue('Email', value: u.email),
                  TKeyValue('Phone', value: u.phone),
                ]),
      ];

      final tableTheme = TTableTheme.defaultTheme(theme.colorScheme).copyWith(forceCardStyle: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: TTable<_User, String>(
                theme: tableTheme,
                headers: headers,
                items: const [
                  _User(id: '1', name: 'Alice', email: 'alice@example.com', phone: '111-222-3333'),
                ],
                itemKey: (x) => x.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('111-222-3333'), findsOneWidget);
      expect(find.text('Contact Info'), findsNothing);
    });
  });

  group('TTableHeader.values tests', () {
    testWidgets('TTableHeader.values applies hierarchical font sizes and contrast on large screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const baseStyle = TextStyle(fontSize: 20.0, color: Colors.blue);
      final tableTheme = TTableTheme.defaultTheme(theme.colorScheme).copyWith(
        rowCardTheme: TTableRowCardTheme.defaultTheme(theme.colorScheme).copyWith(
          contentTextStyle: baseStyle,
        ),
      );

      late BuildContext capturedCtx;

      final headers = [
        TTableHeader<_User, String>.values(
            'Details',
            (u) => [
                  TKeyValue('Name', value: u.name),
                  TKeyValue('Email', value: u.email),
                  TKeyValue('Phone', value: u.phone),
                  TKeyValue('Role', value: u.role),
                  TKeyValue('Department', value: u.department),
                ]),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(builder: (ctx) {
              capturedCtx = ctx;
              return SizedBox(
                width: 1000,
                height: 600,
                child: TTable<_User, String>(
                  theme: tableTheme,
                  headers: headers,
                  items: const [
                    _User(
                      id: '1',
                      name: 'Alice',
                      email: 'alice@example.com',
                      phone: '111-222-3333',
                      role: 'Lead',
                      department: 'Design',
                    ),
                  ],
                  itemKey: (x) => x.id,
                ),
              );
            }),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check 1st value: 20.0 * 1.015 = 20.3, same color as contentTextStyle
      final Text t1 = tester.widget(find.text('Alice'));
      expect(t1.style?.fontSize, equals(20.0 * 1.015));
      expect(t1.style?.color, equals(Colors.blue));

      // Check 2nd value: 20.0 * 0.85 = 17.0, adaptiveContrast(-0.5)
      final Text t2 = tester.widget(find.text('alice@example.com'));
      expect(t2.style?.fontSize, equals(20.0 * 0.85));
      expect(t2.style?.color, equals(Colors.blue.adaptiveContrast(capturedCtx, -0.5)));

      // Check 3rd value: 20.0 * 0.7 = 14.0, adaptiveContrast(-0.85)
      final Text t3 = tester.widget(find.text('111-222-3333'));
      expect(t3.style?.fontSize, equals(20.0 * 0.7));
      expect(t3.style?.color, equals(Colors.blue.adaptiveContrast(capturedCtx, -0.85)));

      // Check 4th value: 20.0 * 0.55 = 11.0, adaptiveContrast(-1.0)
      final Text t4 = tester.widget(find.text('Lead'));
      expect(t4.style?.fontSize, equals(20.0 * 0.55));
      expect(t4.style?.color, equals(Colors.blue.adaptiveContrast(capturedCtx, -1.0)));

      // Check 5th value: 20.0 * 0.55 = 11.0, adaptiveContrast(-1.0)
      final Text t5 = tester.widget(find.text('Design'));
      expect(t5.style?.fontSize, equals(20.0 * 0.55));
      expect(t5.style?.color, equals(Colors.blue.adaptiveContrast(capturedCtx, -1.0)));
    });

    testWidgets('TTableHeader.values flattens into key values on mobile card mode', (WidgetTester tester) async {
      final headers = [
        TTableHeader<_User, String>.values(
            'User Profile',
            (u) => [
                  TKeyValue('Name', value: u.name),
                  TKeyValue('Email', value: u.email),
                  TKeyValue('Phone', value: u.phone),
                ]),
      ];

      final tableTheme = TTableTheme.defaultTheme(theme.colorScheme).copyWith(forceCardStyle: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: TTable<_User, String>(
                theme: tableTheme,
                headers: headers,
                items: const [
                  _User(id: '1', name: 'Bob', email: 'bob@example.com', phone: '999-888-7777'),
                ],
                itemKey: (x) => x.id,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('999-888-7777'), findsOneWidget);
      expect(find.text('User Profile'), findsNothing);
    });
  });
}

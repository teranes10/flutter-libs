import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('email login validates, then passes credentials and shows the returned error', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: TAppTheme.defaultTheme().lightTheme,
        home: TLogin(
          title: 'POS System',
          identifier: TLoginIdentifier.email,
          onLogin: (email, password, status) async {
            calls.add('$email:$password');
            return 'Invalid login.';
          },
        ),
      ),
    ));

    Future<void> signIn(String email) async {
      await tester.enterText(find.byType(EditableText).first, email);
      await tester.enterText(find.byType(EditableText).last, 'secret');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
    }

    await signIn('not-an-email');
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(calls, isEmpty);

    await signIn(' a@b.com ');
    expect(calls, ['a@b.com:secret']);
    expect(find.text('Invalid login.'), findsOneWidget);
  });
}

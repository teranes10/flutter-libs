import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class AccountForm extends TFormBase {
  final username = TFieldProp<String>('');
  final email = TFieldProp<String>('');

  @override
  List<TFormField> get fields => [
        TFormField.text(username, 'Username', isRequired: true),
        TFormField.text(email, 'Email'),
      ];
}

class ProfileForm extends TFormBase {
  final bio = TFieldProp<String>('');

  @override
  List<TFormField> get fields => [
        TFormField.text(bio, 'Bio'),
      ];
}

class ParentFormWithTabs extends TFormBase {
  final title = TFieldProp<String>('');
  final account = AccountForm();
  final profile = ProfileForm();

  @override
  List<TFormField> get fields => [
        TFormField.text(title, 'Title', isRequired: true),
        TFormField.horizontalTabs(
          tabs: [
            TFormTab(title: 'Account', icon: Icons.person, input: account),
            TFormTab(title: 'Profile', icon: Icons.badge, input: profile),
          ],
        ),
      ];
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TFormBuilder renders horizontal tabs and switches tab content', (WidgetTester tester) async {
    final accountForm = AccountForm();
    final profileForm = ProfileForm();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TFormBuilder.horizontalTabs(
              tabs: [
                TFormTab(title: 'Account Tab', icon: Icons.person, input: accountForm),
                TFormTab(title: 'Profile Tab', icon: Icons.badge, input: profileForm),
              ],
            ),
          ),
        ),
      ),
    );

    // Tab buttons should be visible
    expect(find.text('Account Tab'), findsOneWidget);
    expect(find.text('Profile Tab'), findsOneWidget);

    // Initial tab (Account) has 2 text fields (Username, Email)
    expect(find.byType(TTextField<String?>), findsNWidgets(2));

    // Tap Profile Tab
    await tester.tap(find.text('Profile Tab'));
    await tester.pumpAndSettle();

    // Now switched to Profile Tab
    expect(find.byType(TTextField<String?>), findsWidgets);

    // Switch back to Account Tab
    await tester.tap(find.text('Account Tab'));
    await tester.pumpAndSettle();

    expect(find.byType(TTextField<String?>), findsWidgets);
  });

  testWidgets('TFormBuilder renders vertical tabs layout', (WidgetTester tester) async {
    final accountForm = AccountForm();
    final profileForm = ProfileForm();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TFormBuilder.verticalTabs(
              tabWidth: 180,
              tabs: [
                TFormTab(title: 'Account', icon: Icons.person, input: accountForm),
                TFormTab(title: 'Profile', icon: Icons.badge, input: profileForm),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(TTextField<String?>), findsNWidgets(2));
  });

  testWidgets('TFormField.tabs integrates validation and isChanged with parent form', (WidgetTester tester) async {
    final parent = ParentFormWithTabs();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TFormBuilder(input: parent),
          ),
        ),
      ),
    );

    // Initial state
    expect(parent.isValid, isFalse);
    expect(parent.validationErrors.length, 2); // Title and Username required
    expect(parent.isChanged, isFalse);

    // Enter username in sub-form
    parent.account.username.value = 'john_doe';
    expect(parent.isChanged, isTrue);

    // Enter title
    parent.title.value = 'My Title';
    expect(parent.isValid, isTrue);

    // Reset
    parent.reset();
    expect(parent.account.username.value, '');
    expect(parent.title.value, '');
    expect(parent.isChanged, isFalse);
  });
}

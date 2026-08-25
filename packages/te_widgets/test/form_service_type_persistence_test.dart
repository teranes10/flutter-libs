import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

class SimpleTestForm extends TFormBase {
  final name = TFieldProp<String>('');

  @override
  String get formTitle => 'Simple Form';

  @override
  List<TFormField> get fields => [
        TFormField.text(name, 'Name'),
      ];
}

class SubAccountForm extends TFormBase {
  final username = TFieldProp<String>('');

  @override
  String get formTitle => 'Account Details';

  @override
  List<TFormField> get fields => [
        TFormField.text(username, 'Username'),
      ];
}

class SubProfileForm extends TFormBase {
  final bio = TFieldProp<String>('');

  @override
  String get formTitle => 'Profile Details';

  @override
  List<TFormField> get fields => [
        TFormField.text(bio, 'Bio'),
      ];
}

class FormWithSubForms extends TFormBase {
  final title = TFieldProp<String>('');
  final account = SubAccountForm();
  final profile = SubProfileForm();

  @override
  String get formTitle => 'Complex Form';

  @override
  List<TFormField> get fields => [
        TFormField.text(title, 'Title'),
        TFormField.tabs(
          tabs: [
            TFormTab(title: 'Account', icon: Icons.person, input: account),
            TFormTab(title: 'Profile', icon: Icons.badge, input: profile),
          ],
        ),
      ];
}

class TabbedFormDirect extends TFormBase {
  final account = SubAccountForm();
  final profile = SubProfileForm();

  @override
  String get formTitle => 'Direct Tabbed Form';

  @override
  List<TFormTab> get tabs => [
        TFormTab(title: 'Account', icon: Icons.person, input: account),
        TFormTab(title: 'Profile', icon: Icons.badge, input: profile),
      ];
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TFormTypePersistence.clearCache();
  });

  test('TFormBase.hasSubForms detects sub-forms accurately', () {
    final simpleForm = SimpleTestForm();
    expect(simpleForm.hasSubForms, isFalse);

    final formWithSubForms = FormWithSubForms();
    expect(formWithSubForms.hasSubForms, isTrue);

    final tabbedFormDirect = TabbedFormDirect();
    expect(tabbedFormDirect.hasSubForms, isTrue);
  });

  testWidgets('TFormService does not show toggle button for forms without sub-forms', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final simpleForm = SimpleTestForm();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TFormService.show(context, simpleForm),
              child: const Text('Open Simple Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Simple Form'));
    await tester.pumpAndSettle();

    // Modal is open
    expect(find.text('Simple Form'), findsOneWidget);

    // Form type toggle switch should NOT be present
    expect(find.byType(TFormTypeToggleSwitch), findsNothing);
  });

  testWidgets('TFormService shows toggle button before close button for forms with sub-forms', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final complexForm = FormWithSubForms();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TFormService.show(context, complexForm),
              child: const Text('Open Complex Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Complex Form'));
    await tester.pumpAndSettle();

    // Modal is open
    expect(find.text('Complex Form'), findsOneWidget);

    // Form type toggle switch should be present in header before close button
    expect(find.byType(TFormTypeToggleSwitch), findsOneWidget);

    // Close button should also be present
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('TFormTypeToggleSwitch cycles layout between horizontal tabs, vertical tabs, and accordion', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final complexForm = FormWithSubForms();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TFormService.show(context, complexForm),
              child: const Text('Open Complex Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Complex Form'));
    await tester.pumpAndSettle();

    // Initially horizontal tabs mode
    expect(find.byType(TTabs<dynamic>), findsOneWidget);

    // Tap toggle switch (cycles from horizontalTabs (index 1) -> verticalTabs (index 2))
    await tester.tap(find.byType(TFormTypeToggleSwitch));
    await tester.pumpAndSettle();

    // Now vertical tabs mode
    expect(find.byType(TTabs<dynamic>), findsOneWidget);

    // Tap toggle switch again (cycles from verticalTabs (index 2) -> accordion (index 0))
    await tester.tap(find.byType(TFormTypeToggleSwitch));
    await tester.pumpAndSettle();

    // Now accordion mode: tabs are rendered as TAccordion items
    expect(find.byType(TAccordion), findsNWidgets(2));
  });

  testWidgets('TFormTypePersistence saves and restores form type preference across sessions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final complexForm = FormWithSubForms();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TFormService.show(context, complexForm),
              child: const Text('Open Complex Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Complex Form'));
    await tester.pumpAndSettle();

    // Cycle to vertical tabs (1 click) and then accordion (2nd click)
    await tester.tap(find.byType(TFormTypeToggleSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TFormTypeToggleSwitch));
    await tester.pumpAndSettle();

    // Now in accordion mode
    expect(find.byType(TAccordion), findsNWidgets(2));

    // Close modal via Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Reopen modal with new form instance of same type
    await tester.tap(find.text('Open Complex Form'));
    await tester.pumpAndSettle();

    // Should immediately restore accordion layout!
    expect(find.byType(TAccordion), findsNWidgets(2));
  });
}

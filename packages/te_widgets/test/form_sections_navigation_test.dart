import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

class _AccountForm extends TFormBase {
  final username = TFieldProp<String>('');

  @override
  List<TFormField> get fields => [TFormField.text(username, 'Username', isRequired: true)];
}

class _ProfileForm extends TFormBase {
  final bio = TFieldProp<String>('');

  @override
  List<TFormField> get fields => [TFormField.text(bio, 'Bio')];
}

class _ContactForm extends TFormBase {
  final email = TFieldProp<String>('');

  @override
  List<TFormField> get fields => [TFormField.text(email, 'Email', isRequired: true)];
}

class _SectionedForm extends TFormBase {
  _SectionedForm(this.type);

  final TFormType type;
  final account = _AccountForm();
  final profile = _ProfileForm();
  final contact = _ContactForm();

  @override
  String get formTitle => 'Sectioned';

  @override
  TFormType? get defaultFormType => type;

  @override
  bool get persistFormType => false;

  @override
  List<TFormTab> get tabs => [
        TFormTab(title: 'Account', input: account),
        TFormTab(title: 'Profile', input: profile),
        TFormTab(title: 'Contact', input: contact),
      ];
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TFormTypePersistence.clearCache();
  });

  Future<void> open(WidgetTester tester, TFormBase form) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => TFormService.show(context, form),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> press(WidgetTester tester, String text) async {
    await tester.tap(find.widgetWithText(TButton, text));
    await tester.pumpAndSettle();
  }

  bool stepHasError(WidgetTester tester, int index) => tester.widget<TStepper>(find.byType(TStepper)).steps[index].hasError;

  int currentStep(WidgetTester tester) => tester.widget<TStepper>(find.byType(TStepper)).currentStep;

  testWidgets('tabs: footer shows Next until the last tab, then Save', (tester) async {
    await open(tester, _SectionedForm(TFormType.horizontalTabs));

    expect(find.widgetWithText(TButton, 'Next'), findsOneWidget);
    expect(find.widgetWithText(TButton, 'Save'), findsNothing);

    await press(tester, 'Next');
    expect(find.widgetWithText(TButton, 'Back'), findsOneWidget);
    expect(find.widgetWithText(TButton, 'Next'), findsOneWidget);

    await press(tester, 'Next');
    expect(find.widgetWithText(TButton, 'Next'), findsNothing);
    expect(find.widgetWithText(TButton, 'Save'), findsOneWidget);
  });

  testWidgets('tabs: Save with errors flags the tabs and opens the first invalid one', (tester) async {
    await open(tester, _SectionedForm(TFormType.horizontalTabs));

    await press(tester, 'Next');
    await press(tester, 'Next');
    await press(tester, 'Save');

    final tabs = tester.widget<TTabs<dynamic>>(find.byType(TTabs<dynamic>)).tabs;
    expect(tabs.map((t) => t.hasError), [true, false, true]);
    // Navigated back to the first invalid tab, with its field error shown.
    expect(find.textContaining('Username is required'), findsOneWidget);
    expect(find.widgetWithText(TButton, 'Next'), findsOneWidget);
  });

  testWidgets('stepper: Next is blocked until the step is valid', (tester) async {
    final form = _SectionedForm(TFormType.horizontalStepper);
    await open(tester, form);

    await press(tester, 'Next');
    expect(currentStep(tester), 0);
    expect(stepHasError(tester, 0), isTrue);
    expect(find.textContaining('Username is required'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'jane');
    await tester.pumpAndSettle();
    expect(stepHasError(tester, 0), isFalse, reason: 'flag clears once the step is fixed');

    await press(tester, 'Next');
    expect(currentStep(tester), 1);
  });

  testWidgets('stepper: tapping a later step cannot skip an invalid step', (tester) async {
    await open(tester, _SectionedForm(TFormType.horizontalStepper));

    await tester.tap(find.text('Contact'));
    await tester.pumpAndSettle();

    expect(currentStep(tester), 0);
    expect(stepHasError(tester, 0), isTrue);
  });

  testWidgets('stepper: toggle offers only stepper layouts', (tester) async {
    await open(tester, _SectionedForm(TFormType.verticalStepper));

    final toggle = tester.widget<TFormTypeToggleSwitch>(find.byType(TFormTypeToggleSwitch));
    expect(toggle.types, TFormType.stepperTypes);
  });

  testWidgets('vertical stepper: renders form content and blocks Next on errors', (tester) async {
    await open(tester, _SectionedForm(TFormType.verticalStepper));
    expect(tester.takeException(), isNull);

    await press(tester, 'Next');
    expect(currentStep(tester), 0);
    expect(stepHasError(tester, 0), isTrue);
  });

  testWidgets('accordion: Save with errors expands and flags the invalid sections', (tester) async {
    final form = _SectionedForm(TFormType.accordion);
    await open(tester, form);
    expect(find.widgetWithText(TButton, 'Save'), findsOneWidget);

    await press(tester, 'Save');

    final accordions = tester.widgetList<TAccordion>(find.byType(TAccordion)).toList();
    expect(accordions.map((a) => a.isExpanded), [true, false, true]);
    expect(accordions.map((a) => a.trailing != null), [true, false, true]);
    expect(find.textContaining('Email is required'), findsOneWidget);
  });

  testWidgets('nested tabs field: footer shows Next until the last nested tab', (tester) async {
    await open(tester, _NestedTabsForm());

    expect(find.widgetWithText(TButton, 'Next'), findsOneWidget);
    expect(find.widgetWithText(TButton, 'Save'), findsNothing);

    await press(tester, 'Next');
    expect(find.widgetWithText(TButton, 'Save'), findsOneWidget);

    await press(tester, 'Save');
    expect(find.textContaining('Username is required'), findsOneWidget);
    expect(find.widgetWithText(TButton, 'Next'), findsOneWidget);
  });
}

class _NestedTabsForm extends TFormBase {
  final account = _AccountForm();
  final profile = _ProfileForm();

  @override
  List<TFormField> get fields => [
        TFormField.verticalTabs(tabs: [
          TFormTab(title: 'Account', input: account),
          TFormTab(title: 'Profile', input: profile),
        ]),
      ];
}

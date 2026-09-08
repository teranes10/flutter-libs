import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

class ValidatedFormWithConfirmation extends TFormBase {
  final name = TFieldProp<String>('');
  bool onSaveCalled = false;
  BuildContext? receivedContext;
  bool returnSaveValue = true;

  @override
  String get formTitle => 'Confirmation Form';

  @override
  List<TFormField> get fields => [
        TFormField.text(name, 'Name', isRequired: true),
      ];

  @override
  Future<bool> onSave(BuildContext context) async {
    onSaveCalled = true;
    receivedContext = context;
    if (!returnSaveValue) {
      return false;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Save'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class SimpleDefaultSaveForm extends TFormBase {
  final name = TFieldProp<String>('Default Value');

  @override
  String get formTitle => 'Default Save Form';

  @override
  List<TFormField> get fields => [
        TFormField.text(name, 'Name'),
      ];
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('TFormBase.onSave defaults to true', () async {
    final form = SimpleDefaultSaveForm();
    final result = await form.onSave(_MockBuildContext());
    expect(result, isTrue);
  });

  testWidgets('TFormService does not invoke onSave if form has validation errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final form = ValidatedFormWithConfirmation();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TFormService.show(context, form),
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Form'));
    await tester.pumpAndSettle();

    // Click Save with empty name (required field)
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // onSave should NOT be called due to validation error
    expect(form.onSaveCalled, isFalse);
    expect(find.text('Confirmation Form'), findsOneWidget);

    // Let the toast timer finish
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('TFormService invokes onSave after validation and aborts save if onSave returns false', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final form = ValidatedFormWithConfirmation();
    TFormBase? savedResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedResult = await TFormService.show(context, form);
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Form'));
    await tester.pumpAndSettle();

    // Enter valid value
    form.name.value = 'John Doe';
    await tester.pumpAndSettle();

    // Click Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // onSave was called and displayed confirmation dialog
    expect(form.onSaveCalled, isTrue);
    expect(form.receivedContext, isNotNull);
    expect(find.text('Confirm Save'), findsOneWidget);

    // Tap "No" to reject
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    // Modal should still remain open
    expect(find.text('Confirmation Form'), findsOneWidget);
    expect(savedResult, isNull);
  });

  testWidgets('TFormService invokes onSave after validation and completes save when onSave returns true', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final form = ValidatedFormWithConfirmation();
    TFormBase? savedResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedResult = await TFormService.show(context, form);
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Form'));
    await tester.pumpAndSettle();

    // Enter valid value
    form.name.value = 'Jane Doe';
    await tester.pumpAndSettle();

    // Click Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Confirm dialog is shown
    expect(find.text('Confirm Save'), findsOneWidget);

    // Tap "Yes" to confirm
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // Modal should be closed and savedResult returned
    expect(find.text('Confirmation Form'), findsNothing);
    expect(savedResult, same(form));
  });

  testWidgets('TFormService with default onSave saves immediately when valid', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final form = SimpleDefaultSaveForm();
    TFormBase? savedResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedResult = await TFormService.show(context, form);
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Form'));
    await tester.pumpAndSettle();

    // Click Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Modal closes and returns form
    expect(find.text('Default Save Form'), findsNothing);
    expect(savedResult, same(form));
  });

  testWidgets('TCrudTable inline create form invokes onSave and respects return value', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final formInstance = ValidatedFormWithConfirmation();
    bool onCreateCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TCrudTable<String, String, ValidatedFormWithConfirmation>(
            headers: [
              TTableHeader<String, String>.map('Name', (x) => x),
            ],
            items: const ['Item 1'],
            itemKey: (x) => x,
            createForm: () => formInstance,
            onCreate: (form) async {
              onCreateCalled = true;
              return 'New Item';
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Click "Add New" button in top bar
    final addButton = find.text('Add New');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Form is displayed. Enter text.
    formInstance.name.value = 'Created Item';
    await tester.pumpAndSettle();

    // Click Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('Confirm Save'), findsOneWidget);
    expect(formInstance.onSaveCalled, isTrue);

    // Click "No"
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    // onCreate was NOT called
    expect(onCreateCalled, isFalse);

    // Click Save again
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Click "Yes"
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // onCreate was called!
    expect(onCreateCalled, isTrue);
  });

  testWidgets('TCrudTable supports unified form and onSave callback for create and edit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final savedActions = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TCrudTable<String, String, SimpleDefaultSaveForm>(
            headers: [
              TTableHeader<String, String>.map('Name', (x) => x),
            ],
            items: const ['Existing Item'],
            itemKey: (x) => x,
            createForm: () => SimpleDefaultSaveForm(),
            editForm: (item) {
              final form = SimpleDefaultSaveForm();
              form.name.value = item;
              return form;
            },
            onCreate: (form) async {
              savedActions.add('create: ${form.name.value}');
              return form.name.value;
            },
            onEdit: (item, form) async {
              savedActions.add('edit: $item -> ${form.name.value}');
              return form.name.value;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Test Create with onSave
    final addButton = find.text('Add New');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Save newly created item
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedActions, contains('create: Default Value'));

    // 2. Test Edit with onSave
    final editButton = find.byIcon(Icons.edit).first;
    expect(editButton, findsOneWidget);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Save edited item
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedActions, contains('edit: Default Value -> Default Value'));
  });
}

class _MockBuildContext extends Fake implements BuildContext {}

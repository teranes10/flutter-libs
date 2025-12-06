import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page showcasing all input field widgets.
class InputFieldsPage extends StatefulWidget {
  const InputFieldsPage({super.key});

  @override
  State<InputFieldsPage> createState() => _InputFieldsPageState();
}

class _InputFieldsPageState extends State<InputFieldsPage> {
  final _emailNotifier = ValueNotifier<String?>('');
  final _passwordNotifier = ValueNotifier<String?>('');
  final _quantityNotifier = ValueNotifier<double?>(null);

  @override
  void dispose() {
    _emailNotifier.dispose();
    _passwordNotifier.dispose();
    _quantityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Input Field Components',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Text inputs, number fields, and other input components with validation support.',
            style: TextStyle(
              fontSize: 13,
              color: context.colors.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),

          // Basic Text Field
          WidgetDocCard(
            title: 'Text Field',
            description: 'Single-line text input with label and placeholder',
            icon: Icons.text_fields,
            preview: TTextField(
              label: 'Full Name',
              placeholder: 'Enter your full name',
              helperText: 'First and last name',
              valueNotifier: ValueNotifier<String?>(''),
            ),
            code: '''TTextField(
  label: 'Full Name',
  placeholder: 'Enter your full name',
  helperText: 'First and last name',
  onValueChanged: (value) {
    print('Name: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'The label text displayed above the field',
              ),
              PropertyDoc(
                name: 'placeholder',
                type: 'String?',
                description: 'Placeholder text shown when field is empty',
              ),
              PropertyDoc(
                name: 'helperText',
                type: 'String?',
                description: 'Helper text displayed below the field',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<String?>?',
                description: 'Callback fired when the value changes',
              ),
            ],
          ),

          // Required Field with Validation
          WidgetDocCard(
            title: 'Required Field with Validation',
            description: 'Text field with required indicator and validation rules',
            icon: Icons.check_circle,
            preview: TTextField(
              label: 'Email',
              placeholder: 'Enter your email',
              isRequired: true,
              valueNotifier: _emailNotifier,
              rules: [
                Validations.requiredString('Email is required'),
                Validations.email('Please enter a valid email'),
              ],
            ),
            code: '''TTextField(
  label: 'Email',
  placeholder: 'Enter your email',
  isRequired: true,
  rules: [
    Validations.requiredString('Email is required'),
    Validations.email('Please enter a valid email'),
  ],
  onValueChanged: (value) {
    print('Email: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'isRequired',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether this field is required. Shows (*) indicator',
              ),
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(String?)>?',
                description: 'Validation rules. Each returns error message or null',
              ),
              PropertyDoc(
                name: 'validationDebounce',
                type: 'Duration?',
                description: 'Delay validation after user stops typing',
              ),
            ],
          ),

          // Multi-line Text Area
          WidgetDocCard(
            title: 'Multi-line Text Area',
            description: 'Text field with multiple rows for longer content',
            icon: Icons.notes,
            preview: TTextField(
              label: 'Description',
              placeholder: 'Enter a detailed description...',
              rows: 4,
              valueNotifier: ValueNotifier<String?>(''),
              rules: [
                Validations.maxLength(500, 'Description must be at most 500 characters'),
              ],
            ),
            code: '''TTextField(
  label: 'Description',
  placeholder: 'Enter a detailed description...',
  rows: 4, // Multi-line text area
  rules: [
    Validations.maxLength(
      500,
      'Description must be at most 500 characters',
    ),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'rows',
                type: 'int',
                defaultValue: '1',
                description: 'Number of rows. When > 1, becomes a text area',
              ),
            ],
          ),

          // Number Field
          WidgetDocCard(
            title: 'Number Field',
            description: 'Input field for numeric values with formatting',
            icon: Icons.numbers,
            preview: TNumberField(
              label: 'Quantity',
              placeholder: 'Enter quantity',
              isRequired: true,
              valueNotifier: _quantityNotifier,
              rules: [
                Validations.minValue(1, 'Quantity must be at least 1'),
                Validations.maxValue(999, 'Quantity cannot exceed 999'),
              ],
            ),
            code: '''TNumberField(
  label: 'Quantity',
  placeholder: 'Enter quantity',
  isRequired: true,
  rules: [
    Validations.minValue(1, 'Quantity must be at least 1'),
    Validations.maxValue(999, 'Quantity cannot exceed 999'),
  ],
  onValueChanged: (value) {
    print('Quantity: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'valueType',
                type: 'ValueType',
                defaultValue: 'ValueType.decimal',
                description: 'Type of number: decimal or integer',
              ),
              PropertyDoc(
                name: 'decimalPlaces',
                type: 'int?',
                description: 'Number of decimal places for decimal type',
              ),
            ],
          ),

          // Disabled Field
          WidgetDocCard(
            title: 'Disabled Field',
            description: 'Non-editable field with grayed out appearance',
            icon: Icons.block,
            preview: TTextField(
              label: 'Account ID',
              value: 'ACC-12345',
              disabled: true,
            ),
            code: '''TTextField(
  label: 'Account ID',
  value: 'ACC-12345',
  disabled: true,
)''',
            properties: const [
              PropertyDoc(
                name: 'disabled',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the field is disabled and cannot be edited',
              ),
            ],
          ),

          // Read-Only Field
          WidgetDocCard(
            title: 'Read-Only Field',
            description: 'Field that displays value but cannot be edited',
            icon: Icons.visibility,
            preview: TTextField(
              label: 'Username',
              value: 'john.doe',
              readOnly: true,
              helperText: 'Username cannot be changed',
            ),
            code: '''TTextField(
  label: 'Username',
  value: 'john.doe',
  readOnly: true,
  helperText: 'Username cannot be changed',
)''',
            properties: const [
              PropertyDoc(
                name: 'readOnly',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the field is read-only',
              ),
            ],
          ),

          // Tags Field
          WidgetDocCard(
            title: 'Tags Field',
            description: 'Input field for managing multiple tags',
            icon: Icons.label,
            preview: TTagsField(
              label: 'Tags',
              placeholder: 'Add tags...',
              textController: TTagsController(tags: ['Flutter', 'Dart', 'Mobile']),
            ),
            code: '''TTagsField(
  label: 'Tags',
  placeholder: 'Add tags...',
  textController: TTagsController(
    tags: ['Flutter', 'Dart', 'Mobile'],
  ),
  onValueChanged: (tags) {
    print('Tags: \$tags');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'textController',
                type: 'TTagsController?',
                description: 'Controller for managing the list of tags',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<List<String>?>?',
                description: 'Callback fired when tags change',
              ),
            ],
          ),

          // Value Notifier Binding
          WidgetDocCard(
            title: 'Two-Way Binding with ValueNotifier',
            description: 'Bind field value to a ValueNotifier for reactive updates',
            icon: Icons.sync,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TTextField(
                  label: 'Password',
                  placeholder: 'Enter password',
                  valueNotifier: _passwordNotifier,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<String?>(
                  valueListenable: _passwordNotifier,
                  builder: (context, value, _) {
                    return Text(
                      'Password length: ${value?.length ?? 0} characters',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.onSurface.withAlpha(153),
                      ),
                    );
                  },
                ),
              ],
            ),
            code: '''final passwordNotifier = ValueNotifier<String?>('');

TTextField(
  label: 'Password',
  placeholder: 'Enter password',
  valueNotifier: passwordNotifier,
)

// Listen to changes
ValueListenableBuilder<String?>(
  valueListenable: passwordNotifier,
  builder: (context, value, _) {
    return Text('Length: \${value?.length ?? 0}');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'valueNotifier',
                type: 'ValueNotifier<String?>?',
                description: 'ValueNotifier for two-way binding with the field value',
              ),
              PropertyDoc(
                name: 'value',
                type: 'String?',
                description: 'Initial value of the field',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

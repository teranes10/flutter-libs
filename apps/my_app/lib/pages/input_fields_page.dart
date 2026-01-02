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
  final _termsNotifier = ValueNotifier<bool?>(false);
  final _notificationsNotifier = ValueNotifier<bool>(false);
  final _interestsNotifier = ValueNotifier<List<String>>([]);

  @override
  void dispose() {
    _emailNotifier.dispose();
    _passwordNotifier.dispose();
    _quantityNotifier.dispose();
    _termsNotifier.dispose();
    _notificationsNotifier.dispose();
    _interestsNotifier.dispose();
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

          // Number Field with Clear Button
          WidgetDocCard(
            title: 'Number Field with Clear Button',
            description: 'Number field with clearable option to reset value',
            icon: Icons.clear,
            preview: TNumberField(
              label: 'Price',
              placeholder: 'Enter price',
              clearable: true,
              valueNotifier: ValueNotifier<double?>(null),
            ),
            code: '''TNumberField(
  label: 'Price',
  placeholder: 'Enter price',
  clearable: true, // Show clear button when field has a value
  onValueChanged: (value) {
    print('Price: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button when field has a value',
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

          // Tags Field with Clear Button
          WidgetDocCard(
            title: 'Tags Field with Clear Button',
            description: 'Tags field with clearable option to remove all tags',
            icon: Icons.clear_all,
            preview: TTagsField(
              label: 'Keywords',
              placeholder: 'Add keywords...',
              clearable: true,
              textController: TTagsController(tags: ['Flutter', 'Mobile', 'Development']),
            ),
            code: '''TTagsField(
  label: 'Keywords',
  placeholder: 'Add keywords...',
  clearable: true, // Show clear button when tags exist
  textController: TTagsController(
    tags: ['Flutter', 'Mobile', 'Development'],
  ),
  onValueChanged: (tags) {
    print('Tags: \$tags');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button to remove all tags',
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

          // Clear Button Example
          WidgetDocCard(
            title: 'Text Field with Clear Button',
            description: 'Enable clear button to allow users to quickly clear the field',
            icon: Icons.clear,
            preview: TTextField(
              label: 'Search',
              placeholder: 'Type to search...',
              clearable: true,
              valueNotifier: ValueNotifier<String?>(''),
            ),
            code: '''TTextField(
  label: 'Search',
  placeholder: 'Type to search...',
  clearable: true, // Enable clear button
  onValueChanged: (value) {
    print('Search: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button when field has a value',
              ),
            ],
          ),

          // ==================== CHECKBOX ====================

          // Basic Checkbox
          WidgetDocCard(
            title: 'Checkbox',
            description: 'Single checkbox for boolean selection',
            icon: Icons.check_box,
            preview: TCheckbox(
              label: 'I agree to the terms and conditions',
              valueNotifier: _termsNotifier,
            ),
            code: '''TCheckbox(
  label: 'I agree to the terms and conditions',
  onValueChanged: (value) {
    print('Checked: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'Label text displayed next to the checkbox',
              ),
              PropertyDoc(
                name: 'value',
                type: 'bool?',
                description: 'Current checkbox state (true, false, or null for indeterminate)',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<bool?>?',
                description: 'Callback fired when checkbox state changes',
              ),
            ],
          ),

          // Checkbox with Validation
          WidgetDocCard(
            title: 'Required Checkbox with Validation',
            description: 'Checkbox with required validation',
            icon: Icons.verified,
            preview: TCheckbox(
              label: 'I accept the privacy policy',
              isRequired: true,
              valueNotifier: ValueNotifier<bool?>(false),
              rules: [
                (value) {
                  if (value != true) return 'You must accept the privacy policy';
                  return null;
                },
              ],
            ),
            code: '''TCheckbox(
  label: 'I accept the privacy policy',
  isRequired: true,
  rules: [
    (value) {
      if (value != true) return 'You must accept the privacy policy';
      return null;
    },
  ],
  onValueChanged: (value) => print(value),
)''',
            properties: const [
              PropertyDoc(
                name: 'isRequired',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the checkbox is required',
              ),
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(bool?)>?',
                description: 'Validation rules for the checkbox',
              ),
            ],
          ),

          // ==================== CHECKBOX GROUP ====================

          // Basic Checkbox Group
          WidgetDocCard(
            title: 'Checkbox Group',
            description: 'Multiple checkbox selection with group management',
            icon: Icons.checklist,
            preview: TCheckboxGroup<String>(
              label: 'Interests',
              items: [
                TCheckboxGroupItem.map('Technology'),
                TCheckboxGroupItem.map('Sports'),
                TCheckboxGroupItem.map('Music'),
                TCheckboxGroupItem.map('Travel'),
              ],
              valueNotifier: _interestsNotifier,
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Interests',
  items: [
    TCheckboxGroupItem.map('Technology'),
    TCheckboxGroupItem.map('Sports'),
    TCheckboxGroupItem.map('Music'),
    TCheckboxGroupItem.map('Travel'),
  ],
  onValueChanged: (selected) {
    print('Selected: \$selected');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'items',
                type: 'List<TCheckboxGroupItem<T>>',
                description: 'List of checkbox items to display',
              ),
              PropertyDoc(
                name: 'value',
                type: 'List<T>?',
                description: 'Currently selected values',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<List<T>?>?',
                description: 'Callback fired when selection changes',
              ),
            ],
          ),

          // Checkbox Group Layouts
          WidgetDocCard(
            title: 'Checkbox Group Layouts',
            description: 'Vertical and horizontal layouts for checkbox groups',
            icon: Icons.view_agenda,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horizontal Layout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TCheckboxGroup<String>(
                  label: 'Preferences',
                  items: [
                    TCheckboxGroupItem.map('Email'),
                    TCheckboxGroupItem.map('SMS'),
                    TCheckboxGroupItem.map('Push'),
                  ],
                  vertical: false,
                  valueNotifier: ValueNotifier<List<String>>([]),
                ),
                const SizedBox(height: 20),
                Text(
                  'Vertical Layout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TCheckboxGroup<String>(
                  label: 'Features',
                  items: [
                    TCheckboxGroupItem.map('Dark Mode'),
                    TCheckboxGroupItem.map('Notifications'),
                    TCheckboxGroupItem.map('Auto-save'),
                  ],
                  vertical: true,
                  valueNotifier: ValueNotifier<List<String>>([]),
                ),
              ],
            ),
            code: '''// Horizontal Layout
TCheckboxGroup<String>(
  label: 'Preferences',
  items: [
    TCheckboxGroupItem.map('Email'),
    TCheckboxGroupItem.map('SMS'),
    TCheckboxGroupItem.map('Push'),
  ],
  vertical: false, // Horizontal layout
)

// Vertical Layout
TCheckboxGroup<String>(
  label: 'Features',
  items: [
    TCheckboxGroupItem.map('Dark Mode'),
    TCheckboxGroupItem.map('Notifications'),
    TCheckboxGroupItem.map('Auto-save'),
  ],
  vertical: true, // Vertical layout (default)
)''',
            properties: const [
              PropertyDoc(
                name: 'vertical',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to display checkboxes vertically',
              ),
              PropertyDoc(
                name: 'block',
                type: 'bool',
                defaultValue: 'true',
                description: 'Whether checkboxes should take full width',
              ),
            ],
          ),

          // Checkbox Group with Validation
          WidgetDocCard(
            title: 'Checkbox Group with Validation',
            description: 'Validate minimum/maximum selections',
            icon: Icons.rule,
            preview: TCheckboxGroup<String>(
              label: 'Select Skills (min 2, max 4)',
              isRequired: true,
              items: [
                TCheckboxGroupItem.map('Flutter'),
                TCheckboxGroupItem.map('React'),
                TCheckboxGroupItem.map('Vue'),
                TCheckboxGroupItem.map('Angular'),
                TCheckboxGroupItem.map('Node.js'),
              ],
              valueNotifier: ValueNotifier<List<String>>([]),
              rules: [
                (selected) {
                  if (selected == null || selected.isEmpty) {
                    return 'Please select at least 2 skills';
                  }
                  if (selected.length < 2) {
                    return 'Please select at least 2 skills';
                  }
                  if (selected.length > 4) {
                    return 'Please select at most 4 skills';
                  }
                  return null;
                },
              ],
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Select Skills (min 2, max 4)',
  isRequired: true,
  items: [
    TCheckboxGroupItem.map('Flutter'),
    TCheckboxGroupItem.map('React'),
    TCheckboxGroupItem.map('Vue'),
    TCheckboxGroupItem.map('Angular'),
    TCheckboxGroupItem.map('Node.js'),
  ],
  rules: [
    (selected) {
      if (selected == null || selected.isEmpty) {
        return 'Please select at least 2 skills';
      }
      if (selected.length < 2) {
        return 'Please select at least 2 skills';
      }
      if (selected.length > 4) {
        return 'Please select at most 4 skills';
      }
      return null;
    },
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(List<T>?)>?',
                description: 'Validation rules for the checkbox group',
              ),
            ],
          ),

          // Checkbox Group with Clear Button
          WidgetDocCard(
            title: 'Checkbox Group with Clear Button',
            description: 'Checkbox group with clearable option to deselect all',
            icon: Icons.clear_all,
            preview: TCheckboxGroup<String>(
              label: 'Notifications',
              clearable: true,
              items: [
                TCheckboxGroupItem.map('Email Updates'),
                TCheckboxGroupItem.map('SMS Alerts'),
                TCheckboxGroupItem.map('Push Notifications'),
                TCheckboxGroupItem.map('Newsletter'),
              ],
              valueNotifier: ValueNotifier<List<String>>(['Email Updates', 'Push Notifications']),
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Notifications',
  clearable: true, // Show clear button when items are selected
  items: [
    TCheckboxGroupItem.map('Email Updates'),
    TCheckboxGroupItem.map('SMS Alerts'),
    TCheckboxGroupItem.map('Push Notifications'),
    TCheckboxGroupItem.map('Newsletter'),
  ],
  value: ['Email Updates', 'Push Notifications'],
  onValueChanged: (selected) {
    print('Selected: \$selected');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button to deselect all items',
              ),
            ],
          ),

          // ==================== SWITCH ====================

          // Basic Switch
          WidgetDocCard(
            title: 'Switch (Toggle)',
            description: 'Toggle switch for boolean settings',
            icon: Icons.toggle_on,
            preview: TSwitch(
              label: 'Enable Notifications',
              valueNotifier: _notificationsNotifier,
            ),
            code: '''TSwitch(
  label: 'Enable Notifications',
  onValueChanged: (value) {
    print('Notifications: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'Label text displayed next to the switch',
              ),
              PropertyDoc(
                name: 'value',
                type: 'bool',
                defaultValue: 'false',
                description: 'Current switch state',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<bool?>?',
                description: 'Callback fired when switch state changes',
              ),
            ],
          ),

          // Switch States
          WidgetDocCard(
            title: 'Switch States and Sizes',
            description: 'Different switch states, sizes, and colors',
            icon: Icons.settings,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TSwitch(
                  label: 'Enabled (On)',
                  value: true,
                  onValueChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TSwitch(
                  label: 'Enabled (Off)',
                  value: false,
                  onValueChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TSwitch(
                  label: 'Disabled (On)',
                  value: true,
                  disabled: true,
                  onValueChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TSwitch(
                  label: 'Disabled (Off)',
                  value: false,
                  disabled: true,
                  onValueChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TSwitch(
                  label: 'Small Size',
                  value: true,
                  size: TInputSize.sm,
                  onValueChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TSwitch(
                  label: 'Large Size',
                  value: true,
                  size: TInputSize.lg,
                  onValueChanged: (_) {},
                ),
              ],
            ),
            code: '''// On state
TSwitch(
  label: 'Enabled (On)',
  value: true,
)

// Off state
TSwitch(
  label: 'Enabled (Off)',
  value: false,
)

// Disabled
TSwitch(
  label: 'Disabled',
  value: true,
  disabled: true,
)

// Different sizes
TSwitch(
  label: 'Small',
  value: true,
  size: TInputSize.sm,
)

TSwitch(
  label: 'Large',
  value: true,
  size: TInputSize.lg,
)''',
            properties: const [
              PropertyDoc(
                name: 'disabled',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the switch is disabled',
              ),
              PropertyDoc(
                name: 'size',
                type: 'TInputSize?',
                description: 'Size of the switch (sm, md, lg)',
              ),
              PropertyDoc(
                name: 'color',
                type: 'Color?',
                description: 'Custom color for the switch when active',
              ),
            ],
          ),

          // Switch with Validation
          WidgetDocCard(
            title: 'Switch with Validation',
            description: 'Required switch with validation rules',
            icon: Icons.verified,
            preview: TSwitch(
              label: 'I confirm I am 18 years or older',
              isRequired: true,
              valueNotifier: ValueNotifier<bool>(false),
              rules: [
                (value) {
                  if (value != true) return 'You must confirm you are 18 or older';
                  return null;
                },
              ],
            ),
            code: '''TSwitch(
  label: 'I confirm I am 18 years or older',
  isRequired: true,
  rules: [
    (value) {
      if (value != true) return 'You must confirm you are 18 or older';
      return null;
    },
  ],
  onValueChanged: (value) => print(value),
)''',
            properties: const [
              PropertyDoc(
                name: 'isRequired',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the switch is required',
              ),
              PropertyDoc(
                name: 'rules',
                type: 'List<String? Function(bool?)>?',
                description: 'Validation rules for the switch',
              ),
            ],
          ),

          // ==================== FILE PICKER ====================

          // Basic File Picker
          WidgetDocCard(
            title: 'File Picker',
            description: 'File upload widget with file type restrictions',
            icon: Icons.upload_file,
            preview: TFilePicker(
              label: 'Upload Document',
              placeholder: 'Choose file',
              valueNotifier: ValueNotifier<List<TFile>>([]),
            ),
            code: '''TFilePicker(
  label: 'Upload Document',
  placeholder: 'Choose file',
  onValueChanged: (files) {
    print('Selected files: \${files?.length}');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'label',
                type: 'String?',
                description: 'Label text displayed above the field',
              ),
              PropertyDoc(
                name: 'placeholder',
                type: 'String?',
                description: 'Placeholder text when no file is selected',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<List<TFile>?>?',
                description: 'Callback fired when file selection changes',
              ),
            ],
          ),

          // File Picker with Clear Button
          WidgetDocCard(
            title: 'File Picker with Clear Button',
            description: 'File picker with clearable option to remove selected files',
            icon: Icons.clear,
            preview: TFilePicker(
              label: 'Upload Images',
              placeholder: 'Choose images',
              clearable: true,
              allowMultiple: true,
              fileType: TFileType.image,
              valueNotifier: ValueNotifier<List<TFile>>([]),
            ),
            code: '''TFilePicker(
  label: 'Upload Images',
  placeholder: 'Choose images',
  clearable: true, // Show clear button when files are selected
  allowMultiple: true,
  fileType: TFileType.image,
  onValueChanged: (files) {
    print('Selected \${files?.length} images');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button to remove all files',
              ),
              PropertyDoc(
                name: 'allowMultiple',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to allow multiple file selection',
              ),
              PropertyDoc(
                name: 'fileType',
                type: 'TFileType',
                defaultValue: 'TFileType.any',
                description: 'Type of files to allow (any, image, video, audio, custom)',
              ),
              PropertyDoc(
                name: 'allowedExtensions',
                type: 'List<String>?',
                description: 'List of allowed file extensions (e.g., [\'pdf\', \'doc\'])',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

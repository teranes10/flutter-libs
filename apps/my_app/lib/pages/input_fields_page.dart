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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Input Field Components',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Text inputs, number fields, and other input components with validation support.',
            style: TextStyle(fontSize: 13, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          // Basic Text Field
          WidgetDocCard(
            title: 'Text Field',
            description: 'Single-line text input with label and placeholder',
            icon: Icons.text_fields,
            preview: TTextField(
              label: 'Full Name',
              info: 'Please enter your full name as it appears on your ID',
              placeholder: 'Enter your full name',
              helperText: 'First and last name',
              valueNotifier: ValueNotifier<String?>(''),
            ),
            code: '''TTextField(
  label: 'Full Name',
  info: 'Please enter your full name as it appears on your ID',
  placeholder: 'Enter your full name',
  helperText: 'First and last name',
  onValueChanged: (value) {
    print('Name: \$value');
  },
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String?', description: 'The label text displayed above the field'),
              PropertyDoc(name: 'info', type: 'String?', description: 'Informational text displayed in a tooltip'),
              PropertyDoc(name: 'placeholder', type: 'String?', description: 'Placeholder text shown when field is empty'),
              PropertyDoc(name: 'helperText', type: 'String?', description: 'Helper text displayed below the field'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<String?>?', description: 'Callback fired when the value changes'),
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
              rules: [Validations.requiredString('Email is required'), Validations.email('Please enter a valid email')],
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
              PropertyDoc(name: 'validationDebounce', type: 'Duration?', description: 'Delay validation after user stops typing'),
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
              rows: 3,
              valueNotifier: ValueNotifier<String?>(''),
              rules: [Validations.maxLength(500, 'Description must be at most 500 characters')],
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
              PropertyDoc(name: 'rows', type: 'int', defaultValue: '1', description: 'Number of rows. When > 1, becomes a text area'),
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
              rules: [Validations.minValue(1, 'Quantity must be at least 1'), Validations.maxValue(999, 'Quantity cannot exceed 999')],
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
              PropertyDoc(name: 'decimalPlaces', type: 'int?', description: 'Number of decimal places for decimal type'),
            ],
          ),

          // Flanked Number Field (Split Stepper)
          WidgetDocCard(
            title: 'Flanked Number Field (Split Stepper)',
            description: 'TNumberField with splitStepper: true placing the minus button in pre-widget and plus button in post-widget',
            icon: Icons.unfold_more,
            preview: TNumberField(label: 'Adjust Value', placeholder: '0', splitStepper: true, valueNotifier: ValueNotifier<double?>(10.0)),
            code: '''TNumberField(
  label: 'Adjust Value',
  placeholder: '0',
  splitStepper: true, // Flanks layout: minus on left, plus on right
  onValueChanged: (value) => print(value),
)''',
          ),

          // Number Field with Clear Button
          WidgetDocCard(
            title: 'Number Field with Clear Button',
            description: 'Number field with clearable option to reset value',
            icon: Icons.clear,
            preview: TNumberField(label: 'Price', placeholder: 'Enter price', clearable: true, valueNotifier: ValueNotifier<double?>(null)),
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

          // Quantity Stepper Variant (Handheld / Touch Flow)
          WidgetDocCard(
            title: 'Quantity Stepper Variant',
            description:
                'Touch-optimized quantity stepper with large 64dp buttons, min/max clamping, unit caption, and quick-add preset chips',
            icon: Icons.add_circle_outline_rounded,
            preview: SizedBox(
              width: 340,
              child: TNumberField<int>(
                label: 'Confirm Pick Quantity',
                variant: TNumberFieldVariant.quantity,
                value: 4,
                min: 0,
                max: 24,
                unit: 'boxes (12 pcs each)',
                presets: const [1, 5, 10],
                onValueChanged: (value) => debugPrint('Quantity: $value'),
              ),
            ),
            code: '''TNumberField<int>(
  label: 'Confirm Pick Quantity',
  variant: TNumberFieldVariant.quantity,
  value: 4,
  min: 0,
  max: 24,
  unit: 'boxes (12 pcs each)',
  presets: [1, 5, 10], // Quick-add preset chips (+1, +5, +10) + 'Max' chip
  onValueChanged: (value) {
    print('Quantity: \$value');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'variant',
                type: 'TNumberFieldVariant',
                defaultValue: 'TNumberFieldVariant.field',
                description: 'Visual presentation: field (standard input) or quantity (handheld touch stepper)',
              ),
              PropertyDoc(name: 'min', type: 'num?', description: 'Minimum allowed value; steppers clamp to this boundary'),
              PropertyDoc(name: 'max', type: 'num?', description: 'Maximum allowed value; steppers clamp to this and renders "Max" chip'),
              PropertyDoc(
                name: 'presets',
                type: 'List<num>',
                defaultValue: '[]',
                description: 'Quick-add chips (+1, +5, ...) shown under quantity stepper',
              ),
              PropertyDoc(
                name: 'unit',
                type: 'String?',
                description: 'Unit caption displayed below the numeric value (e.g. boxes, pcs, kg)',
              ),
            ],
          ),

          // Number Field with Min & Max Bounds
          WidgetDocCard(
            title: 'Number Field with Min & Max Bounds',
            description: 'Standard number field with min and max constraints clamping stepper increments and input',
            icon: Icons.tune_rounded,
            preview: TNumberField<double>(
              label: 'Discount Percentage',
              placeholder: '0',
              value: 15.0,
              min: 0,
              max: 100,
              splitStepper: true,
              helperText: 'Value clamped between 0% and 100%',
              onValueChanged: (v) => debugPrint('Discount: $v'),
            ),
            code: '''TNumberField<double>(
  label: 'Discount Percentage',
  placeholder: '0',
  value: 15.0,
  min: 0,
  max: 100, // Clamps values between 0 and 100
  splitStepper: true,
  helperText: 'Value clamped between 0% and 100%',
  onValueChanged: (value) => print('Discount: \$value%'),
)''',
            properties: const [
              PropertyDoc(name: 'min', type: 'num?', description: 'Lowest value allowed for steppers and validation clamping'),
              PropertyDoc(name: 'max', type: 'num?', description: 'Highest value allowed for steppers and validation clamping'),
              PropertyDoc(
                name: 'splitStepper',
                type: 'bool?',
                description: 'Places decrement button in pre-widget and increment in post-widget',
              ),
            ],
          ),

          // Disabled Field
          WidgetDocCard(
            title: 'Disabled Field',
            description: 'Non-editable field with grayed out appearance',
            icon: Icons.block,
            preview: TTextField(label: 'Account ID', value: 'ACC-12345', disabled: true),
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

          // Above Label Position
          WidgetDocCard(
            title: 'Above Label Position',
            description: 'Label positioned above the field with info icon next to it',
            icon: Icons.vertical_align_top,
            preview: Builder(
              builder: (context) {
                return TTextField(
                  label: 'Username',
                  info: 'Your unique identifier on the platform',
                  placeholder: 'Enter username',
                  theme: context.theme.textFieldTheme.copyWith(labelPosition: TLabelPosition.aboveField),
                );
              },
            ),
            code: '''TTextField(
  label: 'Username',
  info: 'Your unique identifier on the platform',
  placeholder: 'Enter username',
  theme: context.theme.textFieldTheme.copyWith(
    labelPosition: TLabelPosition.aboveField,
  ),
)''',
            properties: const [
              PropertyDoc(
                name: 'labelPosition',
                type: 'TLabelPosition',
                defaultValue: 'TLabelPosition.floating',
                description: 'Position of the label: floating (inside) or aboveField (outside)',
              ),
            ],
          ),

          // Read-Only Field
          WidgetDocCard(
            title: 'Read-Only Field',
            description: 'Field that displays value but cannot be edited',
            icon: Icons.visibility,
            preview: TTextField(label: 'Username', value: 'john.doe', readOnly: true, helperText: 'Username cannot be changed'),
            code: '''TTextField(
  label: 'Username',
  value: 'john.doe',
  readOnly: true,
  helperText: 'Username cannot be changed',
)''',
            properties: const [
              PropertyDoc(name: 'readOnly', type: 'bool', defaultValue: 'false', description: 'Whether the field is read-only'),
            ],
          ),

          // Tags Field
          WidgetDocCard(
            title: 'Tags Field',
            description: 'Input field for managing multiple tags',
            icon: Icons.label,
            preview: TTagsField(label: 'Tags', placeholder: 'Add tags...'),
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
              PropertyDoc(name: 'textController', type: 'TTagsController?', description: 'Controller for managing the list of tags'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<List<String>?>?', description: 'Callback fired when tags change'),
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

          // Date Time Text Field
          WidgetDocCard(
            title: 'Date/Time Formatted Field',
            description: 'Text field with automatic date/time formatting and masking',
            icon: Icons.calendar_month,
            preview: Column(
              children: [
                TDateTimeTextField(label: 'Date', formatType: TDateTimeFormatType.date, onValueChanged: (v) => debugPrint('Date: $v')),
                const SizedBox(height: 16),
                TDateTimeTextField(label: 'Time', formatType: TDateTimeFormatType.time, onValueChanged: (v) => debugPrint('Time: $v')),
                const SizedBox(height: 16),
                TDateTimeTextField(
                  label: 'Date & Time',
                  formatType: TDateTimeFormatType.dateTime,
                  onValueChanged: (v) => debugPrint('DateTime: $v'),
                ),
              ],
            ),
            code: '''TDateTimeTextField(
  label: 'Date',
  formatType: TDateTimeFormatType.date,
  onValueChanged: (value) {
    print('Date: \$value');
  },
)

TDateTimeTextField(
  label: 'Time',
  formatType: TDateTimeFormatType.time,
)

TDateTimeTextField(
  label: 'Date & Time',
  formatType: TDateTimeFormatType.dateTime,
)''',
            properties: const [
              PropertyDoc(
                name: 'formatType',
                type: 'TDateTimeFormatType',
                defaultValue: 'TDateTimeFormatType.date',
                description: 'Format to apply: date (DD/MM/YY), time (HH:MM), or dateTime',
              ),
              PropertyDoc(name: 'placeholder', type: 'String?', description: 'Custom placeholder. Defaults to format (e.g., DD/MM/YY)'),
            ],
          ),

          // Phone Field
          WidgetDocCard(
            title: 'Phone Number Field',
            description: 'Phone input with country code selection and automatic formatting',
            icon: Icons.phone,
            preview: TPhoneField(label: 'Phone Number', isRequired: true, onValueChanged: (v) => debugPrint('Phone: $v')),
            code: '''TPhoneField(
  label: 'Phone Number',
  isRequired: true,
  onValueChanged: (value) {
    print('Phone: \$value');
  },
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String?', description: 'The label text displayed above the field'),
              PropertyDoc(name: 'initialCountry', type: 'TCountry?', description: 'The initially selected country'),
              PropertyDoc(name: 'isRequired', type: 'bool', defaultValue: 'false', description: 'Whether this field is required'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<String>?', description: 'Callback with dial code + formatted number'),
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
                TTextField(label: 'Password', placeholder: 'Enter password', valueNotifier: _passwordNotifier),
                const SizedBox(height: 4),
                ValueListenableBuilder<String?>(
                  valueListenable: _passwordNotifier,
                  builder: (context, value, _) {
                    return Text(
                      'Password length: ${value?.length ?? 0} characters',
                      style: TextStyle(fontSize: 13, color: context.colors.onSurface.withAlpha(153)),
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
              PropertyDoc(name: 'value', type: 'String?', description: 'Initial value of the field'),
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

          // ==================== FILE PICKER ====================

          // Basic File Picker
          WidgetDocCard(
            title: 'File Picker',
            description: 'File upload widget with file type restrictions',
            icon: Icons.upload_file,
            preview: TFilePicker(label: 'Upload Document', placeholder: 'Choose file', valueNotifier: ValueNotifier<List<TFile>>([])),
            code: '''TFilePicker(
  label: 'Upload Document',
  placeholder: 'Choose file',
  onValueChanged: (files) {
    print('Selected files: \${files?.length}');
  },
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String?', description: 'Label text displayed above the field'),
              PropertyDoc(name: 'placeholder', type: 'String?', description: 'Placeholder text when no file is selected'),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<List<TFile>?>?',
                description: 'Callback fired when file selection changes',
              ),
            ],
          ),

          // Multiple File Picker
          WidgetDocCard(
            title: 'Multiple File Picker',
            description: 'File picker allowing selection of multiple files at once',
            icon: Icons.file_copy,
            preview: TFilePicker(
              label: 'Upload Multiple Documents',
              placeholder: 'Choose files',
              allowMultiple: true,
              valueNotifier: ValueNotifier<List<TFile>>([]),
            ),
            code: '''TFilePicker(
  label: 'Upload Multiple Documents',
  placeholder: 'Choose files',
  allowMultiple: true,
  onValueChanged: (files) {
    print('Selected \${files?.length} files');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'allowMultiple',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to allow selecting multiple files at once',
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

          // File Picker with onAdd and onRemove Events
          WidgetDocCard(
            title: 'File Picker with onAdd & onRemove Events',
            description: 'Receive real-time callbacks with List<TFile> whenever files are added or removed (individually or cleared).',
            icon: Icons.playlist_add_check_rounded,
            preview: TFilePicker(
              label: 'Upload Attachments',
              placeholder: 'Choose files to observe events',
              allowMultiple: true,
              clearable: true,
              valueNotifier: ValueNotifier<List<TFile>>([]),
              onAdd: (addedFiles) {
                TToastService.success(context, 'Added ${addedFiles.length} file(s): ${addedFiles.map((f) => f.name).join(', ')}');
              },
              onRemove: (removedFiles) {
                TToastService.warning(context, 'Removed ${removedFiles.length} file(s): ${removedFiles.map((f) => f.name).join(', ')}');
              },
            ),
            code: '''TFilePicker(
  label: 'Upload Attachments',
  placeholder: 'Choose files',
  allowMultiple: true,
  clearable: true,
  onAdd: (addedFiles) {
    // List<TFile> of newly added files
    print('Added \${addedFiles.length} files: \${addedFiles.map((f) => f.name)}');
  },
  onRemove: (removedFiles) {
    // List<TFile> of removed files (via individual delete or clear all)
    print('Removed \${removedFiles.length} files: \${removedFiles.map((f) => f.name)}');
  },
  onValueChanged: (allFiles) {
    // Current total list of files
    print('Total files: \${allFiles?.length}');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'onAdd',
                type: 'ValueChanged<List<TFile>>?',
                description: 'Callback fired when new files are selected and added, passing the list of newly added files.',
              ),
              PropertyDoc(
                name: 'onRemove',
                type: 'ValueChanged<List<TFile>>?',
                description:
                    'Callback fired when files are removed (either individually or all at once), passing the list of removed files.',
              ),
              PropertyDoc(
                name: 'onValueChanged',
                type: 'ValueChanged<List<TFile>?>?',
                description: 'Callback fired whenever the file list changes, passing the full current list of files.',
              ),
            ],
          ),

          // File Picker Gallery Mode
          WidgetDocCard(
            title: 'File Picker Gallery Mode',
            description: 'Image file picker displaying selected images as 100x100 TImage thumbnails with hover title/subtitle overlays',
            icon: Icons.collections,
            preview: TFilePicker(
              label: 'Image Gallery Picker',
              placeholder: 'Choose gallery images',
              allowMultiple: true,
              isGalleryMode: true,
              fileType: TFileType.image,
              clearable: true,
            ),
            code: '''TFilePicker(
  label: 'Image Gallery Picker',
  placeholder: 'Choose gallery images',
  allowMultiple: true,
  isGalleryMode: true, // Display 100x100 TImage thumbnails
  fileType: TFileType.image,
  onValueChanged: (files) {
    print('Selected \${files?.length} images in gallery mode');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'isGalleryMode',
                type: 'bool',
                defaultValue: 'false',
                description: 'Displays selected files as 100x100 TImage thumbnails with hover title/subtitle overlay',
              ),
              PropertyDoc(
                name: 'showTitleSubtitleOverlayOnHover',
                type: 'bool',
                defaultValue: 'false',
                description: 'TImage property to render title and subtitle as a gradient overlay on mouse hover',
              ),
            ],
          ),

          // File Picker Camera Source
          WidgetDocCard(
            title: 'Camera File Picker (Direct Photo Capture)',
            description: 'Directly launches device camera to capture proof photos or damage evidence, with automatic image downscaling.',
            icon: Icons.photo_camera_rounded,
            preview: TFilePicker(
              label: 'Proof of Delivery Photo',
              placeholder: 'Take photo with camera',
              source: TFilePickerSource.camera,
              fileType: TFileType.image,
              maxImageDimension: 1600,
              imageQuality: 85,
              clearable: true,
            ),
            code: '''TFilePicker(
  label: 'Proof of Delivery Photo',
  placeholder: 'Take photo with camera',
  source: TFilePickerSource.camera, // Direct camera capture
  fileType: TFileType.image,
  maxImageDimension: 1600, // Downscales photo longest side to 1600px
  imageQuality: 85,
  onValueChanged: (files) {
    print('Captured photo: \${files?.first.name}');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'source',
                type: 'TFilePickerSource',
                defaultValue: 'TFilePickerSource.files',
                description: 'Source for files: files (browser), camera (direct photo), or filesOrCamera (picker option)',
              ),
              PropertyDoc(
                name: 'maxImageDimension',
                type: 'double',
                defaultValue: '1600',
                description: 'Longest side dimension (px) captured photos are downscaled to',
              ),
              PropertyDoc(
                name: 'imageQuality',
                type: 'int',
                defaultValue: '85',
                description: 'JPEG compression quality (1-100) for captured photos',
              ),
            ],
          ),

          // File Picker Files or Camera Source
          WidgetDocCard(
            title: 'Files or Camera Picker (Dual Source)',
            description: 'Prompts user to choose between capturing a photo with the camera or selecting an existing file from the gallery / device.',
            icon: Icons.add_a_photo_rounded,
            preview: TFilePicker(
              label: 'Damage Evidence Photo / Document',
              placeholder: 'Capture photo or choose file',
              source: TFilePickerSource.filesOrCamera,
              allowMultiple: true,
              clearable: true,
            ),
            code: '''TFilePicker(
  label: 'Damage Evidence Photo / Document',
  placeholder: 'Capture photo or choose file',
  source: TFilePickerSource.filesOrCamera, // Shows selection modal: Camera or File Browser
  allowMultiple: true,
  clearable: true,
  onValueChanged: (files) {
    print('Selected \${files?.length} files from camera/gallery');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'source',
                type: 'TFilePickerSource',
                defaultValue: 'TFilePickerSource.files',
                description: 'Source mode: filesOrCamera prompts user to select between Camera or File Manager',
              ),
              PropertyDoc(
                name: 'allowMultiple',
                type: 'bool',
                defaultValue: 'false',
                description: 'Allows picking multiple files or capturing multiple photos sequentially',
              ),
            ],
          ),

          // Signature Pad
          WidgetDocCard(
            title: 'Signature Pad (TSignaturePad)',
            description: 'Touch / stylus canvas for proof-of-delivery, sign-offs, and agreement approvals.',
            icon: Icons.draw_rounded,
            preview: SizedBox(
              width: 400,
              child: TSignaturePad(
                hint: 'Sign here',
                onChanged: (hasInk) => debugPrint('Signature changed: $hasInk'),
              ),
            ),
            code: '''final controller = TSignaturePadController();

TSignaturePad(
  controller: controller,
  height: 200,
  hint: 'Sign here',
  onChanged: (hasInk) => print('Signed: \$hasInk'),
)

// Later export to PNG bytes
final pngBytes = await controller.toPngBytes();''',
            properties: const [
              PropertyDoc(
                name: 'controller',
                type: 'TSignaturePadController?',
                description: 'Controller to clear, undo, or export signature PNG bytes',
              ),
              PropertyDoc(name: 'height', type: 'double', defaultValue: '200', description: 'Canvas height in logical pixels'),
              PropertyDoc(name: 'penColor', type: 'Color?', description: 'Ink color (defaults to theme onSurface)'),
              PropertyDoc(name: 'penWidth', type: 'double', defaultValue: '3', description: 'Thickness of the drawn stroke'),
              PropertyDoc(name: 'hint', type: 'String', defaultValue: '\'Sign here\'', description: 'Hint text displayed when canvas is empty'),
              PropertyDoc(name: 'showClear', type: 'bool', defaultValue: 'true', description: 'Whether to show the Clear action button when signed'),
              PropertyDoc(
                name: 'onChanged',
                type: 'ValueChanged<bool>?',
                description: 'Callback fired when signature state changes between empty and signed',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

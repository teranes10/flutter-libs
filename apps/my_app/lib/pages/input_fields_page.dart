import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class InputFieldsPage extends StatefulWidget {
  const InputFieldsPage({super.key});

  @override
  State<InputFieldsPage> createState() => _InputFieldsPageState();
}

class _InputFieldsPageState extends State<InputFieldsPage> {
  int integerValue = 10;
  double doubleValue = 100;
  bool? singleCheckbox = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 20.0,
        children: [
          TTextField(
            label: 'Order No',
            placeholder: 'Enter a order no',
            tag: 'Required',
            isRequired: true,
            rules: [
              (value) => value == null || value.length < 2 ? 'Name must be at least 2 characters' : null,
              (value) => value == null || !value.startsWith('Order#') ? 'Order number must be start with Order#' : null,
            ],
          ),
          TTextField(
            label: 'Disabled',
            placeholder: 'Disabled field',
            disabled: true,
          ),
          TTagsField(
            label: "Skills",
            placeholder: 'Add a tag and press Enter',
            value: ["Flutter", "Dart"],
          ),
          TTextField(
            label: 'Description',
            placeholder: 'Enter description',
            rows: 4,
            helperText: 'This is a helper text',
          ),
          TNumberField<int>(
            label: "Age",
            value: integerValue,
          ),
          TNumberField<double>(
            label: "Price",
            value: doubleValue,
            rules: [(value) => value == null || value < 100 ? 'Value must be greater than 100' : null],
          ),
          TDatePicker(
            value: DateTime.now(),
            label: 'Select Date',
            placeholder: 'Choose a date',
          ),
          TTimePicker(
            label: 'Select Time',
            placeholder: 'Choose a time',
          ),
          TDateTimePicker(
            label: 'Select Date & Time',
            placeholder: 'Choose date and time',
          ),
          TCheckbox(
            label: 'Checkbox (sm)',
            value: singleCheckbox,
            onValueChanged: (v) => setState(() => singleCheckbox = v),
            size: TInputSize.sm,
          ),
          TCheckbox(
            label: 'Checkbox (md)',
            value: singleCheckbox,
            onValueChanged: (v) => setState(() => singleCheckbox = v),
            size: TInputSize.md,
          ),
          TCheckbox(
            label: 'Checkbox (lg)',
            value: singleCheckbox,
            onValueChanged: (v) => setState(() => singleCheckbox = v),
            size: TInputSize.lg,
          ),
          TCheckboxGroup<String>(
            label: 'Fruits',
            items: [TCheckboxGroupItem.map('Apple'), TCheckboxGroupItem.map('Banana'), TCheckboxGroupItem.map('Orange')],
            value: ['Apple'],
          ),
          TSwitch(label: 'Switch'),
          TFilePicker(label: 'File Picker'),
        ],
      ),
    ));
  }
}

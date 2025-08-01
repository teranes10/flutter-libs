import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class InputFieldsPage extends StatefulWidget {
  const InputFieldsPage({super.key});

  @override
  State<InputFieldsPage> createState() => _InputFieldsPageState();
}

class _InputFieldsPageState extends State<InputFieldsPage> {
  int integerValue = 10;
  double doubleValue = 10.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
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
            message: 'This is a message',
          ),
          TNumberField<int>(
            label: "Age",
            value: integerValue,
          ),
          TNumberField<double>(
            label: "Price",
            value: doubleValue,
            decimals: 2,
            rules: [(value) => value == null || value < 100 ? 'Value must be greater than 100' : null],
          ),
          TDatePicker(
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
          TButton(
            text: 'time',
            onPressed: (_) {
              showTimePicker(context: context, initialEntryMode: TimePickerEntryMode.dialOnly, initialTime: DateTime.now().toTimeOfDay);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/number-field/number_field.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';
import 'package:te_widgets/widgets/tags-field/tags_field.dart';

class InputFieldsPage extends StatefulWidget {
  const InputFieldsPage({super.key});

  @override
  State<InputFieldsPage> createState() => _InputFieldsPageState();
}

class _InputFieldsPageState extends State<InputFieldsPage> {
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
            isRequired: true,
            rules: [
              (value) => value == null || value.length < 2 ? 'Name must be at least 2 characters' : null,
              (value) => value == null || !value.startsWith('Order#') ? 'Order number must be start with Order#' : null,
            ],
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
          ),
          TNumberField<double>(
            label: "Price",
            decimals: 2,
            rules: [(value) => value == null || value < 100 ? 'Value must be greater than 100' : null],
          ),
        ],
      ),
    );
  }
}

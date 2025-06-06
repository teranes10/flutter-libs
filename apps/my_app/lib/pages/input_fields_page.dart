import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/number-field/number_field.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';

class InputFieldsPage extends StatefulWidget {
  const InputFieldsPage({super.key});

  @override
  State<InputFieldsPage> createState() => _InputFieldsPageState();
}

class _InputFieldsPageState extends State<InputFieldsPage> {
  String _textValue = '';
  List<String> _tags = ['Flutter', 'Dart'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 20.0,
        children: [
          TTextField(
            label: 'Name',
            placeholder: 'Enter your name',
            required: true,
            value: _textValue,
            onChanged: (value) {
              setState(() {
                _textValue = value;
              });
            },
            rules: [
              (value) => value?.isEmpty == true ? 'Name is required' : '',
              (value) => value == null || value.length < 2 ? 'Name must be at least 2 characters' : '',
            ],
          ),
          TTextField(
            label: 'Tags',
            placeholder: 'Add a tag and press Enter',
            tags: _tags,
            addTagOnEnter: true,
            onTagsChanged: (tags) {
              setState(() {
                _tags = tags;
              });
            },
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
            onChanged: (value) => print("Age: $value"),
          ),
          TNumberField<double>(
            label: "Price",
            decimals: 2,
            onChanged: (value) => print("Price: \$${value?.toStringAsFixed(2)}"),
          ),
        ],
      ),
    );
  }
}

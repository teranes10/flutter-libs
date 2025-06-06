import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/checkbox/checkbox.dart';
import 'package:te_widgets/widgets/checkbox/checkbox_config.dart';
import 'package:te_widgets/widgets/checkbox/checkbox_group.dart';

class SelectionsPage extends StatefulWidget {
  const SelectionsPage({super.key});

  @override
  State<SelectionsPage> createState() => _SelectionsPageState();
}

class _SelectionsPageState extends State<SelectionsPage> {
  bool singleCheckbox = false;
  List<String> selectedFruits = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single checkbox
          TCheckbox<bool>(
            label: 'I agree to the terms',
            modelValue: singleCheckbox,
            onChanged: (value) => setState(() => singleCheckbox = value),
            rules: [
              (value) => value != true ? 'You must agree to continue' : '',
            ],
          ),

          const SizedBox(height: 32),

          // Checkbox group
          TCheckboxGroup<String>(
            label: 'Select fruits',
            required: true,
            modelValue: selectedFruits,
            onChanged: (values) => setState(() => selectedFruits = values),
            items: const [
              TCheckboxGroupItem(value: 'apple', label: 'Apple'),
              TCheckboxGroupItem(value: 'banana', label: 'Banana'),
              TCheckboxGroupItem(value: 'orange', label: 'Orange'),
            ],
            rules: [
              (values) => values?.isEmpty == true ? 'Select at least one fruit' : '',
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select.dart';
import 'package:te_widgets/widgets/select/multi_select.dart';
import 'package:te_widgets/widgets/autocomplete/autocomplete.dart';

class SelectFieldsPage extends StatefulWidget {
  const SelectFieldsPage({super.key});

  @override
  State<SelectFieldsPage> createState() => _SelectFieldsPageState();
}

class _SelectFieldsPageState extends State<SelectFieldsPage> {
  String? singleValue;
  User? selectedUser;
  List<User>? selectedUsers;
  List<String> multiValue = ['Flutter Development'];
  final countries = TSelectItemBuilder.fromMap({
    'United States': 'US',
    'Canada': 'CA',
  });

  final skills = [
    'Flutter Development',
    'Android Development',
    'iOS Development',
  ];

  final users = [
    User(id: '1', name: 'Alice', role: 'Developer'),
    User(id: '2', name: 'Bob', role: 'Manager'),
  ];

  final customDecoration = BoxDecoration(
    color: AppColors.warning.shade50,
    border: Border.all(color: Colors.blue),
    borderRadius: BorderRadius.circular(8),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic TSelect (String)', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect(
          label: 'Country',
          placeholder: 'Choose a country',
          helperText: 'This field is required',
          isRequired: true,
          items: countries,
          value: singleValue,
          onValueChanged: (val) => setState(() => singleValue = val),
        ),
        const SizedBox(height: 20),
        const Text('Disabled Select', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect(
          label: 'Disabled',
          disabled: true,
          items: countries,
        ),
        const SizedBox(height: 20),
        const Text('With Custom Text & Value Accessor', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect(
          label: 'Select User',
          items: users,
          itemText: (u) => u.name,
          value: selectedUser,
          onValueChanged: (val) => setState(() => selectedUser = val),
        ),
        const SizedBox(height: 20),
        const Text('With Custom Decoration & Widgets', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect(
          label: 'Styled Field',
          items: countries,
          boxDecoration: customDecoration,
          preWidget: const Icon(
            Icons.flag,
            color: AppColors.warning,
          ),
          postWidget: const Icon(Icons.arrow_drop_down, color: AppColors.warning),
          value: singleValue,
          onValueChanged: (val) => setState(() => singleValue = val),
        ),
        const SizedBox(height: 20),
        const Text('Multiselect Basic', style: TextStyle(fontWeight: FontWeight.w400)),
        TMultiSelect(
          label: 'Select Skills',
          items: skills,
          value: multiValue,
          onValueChanged: (val) => setState(() => multiValue = val),
        ),
        const SizedBox(height: 20),
        const Text('Multiselect with Custom ItemText', style: TextStyle(fontWeight: FontWeight.w400)),
        TMultiSelect(
          label: 'Select Users',
          items: users,
          itemText: (u) => '${u.name} (${u.role})',
          value: selectedUsers,
          onValueChanged: (val) => setState(() => selectedUsers = val),
        ),
        const SizedBox(height: 20),
        const Text('With Multi-Level (for hierarchy)', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect<TSelectItem<String>, String>(
          label: 'Categories',
          items: TSelectItemBuilder.fromHierarchy([
            {
              'text': 'Tech',
              'value': 'tech',
              'children': [
                {'text': 'Mobile', 'value': 'mobile'},
                {'text': 'Web', 'value': 'web'},
              ]
            }
          ]),
          multiLevel: true,
          value: 'mobile',
          // onValueChanged: (v) => debugPrint('Selected: $v'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class User {
  final String id;
  final String name;
  final String role;

  User({required this.id, required this.name, required this.role});

  @override
  String toString() => '$name ($role)';
}

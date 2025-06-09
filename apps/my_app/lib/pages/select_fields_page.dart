import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select.dart';
import 'package:te_widgets/widgets/select/multi_select.dart';

class SelectFieldsPage extends StatefulWidget {
  const SelectFieldsPage({super.key});

  @override
  State<SelectFieldsPage> createState() => _SelectFieldsPageState();
}

class _SelectFieldsPageState extends State<SelectFieldsPage> {
  String? selectedCountry;
  List<String> selectedSkills = [];
  String? selectedCategory;
  User? selectedUser;
  List<User> selectedTeamMembers = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 20.0,
        children: [
          TSelect<String>(
            label: 'Country',
            placeholder: 'Select your country',
            helperText: 'Choose your country of residence',
            items: TSelectItemBuilder.fromMap({
              'United States': 'US',
              'United Kingdom': 'UK',
              'Canada': 'CA',
              'Australia': 'AU',
              'Germany': 'DE',
              'France': 'FR',
              'Japan': 'JP',
              'South Korea': 'KR',
            }),
            value: selectedCountry,
            onValueChanged: (value) {
              setState(() {
                selectedCountry = value;
              });
            },
            isRequired: true,
            size: TInputSize.md,
          ),
          TMultiSelect<String>(
            label: 'Skills',
            placeholder: 'Select your skills',
            helperText: 'Choose all applicable skills',
            items: TSelectItemBuilder.fromList([
              'Flutter Development',
              'React Native',
              'iOS Development',
              'Android Development',
              'Web Development',
              'Backend Development',
              'UI/UX Design',
              'Project Management',
              'DevOps',
              'Machine Learning',
            ]),
            value: selectedSkills,
            onValueChanged: (values) {
              setState(() {
                selectedSkills = values;
              });
            },
            size: TInputSize.md,
          ),
          TSelect<String>(
            label: 'Product Category',
            placeholder: 'Select a category',
            helperText: 'Navigate through categories and subcategories',
            multiLevel: true,
            items: TSelectItemBuilder.fromHierarchy([
              {
                'text': 'Electronics',
                'value': 'electronics',
                'key': 'electronics',
                'children': [
                  {
                    'text': 'Smartphones',
                    'value': 'smartphones',
                    'key': 'smartphones',
                    'children': [
                      {
                        'text': 'iPhone',
                        'value': 'iphone',
                        'key': 'iphone',
                      },
                      {
                        'text': 'Android',
                        'value': 'android',
                        'key': 'android',
                      },
                    ],
                  },
                  {
                    'text': 'Laptops',
                    'value': 'laptops',
                    'key': 'laptops',
                    'children': [
                      {
                        'text': 'MacBook',
                        'value': 'macbook',
                        'key': 'macbook',
                      },
                      {
                        'text': 'Windows Laptops',
                        'value': 'windows_laptops',
                        'key': 'windows_laptops',
                      },
                    ],
                  },
                ],
              },
              {
                'text': 'Clothing',
                'value': 'clothing',
                'key': 'clothing',
                'children': [
                  {
                    'text': 'Men\'s Clothing',
                    'value': 'mens_clothing',
                    'key': 'mens_clothing',
                  },
                  {
                    'text': 'Women\'s Clothing',
                    'value': 'womens_clothing',
                    'key': 'womens_clothing',
                  },
                ],
              },
              {
                'text': 'Books',
                'value': 'books',
                'key': 'books',
              },
            ]),
            value: selectedCategory,
            onValueChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            dropdownMaxHeight: 300,
          ),
          TSelect<String>(
            label: 'Disabled Select',
            placeholder: 'This select is disabled',
            disabled: true,
            items: TSelectItemBuilder.fromList(['Option 1', 'Option 2']),
            value: null,
            onValueChanged: null,
          ),
          TSelect<User>(
            label: 'Project Manager',
            placeholder: 'Select project manager',
            items: [
              TSimpleSelectItem<User>(
                text: 'John Doe (Senior)',
                value: User(id: '1', name: 'John Doe', role: 'Senior Developer'),
                key: 'user_1',
              ),
              TSimpleSelectItem<User>(
                text: 'Jane Smith (Lead)',
                value: User(id: '2', name: 'Jane Smith', role: 'Team Lead'),
                key: 'user_2',
              ),
              TSimpleSelectItem<User>(
                text: 'Bob Johnson (Manager)',
                value: User(id: '3', name: 'Bob Johnson', role: 'Project Manager'),
                key: 'user_3',
              ),
            ],
            value: selectedUser,
            onValueChanged: (user) {
              setState(() {
                selectedUser = user;
              });
            },
          ),
          TMultiSelect<User>(
            label: 'Team Members',
            placeholder: 'Select team members',
            items: [
              TSimpleSelectItem<User>(
                text: 'Alice Brown (Frontend)',
                value: User(id: '4', name: 'Alice Brown', role: 'Frontend Developer'),
                key: 'user_4',
              ),
              TSimpleSelectItem<User>(
                text: 'Charlie Wilson (Backend)',
                value: User(id: '5', name: 'Charlie Wilson', role: 'Backend Developer'),
                key: 'user_5',
              ),
              TSimpleSelectItem<User>(
                text: 'Diana Davis (Designer)',
                value: User(id: '6', name: 'Diana Davis', role: 'UI/UX Designer'),
                key: 'user_6',
              ),
            ],
            value: selectedTeamMembers,
            onValueChanged: (users) {
              setState(() {
                selectedTeamMembers = users;
              });
            },
          ),
        ],
      ),
    );
  }
}

class User {
  final String id;
  final String name;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.role,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name ($role)';
}

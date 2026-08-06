import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page showcasing select and dropdown widgets.
class SelectFieldsPage extends StatefulWidget {
  const SelectFieldsPage({super.key});

  @override
  State<SelectFieldsPage> createState() => _SelectFieldsPageState();
}

class _SelectFieldsPageState extends State<SelectFieldsPage> {
  final _countryNotifier = ValueNotifier<String?>('');
  final _userNotifier = ValueNotifier<int?>(null);
  final _footerValueNotifier = ValueNotifier<String?>('');
  final List<String> _footerOptions = ['Item A', 'Item B', 'Item C'];
  List<String> _colors = [];

  @override
  void dispose() {
    _countryNotifier.dispose();
    _userNotifier.dispose();
    _footerValueNotifier.dispose();
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
            'Select Field Components',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Dropdown selects with search, pagination, and hierarchical support.',
            style: TextStyle(fontSize: 13, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Basic Select
          WidgetDocCard(
            title: 'Basic Select',
            description: 'Simple dropdown with string values',
            icon: Icons.arrow_drop_down_circle,
            preview: TSelect<String, String, String>(
              label: 'Country',
              placeholder: 'Select a country',
              items: ['USA', 'Canada', 'Mexico', 'Brazil', 'Argentina'],
              valueNotifier: _countryNotifier,
              onValueChanged: (v) {
                debugPrint(v);
              },
            ),
            code: '''TSelect<String, String, String>(
  label: 'Country',
  placeholder: 'Select a country',
  items: ['USA', 'Canada', 'Mexico', 'Brazil', 'Argentina'],
  onValueChanged: (value) {
    print('Selected: \$value');
  },
)''',
            properties: const [
              PropertyDoc(name: 'items', type: 'List<T>?', description: 'The list of items to display in the dropdown'),
              PropertyDoc(name: 'placeholder', type: 'String?', description: 'Placeholder text shown when no item is selected'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<V?>?', description: 'Callback fired when the selected value changes'),
            ],
          ),

          // Searchable Select
          WidgetDocCard(
            title: 'Searchable Select',
            description: 'Dropdown with built-in search functionality',
            icon: Icons.search,
            preview: TSelect<String, String, String>(
              label: 'City',
              placeholder: 'Search for a city',
              filterable: true,
              items: [
                'New York',
                'Los Angeles',
                'Chicago',
                'Houston',
                'Phoenix',
                'Philadelphia',
                'San Antonio',
                'San Diego',
                'Dallas',
                'San Jose',
              ],
              valueNotifier: ValueNotifier<String?>(''),
            ),
            code: '''TSelect<String, String, String>(
  label: 'City',
  placeholder: 'Search for a city',
  filterable: true,
  items: [
    'New York',
    'Los Angeles',
    'Chicago',
    // ... more cities
  ],
)''',
            properties: const [
              PropertyDoc(name: 'filterable', type: 'bool', defaultValue: 'true', description: 'Whether users can type to filter items'),
              PropertyDoc(name: 'searchDelay', type: 'int?', description: 'Debounce delay for search in milliseconds'),
            ],
          ),

          // Select with Custom Objects
          WidgetDocCard(
            title: 'Custom Object Select',
            description: 'Dropdown with custom data objects',
            icon: Icons.category,
            preview: TSelect<_User, int, int>(
              label: 'User',
              placeholder: 'Select a user',
              items: [
                _User(1, 'John Doe', 'john@example.com'),
                _User(2, 'Jane Smith', 'jane@example.com'),
                _User(3, 'Bob Johnson', 'bob@example.com'),
              ],
              itemText: (user) => user.name,
              itemSubText: (user) => user.email,
              itemValue: (user) => user.id,
              valueNotifier: _userNotifier,
            ),
            code: '''class User {
  final int id;
  final String name;
  final String email;
  User(this.id, this.name, this.email);
}

TSelect<User, int, int>(
  label: 'User',
  placeholder: 'Select a user',
  items: users,
  itemText: (user) => user.name,
  itemSubText: (user) => user.email,
  itemValue: (user) => user.id,
  onValueChanged: (userId) {
    print('Selected user ID: \$userId');
  },
)''',
            properties: const [
              PropertyDoc(name: 'itemText', type: 'ItemTextAccessor<T>', description: 'Function to extract display text from an item'),
              PropertyDoc(name: 'itemSubText', type: 'ItemTextAccessor<T>?', description: 'Function to extract subtitle text from an item'),
              PropertyDoc(
                name: 'itemValue',
                type: 'ItemValueAccessor<T, V>?',
                description: 'Function to extract the value to store when selected',
              ),
            ],
          ),

          // Required Select with Validation
          WidgetDocCard(
            title: 'Required Select',
            description: 'Dropdown with validation rules',
            icon: Icons.rule,
            preview: TSelect<String, String, String>(
              label: 'Department',
              placeholder: 'Select department',
              isRequired: true,
              items: ['Engineering', 'Marketing', 'Sales', 'HR'],
              valueNotifier: ValueNotifier<String?>(''),
              rules: [(value) => value == null || value.isEmpty ? 'Department is required' : null],
            ),
            code: '''TSelect<String, String, String>(
  label: 'Department',
  placeholder: 'Select department',
  isRequired: true,
  items: ['Engineering', 'Marketing', 'Sales', 'HR'],
  rules: [
    (value) => value == null || value.isEmpty 
        ? 'Department is required' 
        : null,
  ],
)''',
            properties: const [
              PropertyDoc(name: 'isRequired', type: 'bool', defaultValue: 'false', description: 'Whether this field is required'),
              PropertyDoc(name: 'rules', type: 'List<String? Function(V?)>?', description: 'Validation rules for the selected value'),
            ],
          ),

          // Disabled Select
          WidgetDocCard(
            title: 'Disabled Select',
            description: 'Non-interactive dropdown',
            icon: Icons.block,
            preview: TSelect<String, String, String>(
              label: 'Status',
              value: 'Active',
              items: ['Active', 'Inactive', 'Pending'],
              disabled: true,
            ),
            code: '''TSelect<String, String, String>(
  label: 'Status',
  value: 'Active',
  items: ['Active', 'Inactive', 'Pending'],
  disabled: true,
)''',
            properties: const [
              PropertyDoc(name: 'disabled', type: 'bool', defaultValue: 'false', description: 'Whether the select is disabled'),
            ],
          ),

          // Clear Button Example
          WidgetDocCard(
            title: 'Select with Clear Button',
            description: 'Enable clear button to quickly deselect items',
            icon: Icons.clear,
            preview: TMultiSelect<String, String, String>(
              label: 'Favorite Color',
              placeholder: 'Select a color',
              clearable: true,
              items: ['Red', 'Blue', 'Green', 'Yellow', 'Purple'],
              value: _colors,
              onValueChanged: (value) => _colors = value ?? [],
            ),
            code: '''TSelect<String, String, String>(
  label: 'Favorite Color',
  placeholder: 'Select a color',
  clearable: true, // Show clear button when item is selected
  items: ['Red', 'Blue', 'Green', 'Yellow', 'Purple'],
  onValueChanged: (value) => print(value),
)

// Also works with TMultiSelect
TMultiSelect<String, String, String>(
  label: 'Tags',
  clearable: true, // Show clear button when items are selected
  items: ['Tag1', 'Tag2', 'Tag3'],
  onValueChanged: (values) => print(values),
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

          // Lazy Loading Select
          WidgetDocCard(
            title: 'Lazy Loading Select',
            description: 'Dropdown that loads items from the API only on first open',
            icon: Icons.hourglass_empty,
            preview: TSelect<String, String, String>(
              label: 'Lazy Options',
              placeholder: 'Click to load items...',
              lazy: true,
              onLoad: (options) async {
                await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
                final allItems = ['Lazy Item A', 'Lazy Item B', 'Lazy Item C', 'Lazy Item D'];
                final filtered = allItems.where((item) => item.toLowerCase().contains((options.search ?? '').toLowerCase())).toList();
                return TLoadResult(filtered, filtered.length, hasNextPage: false);
              },
            ),
            code: '''TSelect<String, String, String>(
  label: 'Lazy Options',
  placeholder: 'Click to load items...',
  lazy: true, // Only fetch on first open
  onLoad: (options) async {
    await Future.delayed(const Duration(seconds: 1));
    return TLoadResult(['Lazy Item A', 'Lazy Item B', 'Lazy Item C'], 3, hasNextPage: false);
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'lazy',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to delay loading items until the dropdown is opened for the first time',
              ),
              PropertyDoc(
                name: 'loadOnSearchOnly',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to only trigger onLoad when there is an active search query (useful for autocompletes)',
              ),
            ],
          ),

          // Select with Custom Footer (Create Option)
          WidgetDocCard(
            title: 'Select with Custom Footer',
            description: 'Dropdown displaying a sticky footer action to create a new option inline',
            icon: Icons.add_circle_outline,
            preview: StatefulBuilder(
              builder: (context, setState) {
                return TSelect<String, String, String>(
                  label: 'Project Options',
                  placeholder: 'Select a project option',
                  items: _footerOptions,
                  valueNotifier: _footerValueNotifier,
                  listTheme: context.theme.listTheme.copyWith(
                    footerSticky: true,
                    footerBuilder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TButton(
                          type: TButtonType.tonal,
                          size: TButtonSize.block,
                          icon: Icons.add,
                          text: 'Create New Option',
                          onTap: () async {
                            final form = _CreateOptionForm();
                            final result = await TFormService.show(context, form);
                            if (result != null) {
                              final text = result.optionName.value.trim();
                              if (text.isNotEmpty) {
                                setState(() {
                                  _footerOptions.add(text);
                                  _footerValueNotifier.value = text;
                                });
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            code: '''TSelect<String, String, String>(
  label: 'Project Options',
  placeholder: 'Select an option',
  items: options,
  listTheme: TListTheme(
    footerSticky: true,
    footerBuilder: (context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TButton(
          type: TButtonType.tonal,
          icon: Icons.add,
          text: 'Create New Option',
          expanded: true,
          onTap: () => showCreateOptionForm(context),
        ),
      );
    },
  ),
)''',
            properties: const [
              PropertyDoc(
                name: 'listTheme',
                type: 'TListTheme?',
                description: 'Custom theme for the inner list, where footerBuilder and footerSticky can be configured',
              ),
            ],
          ),

          // Hierarchical / Nested Select
          WidgetDocCard(
            title: 'Hierarchical / Nested Select',
            description: 'Dropdown displaying nested tree items with inline expansion',
            icon: Icons.account_tree,
            preview: TSelect<_Category, String, String>(
              label: 'Category',
              placeholder: 'Select category / sub-category',
              itemText: (category) => category.name,
              itemValue: (category) => category.id,
              itemChildren: (category) => category.subcategories,
              items: [
                _Category('electronics', 'Electronics', [
                  _Category('phones', 'Smartphones', [_Category('iphone', 'iPhone'), _Category('android', 'Android Phones')]),
                  _Category('laptops', 'Laptops'),
                ]),
                _Category('clothing', 'Clothing', [_Category('mens', 'Mens Wear'), _Category('womens', 'Womens Wear')]),
              ],
              onValueChanged: (val) => debugPrint('Selected category ID: $val'),
            ),
            code: '''class Category {
  final String id;
  final String name;
  final List<Category>? subcategories;
  Category(this.id, this.name, [this.subcategories]);
}

TSelect<Category, String, String>(
  label: 'Category',
  placeholder: 'Select category',
  itemText: (category) => category.name,
  itemValue: (category) => category.id,
  itemChildren: (category) => category.subcategories, // Function returning child items
  items: categories,
  onValueChanged: (categoryId) {
    print('Selected category ID: \$categoryId');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'itemChildren',
                type: 'ItemChildrenAccessor<T>?',
                description: 'Function returning sub-items for rendering hierarchical dropdown structures',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Example model classes
class _User {
  final int id;
  final String name;
  final String email;

  _User(this.id, this.name, this.email);
}

class _Category {
  final String id;
  final String name;
  final List<_Category>? subcategories;

  _Category(this.id, this.name, [this.subcategories]);
}

class _CreateOptionForm extends TFormBase {
  final optionName = TFieldProp<String>('');

  @override
  List<TFormField> get fields => [
    TFormField.text(
      optionName,
      'Option Name',
      placeholder: 'Enter option name',
      isRequired: true,
      rules: [(value) => value == null || value.trim().isEmpty ? 'Name is required' : null],
    ),
  ];

  @override
  String get formTitle => 'Create New Option';
}

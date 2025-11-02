import 'package:flutter/material.dart';
import 'package:my_app/clients/posts_client.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/post_dto.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class SelectFieldsPage extends StatefulWidget {
  const SelectFieldsPage({super.key});

  @override
  State<SelectFieldsPage> createState() => _SelectFieldsPageState();
}

class _SelectFieldsPageState extends State<SelectFieldsPage> {
  String? singleValue = 'CA';
  static List<PostDto> defaultPosts = [PostDto(userId: 12345, id: 234546, title: "Default Post", body: "")];
  int? selectedPost = defaultPosts.first.id;
  User? selectedUser;
  List<User>? selectedUsers;
  List<String> multiValue = ['Flutter Development'];
  final countries = {
    'United States': 'US',
    'Canada': 'CA',
    'Mexico': 'MX',
    'Brazil': 'BR',
    'Argentina': 'AR',
    'United Kingdom': 'GB',
    'Germany': 'DE',
    'France': 'FR',
    'Italy': 'IT',
    'Spain': 'ES',
    'India': 'IN',
    'China': 'CN',
    'Japan': 'JP',
    'South Korea': 'KR',
    'Australia': 'AU',
    'New Zealand': 'NZ',
    'South Africa': 'ZA',
  }.entries.toList();

  final skills = [
    'Flutter Development',
    'Android Development',
    'iOS Development',
    'Dart Programming',
    'Firebase Integration',
    'RESTful API Integration',
    'State Management (Provider, Riverpod, Bloc)',
    'Cross-Platform App Architecture',
    'Unit & Widget Testing',
    'Material Design Implementation',
    'App Store & Play Store Deployment',
  ];

  final users = [
    User(id: '1', name: 'Alice', role: 'Developer'),
    User(id: '2', name: 'Bob', role: 'Manager'),
  ];

  final hierarch = [
    Category('Tech', 'tech', [
      Category('Mobile', 'mobile'),
      Category('Web', 'web'),
    ])
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic TSelect (String)', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect<MapEntry<String, String>, String, String>(
          label: 'Country',
          placeholder: 'Choose a country',
          helperText: 'This field is required',
          isRequired: true,
          items: countries,
          itemText: (x) => x.key,
          itemValue: (x) => x.value,
          value: singleValue,
        ),
        const SizedBox(height: 20),
        const Text('Disabled Select', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect<MapEntry<String, String>, String, String>(
          label: 'Disabled',
          disabled: true,
          items: countries,
          itemText: (x) => x.key,
          itemValue: (x) => x.value,
        ),
        const SizedBox(height: 20),
        const Text('With Custom Text & Value Accessor', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect<User, User, String>(
          label: 'Select User',
          items: users,
          itemText: (u) => u.name,
          itemKey: (u) => u.id,
          value: selectedUser,
        ),
        const SizedBox(height: 20),
        const Text('Multiselect Basic', style: TextStyle(fontWeight: FontWeight.w400)),
        TMultiSelect<String, String, String>(
          label: 'Select Skills',
          items: skills,
          value: multiValue,
        ),
        const SizedBox(height: 20),
        const Text('Multiselect with Custom ItemText', style: TextStyle(fontWeight: FontWeight.w400)),
        TMultiSelect<User, User, int>(
          label: 'Select Users',
          items: users,
          itemText: (u) => '${u.name} (${u.role})',
          value: selectedUsers,
        ),
        const SizedBox(height: 20),
        const Text('With Multi-Level (for hierarchy)', style: TextStyle(fontWeight: FontWeight.w400)),
        TSelect<Category, String, String>(
          label: 'Categories',
          items: hierarch,
          itemText: (x) => x.name,
          itemValue: (x) => x.code,
          itemChildren: (x) => x.subCategories,
          value: 'mobile',
        ),
        const SizedBox(height: 20),
        TSelect<PostDto, int, int>(
          label: 'Server side rendering',
          onLoad: PostsClient().loadMore,
          itemText: (x) => x.title,
          itemSubText: (x) => x.body,
          itemValue: (x) => x.id,
          items: defaultPosts,
          // In server-side rendering, include the default selected item in the items list so its text can be displayed, even if it’s not on the first page.
          // This is required only when itemValue is provided — if value is of type T, the text is automatically taken from the provided value item.
          value: selectedPost,
        ),
        const SizedBox(height: 20),
        TSelect<ProductDto, int, int>(
          label: 'Server side rendering',
          onLoad: ProductsClient().loadMore,
          itemText: (x) => x.title,
          itemSubText: (x) => x.category,
          itemImageUrl: (x) => x.thumbnail ?? '',
          itemValue: (x) => x.id,
          value: 1,
        )
      ],
    ));
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

class Category {
  final String name;
  final String code;
  final List<Category> subCategories;

  Category(this.name, this.code, [this.subCategories = const []]);
}

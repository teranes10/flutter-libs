import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/clients/posts_client.dart';
import 'package:my_app/models/post_dto.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/button/button_config.dart';
import 'package:te_widgets/widgets/button/button_group.dart';
import 'package:te_widgets/widgets/data-table/data_table.dart';
import 'package:te_widgets/widgets/table/table.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';
import 'package:te_widgets/widgets/chip/chip.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  List<Map<String, dynamic>> userMaps = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'Admin',
      'createdAt': DateTime.now(),
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 3,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 4,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 5,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 6,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 7,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 8,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 9,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 50,
        children: [
          TTable<Product>(
            headers: [
              TTableHeader.map("Name", (x) => x.name),
              TTableHeader.map("Price", (x) => x.price.toString()),
              TTableHeader.map("Stock", (x) => x.stock.toString()),
            ],
            items: products,
          ),
          TDataTable<Product>(
            headers: [
              TTableHeader.map("Name", (x) => x.name),
              TTableHeader.map("Price", (x) => x.price.toString()),
              TTableHeader.map("Stock", (x) => x.stock.toString()),
              TTableHeader('Stock', builder: (_, x) => TChip(text: x.stock.toString(), color: AppColors.info)),
              TTableHeader(
                'Actions',
                maxWidth: 132,
                alignment: Alignment.center,
                builder: (context, user) => TButtonGroup(
                  type: TButtonGroupType.icon,
                  items: [
                    TButtonGroupItem(tooltip: 'View', icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Edit', icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Restore', icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Archive', icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Delete', icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
                  ],
                ),
              ),
            ],
            items: products,
          ),
          TDataTable<PostDto>(
            headers: [
              TTableHeader.map('Title', (x) => x.title),
              TTableHeader.map('Body', (x) => x.body),
            ],
            onLoad: (o) async {
              print('__onload');
              final pair = await PostsClient().fetchPosts(start: o.offset, limit: o.itemsPerPage);
              o.callback(pair.$1, pair.$2);
            },
          )
        ],
      ),
    );
  }

  void _editUser(User user) {
    // Implement edit functionality
  }

  void _deleteUser(User user) {
    // Implement delete functionality
  }

  void _viewUser(User user) {
    // Implement view functionality
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;

  Product(this.id, this.name, this.price, this.stock);
}

final List<Product> products = List.generate(
  3,
  (index) => Product(
    'ID-${index + 1}',
    'Product Description ${index + 1}',
    10.0 + (index * 0.5),
    100 - index,
  ),
);

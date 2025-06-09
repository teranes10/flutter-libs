import 'package:flutter/material.dart';
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
  List<User> users = [
    User(id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin', createdAt: DateTime.now()),
    User(id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 3, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 4, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 5, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 6, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 7, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 8, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    User(id: 9, name: 'Jane Smith', email: 'jane@example.com', role: 'User', createdAt: DateTime.now()),
    // Add more users...
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
              TTableHeader("Name", map: (x) => x.name),
              TTableHeader("Price", map: (x) => x.price.toString()),
              TTableHeader("Stock", map: (x) => x.stock.toString()),
            ],
            items: products,
          ),
          TDataTable<User>(
            headers: [
              TTableHeader('ID', maxWidth: 50, map: (user) => user.id.toString()),
              TTableHeader('Name', map: (user) => user.name),
              TTableHeader('Email', map: (user) => user.email),
              TTableHeader(
                'Role',
                builder: (context, user) => TChip(text: user.role, color: user.role == 'Admin' ? AppColors.info : AppColors.success),
              ),
              TTableHeader(
                'Actions',
                maxWidth: 132,
                alignment: Alignment.center,
                builder: (context, user) => TButtonGroup(
                  type: TButtonGroupType.icon,
                  items: [
                    TButtonGroupItem(icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
                    TButtonGroupItem(icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
                    TButtonGroupItem(icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
                  ],
                ),
              ),
            ],
            items: users,
          ),
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
  10,
  (index) => Product(
    'ID-${index + 1}',
    'Product Description ${index + 1}',
    10.0 + (index * 0.5),
    100 - index,
  ),
);

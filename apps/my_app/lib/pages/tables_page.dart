import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
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
              TTableHeader('ID', map: (user) => user.id.toString()),
              TTableHeader('Name', map: (user) => user.name),
              TTableHeader('Email', map: (user) => user.email),
              TTableHeader(
                'Role',
                maxWidth: 100,
                alignment: Alignment.center,
                builder: (context, user) => TChip(text: user.role, color: user.role == 'Admin' ? AppColors.info : AppColors.success),
              ),
              TTableHeader(
                'Actions',
                maxWidth: 100,
                alignment: Alignment.center,
                builder: (context, user) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 18),
                      onPressed: () => _editUser(user),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _deleteUser(user),
                    ),
                  ],
                ),
              ),
            ],
            items: users,
            itemsPerPage: 10,
            onItemTap: (user) => _viewUser(user),
            onInitialize: (context) {
              // Initialize data table context if needed
            },
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

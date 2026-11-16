import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Stock level of a [DemoProduct]. Design tokens live here, not inline in table pages: `.label`, `.color`, `.toChip()`.
enum DemoStockStatus { inStock, lowStock }

extension DemoStockStatusExt on DemoStockStatus {
  String get label => switch (this) {
    DemoStockStatus.inStock => 'In Stock',
    DemoStockStatus.lowStock => 'Low Stock',
  };

  Color color(BuildContext context) => switch (this) {
    DemoStockStatus.inStock => context.theme.success,
    DemoStockStatus.lowStock => context.theme.danger,
  };

  TChip toChip(BuildContext context, {int? stock}) =>
      TChip(text: stock == null ? label : '$label ($stock)', color: color(context), type: TVariant.tonal);
}

extension DemoProductX on DemoProduct {
  DemoStockStatus get stockStatus => stock > 10 ? DemoStockStatus.inStock : DemoStockStatus.lowStock;
}

/// Shared columns of the row-expansion demo tables (image, name, category, rating, stock chip, price).
List<TTableHeader<DemoProduct, String>> demoProductHeaders(BuildContext context, {bool stock = true}) => [
  TTableHeader<DemoProduct, String>.image('Image', (x) => x.imageUrl, width: 60),
  TTableHeader<DemoProduct, String>.map('Name', (x) => x.name),
  TTableHeader<DemoProduct, String>.map('Category', (x) => x.category),
  TTableHeader<DemoProduct, String>.rating('Rating', (x) => x.rating),
  if (stock)
    TTableHeader<DemoProduct, String>.chip(
      'Stock',
      (x) => '${x.stockStatus.label} (${x.stock})',
      color: (x) => x.stockStatus.color(context),
    ),
  TTableHeader<DemoProduct, String>.map('Price', (x) => '\$${x.price.toStringAsFixed(2)}'),
];

class DemoProduct {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int stock;
  final double price;
  final String imageUrl;
  final String sku;
  final String manufacturer;
  final String warranty;
  final String weight;
  final String description;

  DemoProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.sku,
    required this.manufacturer,
    required this.warranty,
    required this.weight,
    required this.description,
  });
}

final List<DemoProduct> demoProducts = [
  DemoProduct(
    id: 'p1',
    name: 'Quantum X Pro Smartphone',
    category: 'Mobile Devices',
    rating: 4.8,
    stock: 45,
    price: 1199.00,
    imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100&h=100&fit=crop',
    sku: 'QX-PRO-128-GRY',
    manufacturer: 'Quantum Technologies Inc.',
    warranty: '2 Years International',
    weight: '185g',
    description: 'A revolutionary smartphone featuring next-generation quantum computing chipsets and a high-refresh crystal screen.',
  ),
  DemoProduct(
    id: 'p2',
    name: 'AcousticWave ANC Headphones',
    category: 'Audio Equipment',
    rating: 4.5,
    stock: 5,
    price: 349.99,
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100&h=100&fit=crop',
    sku: 'AW-ANC-BLK',
    manufacturer: 'AcousticWave Labs',
    warranty: '1 Year Manufacturer',
    weight: '250g',
    description: 'Industry-leading hybrid active noise cancelling over-ear headphones with custom spatial acoustics.',
  ),
  DemoProduct(
    id: 'p3',
    name: 'Helios Smartwatch Series 7',
    category: 'Wearable Tech',
    rating: 4.6,
    stock: 82,
    price: 429.00,
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
    sku: 'HL-SW7-SILV',
    manufacturer: 'Helios Devices',
    warranty: '1 Year Limited',
    weight: '45g',
    description: 'Premium titanium smartwatch with integrated continuous health monitoring, GPS tracking, and cellular connectivity.',
  ),
];

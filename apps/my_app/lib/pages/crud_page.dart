import 'package:flutter/material.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:my_app/pages/crud/product_detail_panel.dart';
import 'package:te_widgets/te_widgets.dart';

class CrudPage extends StatelessWidget {
  const CrudPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TListController<ProductDto, int>(
      selectionMode: TSelectionMode.multiple,
      expansionMode: TExpansionMode.single,
      onLoad: ProductsClient().loadMore,
    );

    final archiveController = TListController<ProductDto, int>(onLoad: ProductsClient().loadMore);

    final otherController = TListController<ProductDto, int>(
      selectionMode: TSelectionMode.multiple,
      expansionMode: TExpansionMode.single,
      items: [
        ProductDto(
          id: 1,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku',
        ),
      ],
    );

    List<TTableHeader<ProductDto, int>> headers = [
      TTableHeader.image("Image", (x) => x.thumbnail, forceCache: true),
      TTableHeader.values('Product', (x) => [TKeyValue('Product', value: x.title), TKeyValue('SKU', value: x.sku)]),
      TTableHeader.map('Category', (x) => x.category),
      TTableHeader.keyValues(
        'Pricing',
        (x) => [TKeyValue('Price', value: '\$${x.price}'), TKeyValue('Discount', value: '${x.discountPercentage}%')],
      ),
      TTableHeader.progress(
        'Fulfillment',
        (x) => (x.stock / 150).clamp(0.0, 1.0),
        valueText: (x) => '${x.stock}/150',
        colorBuilder: (value, percentage) => percentage < 30
            ? AppColors.danger
            : percentage < 70
            ? AppColors.warning
            : AppColors.success,
      ),
      TTableHeader.rating('Rating', (x) => x.rating.toDouble()),
      // Stock state badge with a dropdown; picking a state patches the product's stock.
      TTableHeader.statusEnum<ProductDto, int, StockStatus>(
        'Stock',
        (x) => StockStatus.of(x.stock),
        StockStatus.values,
        label: (s) => s.label,
        color: (s) => s.color(context),
        icon: (s) => s.icon,
        onChanged: (product, status) {
          final updated = product.copyWith(stock: status.stockFor(product.stock));
          for (final c in [controller, archiveController, otherController]) {
            if (c.flatItems.any((p) => p.id == product.id)) c.updateItem(product, updated);
          }
          return true;
        },
      ),
    ];

    return TCrudTable<ProductDto, int, ProductForm>(
      headers: headers,
      createForm: () => ProductForm(),
      editForm: (ProductDto item) => ProductForm(item),
      onCreate: (input) async {
        return ProductDto(
          id: productId++,
          title: input.title.value,
          description: input.description.value,
          price: input.price.value,
          discountPercentage: 1,
          rating: 1,
          stock: 1,
          category: 'category',
          sku: 'sku',
        );
      },
      onEdit: (item, form) async {
        return item.copyWith(title: form.title.value, description: form.description.value, price: form.price.value);
      },
      onArchive: (item) async {
        return true;
      },
      onRestore: (item) async {
        return true;
      },
      onDelete: (item) async {
        return true;
      },
      config: TCrudConfig<ProductDto, int>(
        pageIcon: HugeIcons.strokeRoundedPackage,
        pageTitle: 'Products',
        pageInfo: 'Manage your product catalog',
        topBarMetrics: [
          TMetricTile(
            label: 'Total Products',
            value: '1,248',

            icon: HugeIcons.strokeRoundedPackage,
            color: context.theme.primary,
            trend: '+2.6%',
            trendUp: true,
          ),
          TMetricTile(
            label: 'Inventory Value',
            value: '\$84,230',

            icon: HugeIcons.strokeRoundedWallet01,
            color: context.theme.success,
            trend: '+8.1%',
            trendUp: true,
          ),
          TMetricTile(
            label: 'Low Stock',
            value: '23',

            icon: HugeIcons.strokeRoundedAlert02,
            color: context.theme.warning,
            trend: '+5',
            trendUp: false,
          ),
          TMetricTile(
            label: 'Out of Stock',
            value: '7',

            icon: HugeIcons.strokeRoundedCancelCircle,
            color: context.theme.danger,
            trend: '-2',
            trendUp: true,
          ),
        ],
        flatActions: false,
        // Advanced filters; the applied values are persisted per route by TCrudTable.
        filters: [
          TFilter.text<ProductDto>('Title', map: (x) => x.title),
          TFilter.text<ProductDto>('SKU', map: (x) => x.sku),
          TFilter.select<ProductDto>('Category', items: categories, map: (x) => x.category),
          TFilter.number<ProductDto>('Price', map: (x) => x.price),
          TFilter.number<ProductDto>('Stock', map: (x) => x.stock),
          TFilter.number<ProductDto>('Rating', map: (x) => x.rating),
        ],
        tabs: [
          TTab(text: "Active", value: 0),
          TTab(text: "Others", value: 2),
          TTab(text: "Archive", value: 1),
        ],
        // Tab values: Active = 0, Archive = 1, Others = 2
        // Note: The order of [tabContents] follows the order of this list,
        tabContents: [TCrudTableContent(headers: headers, controller: otherController)],
        topBarActions: [
          TButton(type: TButtonType.outline, icon: HugeIcons.strokeRoundedFileUpload, text: 'Upload File', onPressed: (_) => {}),
        ],
      ),
      itemTitle: (item) => item.title,
      itemSubTitle: (item) => item.sku,
      itemImageUrl: (item) => item.thumbnail,
      itemDescription: (item) => item.description,
      itemInfo: (item) => [
        TKeyValue.text('SKU', item.sku),
        TKeyValue.text('Category', item.category),
        TKeyValue.text('Stock', '${item.stock} units'),
        TKeyValue.text('Price', '\$${item.price.toStringAsFixed(2)}'),
        TKeyValue.text('Rating', '${item.rating} / 5.0'),
      ],
      expandedBuilder: (ctx, item, index) => ProductDetailPanel(product: item.data),
      rowColorBuilder: (item, index) {
        if (item.data.stock < 5) return AppColors.danger.withAlpha(15);
        if (item.data.stock < 10) return AppColors.warning.withAlpha(15);
        return null; // Use default background color
      },
      controller: controller,
      archiveController: archiveController,
    );
  }
}

/// Stock state shown in the Stock column; derived from the stock count.
enum StockStatus {
  inStock('In Stock'),
  low('Low'),
  outOfStock('Out of Stock');

  const StockStatus(this.label);
  final String label;

  static StockStatus of(int stock) => stock <= 0
      ? outOfStock
      : stock > 50
      ? inStock
      : low;

  Color color(BuildContext context) => switch (this) {
    inStock => context.theme.success,
    low => context.theme.warning,
    outOfStock => context.theme.danger,
  };

  dynamic get icon => switch (this) {
    inStock => HugeIcons.strokeRoundedCheckmarkCircle02,
    low => HugeIcons.strokeRoundedAlert02,
    outOfStock => HugeIcons.strokeRoundedCancelCircle,
  };

  /// Stock count that represents this state, keeping [current] when it already does.
  int stockFor(int current) => StockStatus.of(current) == this
      ? current
      : switch (this) {
          inStock => 100,
          low => 20,
          outOfStock => 0,
        };
}

var productId = 1000;
var categories = ['Category 1', 'Category 2', 'Category 3'];

class ProductForm extends TFormBase {
  final title = TFieldProp('');
  final description = TFieldProp('');
  final price = TFieldProp(0.0);
  final date = TFieldProp(DateTime.now());
  final category = TFieldProp('Category 1');

  ProductForm([ProductDto? product]) {
    if (product != null) {
      title.value = product.title;
      description.value = product.description;
      price.value = product.price.toDouble();
      category.value = product.category;

      final createdAt = product.meta?.createdAt;
      if (createdAt != null) {
        date.value = DateTime.tryParse(createdAt) ?? DateTime.now();
      }
    }
  }

  @override
  double get formWidth => 750;

  @override
  String get formTitle => title.value.isEmpty ? 'Add New Product' : 'Edit Product: ${title.value}';

  @override
  String get formActionName => title.value.isEmpty ? 'Add New Product' : 'Update Product';

  @override
  List<TFormField> get fields {
    return [
      TFormField.text(title, 'Title', isRequired: true).size(6),
      TFormField.number(price, 'Price').size(6),
      TFormField.date(date, "Date"),
      TFormField.text(description, 'Description', rows: 3),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<TTableHeader<ProductDto, int>> headers = [
      TTableHeader.image("Image", (x) => x.thumbnail),
      TTableHeader.map('SKU', (x) => x.sku),
      TTableHeader.map('Title', (x) => x.title),
      TTableHeader.map('Category', (x) => x.category),
      TTableHeader.map('Price', (x) => x.price),
      TTableHeader.map('Discount', (x) => x.discountPercentage),
      TTableHeader.map('Rating', (x) => x.rating),
      TTableHeader.chip('Stock', (x) => x.stock, color: AppColors.info)
    ];

    return TTable<ProductDto, int>(
      theme: context.theme.tableTheme.copyWith(
        grid: TGridMode.aligned,
        gridDelegate: (context) => context.isMobile ? TGridDelegate(crossAxisCount: 1) : TGridDelegate(maxCrossAxisExtent: 350),
      ),
      headers: headers,
      onLoad: ProductsClient().loadMore,
    );
  }
}

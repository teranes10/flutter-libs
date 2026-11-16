import 'package:flutter/material.dart';
import 'package:my_app/models/demo_product.dart';
import 'package:te_widgets/te_widgets.dart';

class TablesDialogPage extends StatefulWidget {
  const TablesDialogPage({super.key});

  @override
  State<TablesDialogPage> createState() => _TablesDialogPageState();
}

class _TablesDialogPageState extends State<TablesDialogPage> {
  late final TListController<DemoProduct, String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TListController<DemoProduct, String>(items: demoProducts, itemKey: (p) => p.id, expansionMode: TExpansionMode.single);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TPageWrapper(
      title: 'Row Expansion: Dialog Mode',
      description:
          'Expands row details into an interactive modal dialog overlay. Excellent for keeping the user focused on a single entry without losing their scroll position on the main table.',
      child: TTable<DemoProduct, String>(
        shrinkWrap: true,
        headers: demoProductHeaders(context),
        controller: _controller,
        details: TTableDetails(
          mode: TTableExpansionMode.dialog,
          itemTitle: (x) => x.name,
          itemSubTitle: (x) => x.category,
          itemImageUrl: (x) => x.imageUrl,
          itemDescription: (x) => x.description,
          itemHighlights: (x) => [x.stockStatus.toChip(context, stock: x.stock)],
          builder: (ctx, item, index) {
            final product = item.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: TKeyValueSection(
                values: [
                  TKeyValue.text('SKU Code', product.sku),
                  TKeyValue.text('Manufacturer', product.manufacturer),
                  TKeyValue.text('Warranty', product.warranty),
                  TKeyValue.text('Weight', product.weight),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

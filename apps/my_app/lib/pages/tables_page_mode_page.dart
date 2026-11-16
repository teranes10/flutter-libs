import 'package:flutter/material.dart';
import 'package:my_app/models/demo_product.dart';
import 'package:te_widgets/te_widgets.dart';

class TablesPageModePage extends StatefulWidget {
  const TablesPageModePage({super.key});

  @override
  State<TablesPageModePage> createState() => _TablesPageModePageState();
}

class _TablesPageModePageState extends State<TablesPageModePage> {
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
      title: 'Row Expansion: Page Mode',
      description:
          'Expands the row details into a full page view by navigating to a new route. Best suited for mobile form factors or scenarios containing extensive lists, complex sub-components, or graphs.',
      child: TTable<DemoProduct, String>(
        shrinkWrap: true,
        headers: demoProductHeaders(context),
        controller: _controller,
        details: TTableDetails(
          mode: TTableExpansionMode.page,
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

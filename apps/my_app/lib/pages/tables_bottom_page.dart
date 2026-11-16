import 'package:flutter/material.dart';
import 'package:my_app/models/demo_product.dart';
import 'package:te_widgets/te_widgets.dart';

class TablesBottomPage extends StatefulWidget {
  const TablesBottomPage({super.key});

  @override
  State<TablesBottomPage> createState() => _TablesBottomPageState();
}

class _TablesBottomPageState extends State<TablesBottomPage> {
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
      title: 'Row Expansion: Bottom Mode',
      description:
          'Expands inline directly beneath the clicked row. Best suited for quick inline details, key-value reviews, and summary sub-tables.',
      child: TTable<DemoProduct, String>(
        shrinkWrap: true,
        headers: demoProductHeaders(context),
        controller: _controller,
        details: TTableDetails(
          mode: TTableExpansionMode.bottom,
          builder: (ctx, item, index) {
            final product = item.data;
            return TCard(
              title: 'Product Technical Specs & Summary',
              icon: HugeIcons.strokeRoundedInformationCircle,
              margin: const EdgeInsets.all(16),
              child: TKeyValueSection(
                values: [
                  TKeyValue.text('SKU Code', product.sku),
                  TKeyValue.text('Manufacturer', product.manufacturer),
                  TKeyValue.text('Warranty Period', product.warranty),
                  TKeyValue.text('Weight', product.weight),
                  TKeyValue.text('Description', product.description),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

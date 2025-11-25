import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pos/features/product/products.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_bar.dart';
import 'package:my_pos/shared/widgets/category_bar/category_bar.dart';
import 'package:my_pos/shared/widgets/product_grid/product_grid.dart';
import 'package:te_widgets/te_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = context.isDesktop;
    final pad = 7.5;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                margin: isWideScreen
                    ? EdgeInsets.only(left: pad, right: pad, bottom: pad)
                    : EdgeInsets.only(left: pad, right: pad, bottom: pad),
                child: TCategoryBar(),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: pad),
                  child: TProductGrid(),
                ),
              ),
            ],
          ),
        ),
        if (isWideScreen)
          Container(
            padding: EdgeInsets.only(top: pad, right: pad, bottom: pad),
            child: TBillBar(),
          ),
      ],
    );
  }
}

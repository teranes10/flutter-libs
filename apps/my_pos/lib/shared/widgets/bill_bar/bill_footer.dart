import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TBillFooter extends StatelessWidget {
  final VoidCallback onPlaceOrder;

  const TBillFooter({super.key, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        buildPaymentDetail(colors, label: 'Sub Total', value: '\$50.00'),
        buildPaymentDetail(colors, label: 'Tax 10% (VAT Included)', value: '\$5.00'),
        Container(
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.outlineVariant, width: 1, style: BorderStyle.solid),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.primary),
              ),
              Text(
                '\$55.00',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: colors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Methods',
                style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildPaymentMethod(colors, icon: Icons.money, label: 'Cash', onTap: () {}),
                  buildPaymentMethod(colors, icon: Icons.credit_card, label: 'Card', onTap: () {}),
                  buildPaymentMethod(colors, icon: Icons.account_balance_wallet, label: 'E-Wallet', onTap: () {}),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TButton(size: TButtonSize.block, text: 'Place Order', onTap: onPlaceOrder),
      ],
    );
  }

  Widget buildPaymentDetail(ColorScheme colors, {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentMethod(ColorScheme colors, {required IconData icon, required String label, VoidCallback? onTap}) {
    return Column(
      spacing: 3,
      children: [
        TButton(
          icon: icon,
          type: TButtonType.outline,
          size: TButtonSize.lg.copyWith(minW: 60, minH: 45),
          color: AppColors.grey,
          shape: TButtonShape.custom(10),
          onTap: onTap,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

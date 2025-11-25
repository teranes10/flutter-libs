import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TBillHeader extends StatelessWidget {
  const TBillHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bill Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 5,
            children: [
              Text(
                '#246',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
              ),
              Text(
                'Sunday, 28 Oct 2022, 7:45 AM',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

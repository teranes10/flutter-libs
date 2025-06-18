import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';
import 'package:te_widgets/widgets/table/table_decoration.dart';

class TTableCard<T> extends StatelessWidget {
  final T item;
  final List<TTableHeader<T>> headers;
  final TTableStyling? styling;
  final VoidCallback? onTap;
  final double? width;

  const TTableCard({
    super.key,
    required this.item,
    required this.headers,
    this.styling,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cardStyle = styling?.cardStyle ?? const TCardStyle();

    return Container(
      width: width,
      margin: cardStyle.margin ?? const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: cardStyle.elevation ?? 1,
        borderRadius: cardStyle.borderRadius ?? BorderRadius.circular(12),
        color: cardStyle.backgroundColor ?? Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardStyle.borderRadius ?? BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: cardStyle.borderRadius ?? BorderRadius.circular(12),
              border: cardStyle.border ?? Border.all(color: AppColors.grey[100]!),
            ),
            padding: cardStyle.padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildCardFields(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCardFields() {
    return headers.asMap().entries.map((entry) {
      final index = entry.key;
      final header = entry.value;
      final isLast = index == headers.length - 1;

      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                header.text,
                style: styling?.cardLabelStyle ??
                    TextStyle(
                      fontSize: 13.6,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey[500],
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildCellContent(header),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCellContent(TTableHeader<T> header) {
    if (header.builder != null) {
      return Builder(
        builder: (context) => header.builder!(context, item),
      );
    }

    return Text(
      header.getValue(item),
      style: styling?.cardValueStyle ??
          TextStyle(
            fontSize: 13.6,
            fontWeight: FontWeight.w300,
            color: AppColors.grey.shade600,
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class TTableHeader<T> {
  final String text;
  final String? value;
  final String Function(T)? map;
  final Widget Function(BuildContext, T)? builder;
  final int? flex;
  final double? minWidth;
  final double? maxWidth;
  final Alignment? alignment;

  const TTableHeader(
    this.text, {
    this.value,
    this.map,
    this.builder,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  });

  const TTableHeader.map(
    this.text,
    this.map, {
    this.value,
    this.builder,
    this.flex,
    this.minWidth,
    this.maxWidth,
    this.alignment,
  });

  String getValue(T item) {
    if (this.map != null) {
      return this.map!(item);
    } else if (item is Map<String, dynamic> && value != null) {
      return item[value]?.toString() ?? '';
    }

    return '';
  }
}

class TTableStyling {
  final TextStyle? headerTextStyle;
  final EdgeInsets? headerPadding;
  final Decoration? headerDecoration;
  final EdgeInsets? contentPadding;
  final TCardStyle? cardStyle;
  final TRowStyle? rowStyle;
  final TextStyle? cardLabelStyle;
  final TextStyle? cardValueStyle;
  final TextStyle? rowTextStyle;

  const TTableStyling({
    this.headerTextStyle,
    this.headerPadding,
    this.headerDecoration,
    this.contentPadding,
    this.cardStyle,
    this.rowStyle,
    this.cardLabelStyle,
    this.cardValueStyle,
    this.rowTextStyle,
  });
}

class TCardStyle {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const TCardStyle({
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });
}

class TRowStyle {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const TRowStyle({
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });
}

extension AlignmentExtension on Alignment {
  TextAlign toTextAlign() {
    if (this == Alignment.centerLeft || this == Alignment.topLeft || this == Alignment.bottomLeft) {
      return TextAlign.left;
    } else if (this == Alignment.centerRight || this == Alignment.topRight || this == Alignment.bottomRight) {
      return TextAlign.right;
    } else {
      return TextAlign.center;
    }
  }
}

Widget tableEmptyState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no items to display at the moment.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

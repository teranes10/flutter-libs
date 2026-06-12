import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TSideSheet extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final bool? showCloseButton;
  final VoidCallback? onClose;
  final double width;
  final bool fromLeft;

  const TSideSheet(
    this.child, {
    super.key,
    this.header,
    this.footer,
    this.title,
    this.showCloseButton,
    this.onClose,
    this.width = 400,
    this.fromLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;
    final sheetWidth = width > screenSize.width ? screenSize.width : width;

    return Container(
      width: sheetWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(fromLeft ? 5 : -5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          if (header != null) header!,
          if (header == null && (title != null || showCloseButton == true)) _buildHeader(context, colors),
          Expanded(
            child: child,
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: title != null
                ? Text(title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                : const SizedBox.shrink(),
          ),
          if (showCloseButton == true) TIcon.close(size: 20, onTap: onClose),
        ],
      ),
    );
  }
}

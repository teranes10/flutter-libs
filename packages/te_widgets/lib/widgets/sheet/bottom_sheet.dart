import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final bool? showCloseButton;
  final VoidCallback? onClose;
  final double? height;
  final bool showHandle;

  const TBottomSheet(
    this.child, {
    super.key,
    this.header,
    this.footer,
    this.title,
    this.showCloseButton,
    this.onClose,
    this.height,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) _buildHandle(context, colors),
          if (header != null) header!,
          if (header == null && (title != null || showCloseButton == true)) _buildHeader(context, colors),
          Flexible(
            child: child,
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colors.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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

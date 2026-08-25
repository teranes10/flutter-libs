import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TSideSheet extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final String? subTitle;
  final bool? showCloseButton;
  final VoidCallback? onClose;
  final double width;
  final double minWidth;
  final bool fromLeft;
  final bool persistent;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext context, Widget child)? layoutBuilder;

  const TSideSheet(
    this.child, {
    super.key,
    this.header,
    this.footer,
    this.title,
    this.subTitle,
    this.showCloseButton,
    this.onClose,
    this.width = 400,
    this.minWidth = 280,
    this.fromLeft = false,
    this.persistent = false,
    this.backgroundColor,
    this.borderRadius,
    this.layoutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;
    final sheetWidth = width.clamp(minWidth, screenSize.width);
    final effectiveBg = backgroundColor ?? context.getBackgroundColor(colors.surface);

    final defaultBorderRadius = borderRadius ??
        (fromLeft
            ? const BorderRadius.horizontal(right: Radius.circular(12))
            : const BorderRadius.horizontal(left: Radius.circular(12)));

    return Container(
      width: sheetWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: Offset(fromLeft ? 4 : -4, 0),
          ),
        ],
        border: Border(
          left: fromLeft ? BorderSide.none : BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
          right: fromLeft ? BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)) : BorderSide.none,
        ),
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: TBackgroundColorScope(
          backgroundColor: effectiveBg,
          child: layoutBuilder != null
              ? layoutBuilder!(context, child)
              : _layout(context, colors),
        ),
      ),
    );
  }

  Widget _layout(BuildContext context, ColorScheme colors) {
    return Column(
      children: [
        if (header != null) header!,
        if (header == null && (title != null || showCloseButton == true)) _buildHeader(context, colors),
        Expanded(
          child: child,
        ),
        if (footer != null) footer!,
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subTitle != null && subTitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subTitle!,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton == true) TIcon.close(size: 20, onTap: onClose),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TModal extends StatelessWidget {
  final bool persistent;
  final double width;
  final Widget child;

  final Widget? header;
  final Widget? footer;

  final String? title;
  final bool? showCloseButton;

  final VoidCallback? onClose;

  final double gap;

  const TModal(
    this.child, {
    super.key,
    this.persistent = false,
    this.width = 500,
    this.header,
    this.footer,
    this.title,
    this.showCloseButton,
    this.onClose,
    this.gap = 15,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;
    final modalWidth = width > screenSize.width ? screenSize.width - gap : width;

    return GestureDetector(
      onTap: () {
        if (!persistent) {
          onClose?.call();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Align(
              alignment: const FractionalOffset(0.5, 0.275),
              child: GestureDetector(
                onTap: () {}, // Prevent tap propagation
                child: Container(
                  width: modalWidth,
                  constraints: BoxConstraints(
                    minWidth: 250,
                    minHeight: 250,
                    maxWidth: screenSize.width - gap,
                    maxHeight: screenSize.height - gap,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 12, spreadRadius: 0)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed header (non-scrollable
                      if (header != null) header!,
                      if (header == null && (title != null || showCloseButton == true)) _buildHeader(context, colors),

                      // Scrollable content area
                      Flexible(
                        child: SingleChildScrollView(child: child),
                      ),

                      // Fixed footer (non-scrollable)
                      if (footer != null) footer!,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    final padding = context.isMobile
        ? const EdgeInsets.only(left: 10, right: 2.5, top: 15, bottom: 7.5)
        : const EdgeInsets.only(left: 25, right: 15, top: 15, bottom: 5);

    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: title != null
                ? Text(title ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: colors.onSurface))
                : SizedBox.shrink(),
          ),
          if (showCloseButton == true) TIcon.close(colors, size: 20, onTap: () => onClose?.call()),
        ],
      ),
    );
  }
}

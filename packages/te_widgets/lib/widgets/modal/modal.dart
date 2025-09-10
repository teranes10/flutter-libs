import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/close-icon/close_icon.dart';

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
    final theme = context.theme;
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
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: theme.shadow, blurRadius: 12, spreadRadius: 0)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed header (non-scrollable
                      if (header != null) header!,
                      if (header == null && (title != null || showCloseButton == true)) _buildHeader(theme),

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

  Widget _buildHeader(ColorScheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: title != null
                ? Text(title ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: theme.onSurface))
                : SizedBox.shrink(),
          ),
          if (showCloseButton == true) TCloseIcon(onClose: () => onClose?.call()),
        ],
      ),
    );
  }
}

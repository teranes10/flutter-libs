import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final modalWidth = width > screenSize.width ? screenSize.width - 50 : width;

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
                    minWidth: 450,
                    minHeight: 250,
                    maxWidth: screenSize.width - 50,
                    maxHeight: screenSize.height - 50,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.grey.shade600.withAlpha(25), blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed header (non-scrollable
                      if (header != null) header!,
                      if (header == null && (title != null || showCloseButton == true)) _buildHeader(),

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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: title != null
                ? Text(title ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: AppColors.grey.shade600))
                : SizedBox.shrink(),
          ),
          if (showCloseButton == true) TCloseIcon(onClose: () => onClose?.call()),
        ],
      ),
    );
  }
}

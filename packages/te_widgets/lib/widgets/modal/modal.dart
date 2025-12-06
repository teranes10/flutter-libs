import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A customizable modal dialog component.
///
/// `TModal` provides a centered modal overlay with:
/// - Optional header and footer
/// - Scrollable content area
/// - Persistent or dismissible modes
/// - Custom width and sizing
/// - Close button support
///
/// ## Basic Usage
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => TModal(
///     Text('Modal content goes here'),
///     title: 'Modal Title',
///     showCloseButton: true,
///     onClose: () => Navigator.pop(context),
///   ),
/// );
/// ```
///
/// ## With Custom Header and Footer
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => TModal(
///     YourContentWidget(),
///     header: CustomHeaderWidget(),
///     footer: Row(
///       children: [
///         TButton(text: 'Cancel', onTap: () => Navigator.pop(context)),
///         TButton(text: 'Save', onTap: () => save()),
///       ],
///     ),
///   ),
/// );
/// ```
///
/// ## Persistent Modal
///
/// ```dart
/// TModal(
///   YourContent(),
///   persistent: true,  // Cannot be dismissed by tapping outside
///   title: 'Important',
///   showCloseButton: true,
/// )
/// ```
///
/// See also:
/// - [TAlert] for simple alert dialogs
class TModal extends StatelessWidget {
  /// Whether the modal is persistent (cannot be dismissed by tapping outside).
  ///
  /// Defaults to false.
  final bool persistent;

  /// The width of the modal.
  ///
  /// Defaults to 500.
  final double width;

  /// The content widget to display in the modal.
  final Widget child;

  /// Custom header widget.
  ///
  /// If null and [title] or [showCloseButton] is provided, a default header is shown.
  final Widget? header;

  /// Custom footer widget.
  final Widget? footer;

  /// The title text for the default header.
  final String? title;

  /// Whether to show the close button in the default header.
  final bool? showCloseButton;

  /// Callback fired when the modal is closed.
  final VoidCallback? onClose;

  /// Gap/margin around the modal.
  ///
  /// Defaults to 15.
  final double gap;

  /// Creates a modal dialog.
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

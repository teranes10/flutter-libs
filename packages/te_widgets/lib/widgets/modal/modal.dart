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
  final double? width;

  /// The content widget to display in the modal.
  final Widget child;

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

  final double minWidth;
  final double minHeight;
  final bool fullscreen;

  final Function(BuildContext context, Widget child)? layoutBuilder;

  /// Creates a modal dialog.
  const TModal(
    this.child, {
    super.key,
    this.persistent = false,
    this.width,
    this.title,
    this.showCloseButton,
    this.onClose,
    this.gap = 50.0,
    this.minWidth = 150.0,
    this.minHeight = 100.0,
    this.fullscreen = false,
    this.layoutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;

    final mMaxWidth = screenSize.width - gap;
    final mMaxHeight = screenSize.height - gap;

    final mWidth = (fullscreen ? screenSize.width : (width ?? 500.0)).clamp(minWidth, mMaxWidth);
    final mHeight = fullscreen ? screenSize.height.clamp(minHeight, mMaxHeight) : null;

    final mConstraints = BoxConstraints(
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: mMaxWidth,
      maxHeight: mMaxHeight,
    );

    final mBorderRadius = BorderRadius.circular(12);

    const preferredTopRatio = 0.165;

    return GestureDetector(
      onTap: () {
        if (!persistent) {
          onClose?.call();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomSingleChildLayout(
          delegate: _ModalPositionDelegate(preferredTopRatio: preferredTopRatio),
          child: GestureDetector(
              onTap: () {}, // Prevent tap propagation
              child: Container(
                width: mWidth,
                height: mHeight,
                constraints: mConstraints,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: mBorderRadius,
                ),
                child: layoutBuilder?.call(context, child) ?? _layout(context, colors, child),
              ),
          ),
        ),
      ),
    );
  }

  Widget _layout(BuildContext context, ColorScheme colors, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if ((title != null || showCloseButton == true)) _buildHeader(context, colors),

        // Scrollable content area
        Flexible(
          child: SingleChildScrollView(child: child),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    final isMobile = context.isMobile;
    final padding = isMobile
        ? const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10)
        : const EdgeInsets.only(left: 25, right: 15, top: 15, bottom: 5);

    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 6,
        children: [
          if (showCloseButton == true && isMobile)
            TIcon(
                icon: Icons.arrow_back_ios_new_rounded, size: 21, padding: EdgeInsets.fromLTRB(3, 3, 3, 1.2), onTap: () => onClose?.call()),
          Expanded(
            child: title != null
                ? Text(title ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: colors.onSurface,
                      overflow: TextOverflow.ellipsis,
                    ))
                : SizedBox.shrink(),
          ),
          if (showCloseButton == true && !isMobile) TIcon.close(size: 20, onTap: () => onClose?.call()),
        ],
      ),
    );
  }
}

/// Positions a modal dialog at [preferredTopRatio] from the top of the screen
/// (e.g. 0.22 = 22% from top) for a natural upper-area feel on small dialogs.
///
/// Automatically clamps the position so the dialog never goes off-screen:
/// - Small dialogs → appear at [preferredTopRatio] from top.
/// - Large dialogs → top position shrinks toward 0 so they always fit.
/// - Dialog is always horizontally centered.
class _ModalPositionDelegate extends SingleChildLayoutDelegate {
  final double preferredTopRatio;

  const _ModalPositionDelegate({this.preferredTopRatio = 0.22});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Pass through constraints unchanged — the dialog sizes itself.
    return constraints;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Center horizontally.
    final x = (size.width - childSize.width) / 2;
    final maxTop = (size.height - childSize.height).clamp(0.0, double.infinity);
    final y = (size.height * preferredTopRatio).clamp(0.0, maxTop / 2);

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_ModalPositionDelegate old) => old.preferredTopRatio != preferredTopRatio;
}

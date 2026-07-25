import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Service for showing modal dialogs.
///
/// `TModalService` provides a simplified API for displaying [TModal] dialogs.
class TModalService {
  /// Shows a modal dialog.
  ///
  /// - [builder]: Function to build the content of the modal.
  /// - [header]: Optional custom header builder.
  /// - [footer]: Optional custom footer builder.
  /// - [persistent]: Whether the modal can be dismissed by tapping outside.
  /// - [width]: The width of the modal (default 500).
  /// - [title]: The title text for the default header.
  /// - [showCloseButton]: Whether to show a close button.
  static Future<T?> show<T>(
    BuildContext context,
    TModalWidgetBuilder<T> builder, {
    bool persistent = false,
    double? width,
    double? minWidth,
    double? minHeight,
    bool fullscreen = false,
    double gap = 50,
    String? title,
    bool? showCloseButton,
    Widget Function(BuildContext context, Widget child)? layoutBuilder,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: persistent,
      builder: (BuildContext dialogContext) {
        final mContext = TModalContext<T>(dialogContext);

        return TModal(
          builder.call(mContext),
          persistent: persistent,
          width: width,
          fullscreen: fullscreen,
          gap: gap,
          title: title,
          showCloseButton: showCloseButton,
          layoutBuilder: layoutBuilder,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  /// Shows an adaptive modal dialog.
  ///
  /// On desktop, this displays a regular modal using [show].
  /// On mobile, it pushes a new page using [TPageWrapper].
  static Future<T?> showAdaptive<T>(
    BuildContext context,
    TModalWidgetBuilder<T> builder, {
    String? title,
    String? subTitle,
    String? imageUrl,
    String? description,
    bool persistent = false,
    double? width,
    bool? showCloseButton,
    Widget Function(BuildContext context, Widget child)? layoutBuilder,
  }) {
    final layout = layoutBuilder ??
        (ctx, child) => defaultAdaptiveLayoutBuilder(
              ctx,
              child,
              title: title,
              subTitle: subTitle,
              imageUrl: imageUrl,
              description: description,
              onBackPressed: () => Navigator.of(ctx).pop(),
            );

    // Mobile: always push a full page.
    if (!context.isDesktop) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute(
          builder: (mContext) {
            final modalCtx = TModalContext<T>(mContext);
            return layout(mContext, builder(modalCtx));
          },
        ),
      );
    }

    return show<T>(
      context,
      builder,
      persistent: persistent,
      width: width,
      layoutBuilder: layout,
    );
  }

  /// Default layout builder for [showAdaptive] mobile (page push) mode.
  static Widget defaultAdaptiveLayoutBuilder(
    BuildContext context,
    Widget child, {
    String? title,
    String? subTitle,
    String? imageUrl,
    String? description,
    VoidCallback? onBackPressed,
  }) {
    return TPageWrapper(
      title: title,
      subTitle: subTitle,
      imageUrl: imageUrl,
      description: description,
      onBackPressed: onBackPressed,
      shrinkWrap: true,
      child: child,
    );
  }
}

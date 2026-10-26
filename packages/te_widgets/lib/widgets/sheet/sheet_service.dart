import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TSheetAnimationType { sliding, drawing }

/// Controls how a [TSideSheet] sizes itself vertically.
enum TSheetHeightMode {
  /// Sheet always fills the full screen height (default, legacy behavior).
  full,

  /// Sheet height hugs its content and is pinned to the top of the screen.
  shrinkWrap,
}

class TSheetService {
  static Future<T?> showBottomSheet<T>(
    BuildContext context,
    TModalWidgetBuilder<T> builder, {
    TModalWidgetBuilder? header,
    TModalWidgetBuilder? footer,
    bool persistent = false,
    double? height,
    String? title,
    bool? showCloseButton,
    bool showHandle = true,
    TSheetAnimationType animationType = TSheetAnimationType.sliding,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: !persistent,
      barrierLabel: 'BottomSheet',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final mContext = TModalContext<T>(context);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: TBottomSheet(
              builder(mContext),
              header: header?.call(mContext),
              footer: footer?.call(mContext),
              title: title,
              showCloseButton: showCloseButton,
              onClose: () => Navigator.pop(context),
              height: height,
              showHandle: showHandle,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (animationType == TSheetAnimationType.drawing) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            // ignore: deprecated_member_use
            axisAlignment: 1,
            child: child,
          );
        } else {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }
      },
    );
  }

  static Future<T?> showSideSheet<T>(
    BuildContext context,
    TModalWidgetBuilder<T> builder, {
    TModalWidgetBuilder? header,
    TModalWidgetBuilder? footer,
    bool persistent = false,
    double width = 400,
    double minWidth = 280,
    double? maxWidth,
    double? widthRatio,
    String? title,
    String? subTitle,
    bool? showCloseButton,
    TSheetAnimationType animationType = TSheetAnimationType.sliding,
    bool fromLeft = false,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Widget Function(BuildContext context, Widget child)? layoutBuilder,
    Duration transitionDuration = const Duration(milliseconds: 250),
    Color barrierColor = Colors.black54,
    TSheetHeightMode heightMode = TSheetHeightMode.full,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: !persistent,
      barrierLabel: 'SideSheet',
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        final mContext = TModalContext<T>(context);
        return Align(
          alignment: fromLeft
              ? (heightMode == TSheetHeightMode.shrinkWrap ? Alignment.topLeft : Alignment.centerLeft)
              : (heightMode == TSheetHeightMode.shrinkWrap ? Alignment.topRight : Alignment.centerRight),
          child: Material(
            color: Colors.transparent,
            child: TSideSheet(
              builder(mContext),
              header: header?.call(mContext),
              footer: footer?.call(mContext),
              title: title,
              subTitle: subTitle,
              showCloseButton: showCloseButton ?? !persistent,
              onClose: () => Navigator.of(context).pop(),
              width: width,
              minWidth: minWidth,
              maxWidth: maxWidth,
              widthRatio: widthRatio,
              fromLeft: fromLeft,
              persistent: persistent,
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
              layoutBuilder: layoutBuilder,
              heightMode: heightMode,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        if (animationType == TSheetAnimationType.drawing) {
          return SizeTransition(
            sizeFactor: curvedAnimation,
            axis: Axis.horizontal,
            // ignore: deprecated_member_use
            axisAlignment: fromLeft ? -1 : 1,
            child: child,
          );
        } else {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(fromLeft ? -1 : 1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TSheetAnimationType { sliding, drawing }

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
    String? title,
    bool? showCloseButton,
    TSheetAnimationType animationType = TSheetAnimationType.sliding,
    bool fromLeft = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: !persistent,
      barrierLabel: 'SideSheet',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final mContext = TModalContext<T>(context);
        return Align(
          alignment: fromLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: TSideSheet(
              builder(mContext),
              header: header?.call(mContext),
              footer: footer?.call(mContext),
              title: title,
              showCloseButton: showCloseButton,
              onClose: () => Navigator.pop(context),
              width: width,
              fromLeft: fromLeft,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (animationType == TSheetAnimationType.drawing) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            axisAlignment: fromLeft ? -1 : 1,
            child: child,
          );
        } else {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(fromLeft ? -1 : 1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:toastification/toastification.dart';

class TToastService {
  static void show(
    BuildContext context,
    String message, {
    String? title,
    IconData? icon,
    Duration? duration,
    Alignment? alignment,
    Color? color,
    TColorType? type,
  }) {
    final exTheme = context.exTheme;
    final mColor = color ?? exTheme.primary;
    final wTheme = context.getWidgetTheme(type ?? exTheme.toastType, mColor);

    toastification.showCustom(
      context: context,
      autoCloseDuration: duration ?? const Duration(seconds: 3),
      alignment: alignment ?? Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      builder: (context, holder) {
        return Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 35, 2),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: title != null ? 6 : 10),
          decoration: BoxDecoration(
              color: wTheme.container, borderRadius: BorderRadius.circular(8), border: wTheme.boxBorder, boxShadow: wTheme.boxShadow),
          child: MouseRegion(
            onEnter: (_) => holder.pause(),
            onExit: (_) => holder.start(),
            child: Row(
              children: [
                if (icon != null) Icon(icon, color: wTheme.onContainer, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(title, style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w400, fontSize: 13)),
                      Text(message, style: TextStyle(color: wTheme.onContainer, fontWeight: FontWeight.w300, fontSize: 12)),
                    ],
                  ),
                ),
                TButton(
                  type: TButtonType.text,
                  size: TButtonSize.xxs,
                  icon: Icons.close_rounded,
                  color: color,
                  onPressed: (_) {
                    toastification.dismissById(holder.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void success(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: Icons.check_circle_outline_rounded, color: context.exTheme.success);
  }

  static void info(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: Icons.info_outline_rounded, color: context.exTheme.info);
  }

  static void warning(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: Icons.warning_amber_rounded, color: context.exTheme.warning);
  }

  static void error(BuildContext context, String message, [String? title]) {
    show(context, message, title: title, icon: Icons.error_outline_rounded, color: context.exTheme.danger);
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

enum TTextFieldSize { sm, md, lg }

enum TTextFieldColor { success, error, info, warning }

mixin TTextFieldMixin {
  String? get label;
  String? get tag;
  String? get placeholder;
  String? get helperText;
  String? get message;
  bool? get required;
  bool? get disabled;
  TTextFieldSize? get size;
  TTextFieldColor? get color;
  BoxDecoration? get boxDecoration;

  Widget buildLabel() {
    if (label == null && tag == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (label != null)
            RichText(
              text: TextSpan(
                text: label!,
                style: TextStyle(
                  fontSize: 12.0,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey.shade500,
                ),
                children: required == true ? [TextSpan(text: ' *', style: TextStyle(color: AppColors.danger))] : null,
              ),
            ),
          if (tag != null)
            Text(
              tag!,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: AppColors.grey.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHelperText() {
    if (helperText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        helperText!,
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: AppColors.grey.shade400),
      ),
    );
  }

  Widget buildMessage() {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        message!,
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: messageColor),
      ),
    );
  }

  BoxDecoration getBoxDecoration({
    required bool isFocused,
    required bool hasErrors,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: getBorderColor(
          isFocused: isFocused,
          hasErrors: hasErrors,
        ),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(6.0),
      color: boxDecoration?.color ?? (disabled == true ? AppColors.grey.shade50 : Colors.white),
      boxShadow: isFocused ? [BoxShadow(color: AppColors.grey.shade50, blurRadius: 3.0, spreadRadius: 3.0)] : null,
    );
  }

  Color getBorderColor({
    required bool isFocused,
    required bool hasErrors,
  }) {
    if (disabled == true) return AppColors.grey.shade200;
    if (hasErrors) return AppColors.danger;

    switch (color) {
      case TTextFieldColor.success:
        return AppColors.success;
      case TTextFieldColor.error:
        return AppColors.danger;
      case TTextFieldColor.info:
        return AppColors.info;
      case TTextFieldColor.warning:
        return AppColors.warning;
      case null:
        return isFocused ? AppColors.grey.shade300 : AppColors.grey.shade200;
    }
  }

  double get fieldHeight {
    switch (size) {
      case TTextFieldSize.sm:
        return 34.0;
      case TTextFieldSize.lg:
        return 42.0;
      case TTextFieldSize.md:
      case null:
        return 38.0;
    }
  }

  EdgeInsets get fieldPadding {
    switch (size) {
      case TTextFieldSize.sm:
        return const EdgeInsets.symmetric(vertical: 5, horizontal: 8);
      case TTextFieldSize.lg:
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 12);
      case TTextFieldSize.md:
      default:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    }
  }

  double get fontSize {
    switch (size) {
      case TTextFieldSize.sm:
        return 12.0;
      case TTextFieldSize.lg:
        return 16.0;
      case TTextFieldSize.md:
      case null:
        return 14.0;
    }
  }

  Color get messageColor {
    switch (color) {
      case TTextFieldColor.success:
        return AppColors.success;
      case TTextFieldColor.error:
        return AppColors.danger;
      case TTextFieldColor.info:
        return AppColors.info;
      case TTextFieldColor.warning:
        return AppColors.warning;
      case null:
        return AppColors.grey.shade600;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

enum TInputSize { sm, md, lg }

enum TInputColor { success, error, info, warning }

mixin TInputFieldMixin {
  String? get label;
  String? get tag;
  String? get placeholder;
  String? get helperText;
  String? get message;
  bool? get isRequired;
  bool? get disabled;
  TInputSize? get size;
  TInputColor? get color;
  BoxDecoration? get boxDecoration;
  Widget? get preWidget;
  Widget? get postWidget;

  double get fieldHeight {
    switch (size) {
      case TInputSize.sm:
        return 34.0;
      case TInputSize.lg:
        return 42.0;
      case TInputSize.md:
      case null:
        return 38.0;
    }
  }

  EdgeInsets get fieldPadding {
    switch (size) {
      case TInputSize.sm:
        return const EdgeInsets.symmetric(vertical: 5, horizontal: 8);
      case TInputSize.lg:
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 12);
      case TInputSize.md:
      default:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    }
  }

  double get fontSize {
    switch (size) {
      case TInputSize.sm:
        return 12.0;
      case TInputSize.lg:
        return 16.0;
      case TInputSize.md:
      case null:
        return 14.0;
    }
  }

  Color get messageColor {
    switch (color) {
      case TInputColor.success:
        return AppColors.success;
      case TInputColor.error:
        return AppColors.danger;
      case TInputColor.info:
        return AppColors.info;
      case TInputColor.warning:
        return AppColors.warning;
      case null:
        return AppColors.grey.shade600;
    }
  }

  BoxDecoration getBoxDecoration({required bool isFocused, required bool hasErrors}) {
    return BoxDecoration(
      border: Border.all(
        color: getBorderColor(isFocused: isFocused, hasErrors: hasErrors),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(6.0),
      color: boxDecoration?.color ?? (disabled == true ? AppColors.grey.shade50 : Colors.white),
      boxShadow: isFocused ? [BoxShadow(color: AppColors.grey.shade50, blurRadius: 3.0, spreadRadius: 3.0)] : null,
    );
  }

  InputDecoration getInputDecoration() {
    return InputDecoration(
      border: InputBorder.none,
      hintText: placeholder ?? label,
      hintStyle: TextStyle(fontWeight: FontWeight.w300, color: AppColors.grey.shade300),
      isCollapsed: true,
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  TextStyle getTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      color: disabled == true ? AppColors.grey.shade400 : AppColors.grey.shade700,
    );
  }

  Color getBorderColor({required bool isFocused, required bool hasErrors}) {
    if (disabled == true) return AppColors.grey.shade200;
    if (hasErrors) return AppColors.danger;

    switch (color) {
      case TInputColor.success:
        return AppColors.success;
      case TInputColor.error:
        return AppColors.danger;
      case TInputColor.info:
        return AppColors.info;
      case TInputColor.warning:
        return AppColors.warning;
      case null:
        return isFocused ? AppColors.grey.shade300 : AppColors.grey.shade200;
    }
  }

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
                children: isRequired == true ? [TextSpan(text: ' *', style: TextStyle(color: AppColors.danger))] : null,
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

  Widget buildValidationErrors(ValueNotifier<List<String>> errorsNotifier) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: errorsNotifier,
      builder: (context, validationErrors, child) {
        if (validationErrors.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: validationErrors.map((error) => Text('• $error', style: TextStyle(fontSize: 12.0, color: AppColors.danger.shade400))).toList(),
          ),
        );
      },
    );
  }

  Widget buildContainer(
      {bool? isMultiline, isFocused, hasErrors, ValueNotifier<List<String>>? errorsNotifier, Widget? child, Widget? postWidget, Widget? preWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(),
        Container(
          constraints: BoxConstraints(
            minHeight: fieldHeight,
            maxHeight: isMultiline == true ? double.infinity : fieldHeight,
          ),
          decoration: getBoxDecoration(
            isFocused: isFocused == true,
            hasErrors: hasErrors == true,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (this.preWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: fieldPadding.top, bottom: fieldPadding.bottom, left: fieldPadding.left),
                      child: Center(child: this.preWidget!)),
                if (preWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: fieldPadding.top, bottom: fieldPadding.bottom, left: fieldPadding.left),
                      child: Center(child: preWidget)),
                Expanded(child: Padding(padding: fieldPadding, child: child)),
                if (postWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: fieldPadding.top, bottom: fieldPadding.bottom, right: fieldPadding.right),
                      child: Center(child: postWidget)),
                if (this.postWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: fieldPadding.top, bottom: fieldPadding.bottom, right: fieldPadding.right),
                      child: Center(child: this.postWidget!)),
              ],
            ),
          ),
        ),
        buildHelperText(),
        buildMessage(),
        if (errorsNotifier != null) buildValidationErrors(errorsNotifier),
      ],
    );
  }
}

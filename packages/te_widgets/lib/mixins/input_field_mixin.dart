import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TInputSize { sm, md, lg }

enum TInputColor { success, error, info, warning }

mixin TInputFieldMixin {
  String? get label;
  String? get tag;
  String? get placeholder;
  String? get helperText;
  String? get message;
  bool get isRequired;
  bool get disabled;
  TInputSize? get size;
  TInputColor? get color;
  BoxDecoration? get boxDecoration;
  Widget? get preWidget;
  Widget? get postWidget;
  VoidCallback? get onTap;

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

  InputDecoration get inputDecoration {
    return InputDecoration(
      border: InputBorder.none,
      hintText: placeholder ?? label,
      hintStyle: TextStyle(fontWeight: FontWeight.w300, color: AppColors.grey.shade300),
      isCollapsed: true,
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  TextStyle get textStyle {
    return TextStyle(
      fontSize: fontSize,
      color: disabled == true ? AppColors.grey.shade400 : AppColors.grey.shade700,
    );
  }

  Widget get labelWidget {
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

  Widget get helperTextWidget {
    if (helperText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        helperText!,
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: AppColors.grey.shade400),
      ),
    );
  }

  Widget get messageWidget {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        message!,
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300, color: messageColor),
      ),
    );
  }
}

mixin TInputFieldStateMixin<W extends StatefulWidget> on State<W> {
  TInputFieldMixin get _widget => widget as TInputFieldMixin;

  BoxDecoration getBoxDecoration({required bool isFocused, required bool hasErrors}) {
    return BoxDecoration(
      border: Border.all(
        color: getBorderColor(isFocused: isFocused, hasErrors: hasErrors),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(6.0),
      color: _widget.boxDecoration?.color ?? (_widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
      boxShadow: isFocused ? [BoxShadow(color: AppColors.grey.shade50, blurRadius: 3.0, spreadRadius: 3.0)] : null,
    );
  }

  Color getBorderColor({required bool isFocused, required bool hasErrors}) {
    if (_widget.disabled == true) return AppColors.grey.shade200;
    if (hasErrors) return AppColors.danger;

    switch (_widget.color) {
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

  Widget buildContainer({
    bool? isMultiline,
    Widget? child,
    Widget? postWidget,
    Widget? preWidget,
    VoidCallback? onTap,
  }) {
    TFocusStateMixin? focusWidget = this is TFocusStateMixin ? this as TFocusStateMixin : null;
    TInputValidationStateMixin? validationMixin = this is TInputValidationStateMixin ? this as TInputValidationStateMixin : null;

    final container = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _widget.labelWidget,
        Container(
          constraints: BoxConstraints(
            minHeight: _widget.fieldHeight,
            maxHeight: isMultiline == true ? double.infinity : _widget.fieldHeight,
          ),
          decoration: getBoxDecoration(
            isFocused: focusWidget?.isFocused == true,
            hasErrors: validationMixin?.hasErrors == true,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (_widget.preWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, left: _widget.fieldPadding.left),
                      child: Center(child: _widget.preWidget!)),
                if (preWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, left: _widget.fieldPadding.left),
                      child: Center(child: preWidget)),
                Expanded(child: Padding(padding: _widget.fieldPadding, child: child)),
                if (postWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, right: _widget.fieldPadding.right),
                      child: Center(child: postWidget)),
                if (_widget.postWidget != null)
                  Padding(
                      padding: EdgeInsets.only(top: _widget.fieldPadding.top, bottom: _widget.fieldPadding.bottom, right: _widget.fieldPadding.right),
                      child: Center(child: _widget.postWidget!)),
              ],
            ),
          ),
        ),
        _widget.helperTextWidget,
        _widget.messageWidget,
        if (validationMixin?.errorsNotifier != null) buildValidationErrors(validationMixin!.errorsNotifier),
      ],
    );

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _widget.onTap?.call();
        onTap?.call();
        focusWidget?.focusNode.requestFocus();
      },
      child: container,
    );
  }
}

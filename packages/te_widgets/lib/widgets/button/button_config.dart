import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TButtonType {
  solid,
  tonal,
  outline,
  softOutline,
  filledOutline,
  text,
  softText,
  filledText,
  icon;

  FontWeight get fontWeight {
    return switch (this) {
      solid || tonal || text || softText || filledText || icon => FontWeight.w400,
      outline || softOutline || filledOutline => FontWeight.w300,
    };
  }
}

enum TButtonGroupType { solid, tonal, outline, softOutline, filledOutline, text, softText, filledText, icon, boxed }

enum TButtonSize { xxs, xs, sm, md, lg }

class TButtonPressOptions {
  final VoidCallback stopLoading;
  TButtonPressOptions({required this.stopLoading});
}

class TButtonSizeData {
  final double minW, minH, hPad, vPad, font, icon, spacing;

  TButtonSizeData({
    required this.minW,
    required this.minH,
    required this.hPad,
    required this.vPad,
    required this.font,
    required this.icon,
    required this.spacing,
  });

  factory TButtonSizeData.from(TButtonSize size) {
    switch (size) {
      case TButtonSize.xxs:
        return TButtonSizeData(minW: 22, minH: 22, hPad: 4, vPad: 1, font: 10, icon: 12, spacing: 3);
      case TButtonSize.xs:
        return TButtonSizeData(minW: 28, minH: 28, hPad: 6, vPad: 2, font: 11, icon: 14, spacing: 4);
      case TButtonSize.sm:
        return TButtonSizeData(minW: 32, minH: 32, hPad: 10, vPad: 4, font: 12, icon: 16, spacing: 5);
      case TButtonSize.md:
        return TButtonSizeData(minW: 38, minH: 38, hPad: 12, vPad: 6, font: 13, icon: 18, spacing: 6);
      case TButtonSize.lg:
        return TButtonSizeData(minW: 42, minH: 42, hPad: 16, vPad: 8, font: 14, icon: 20, spacing: 8);
    }
  }
}

TButtonType mapGroupTypeToButtonType(TButtonGroupType groupType) {
  switch (groupType) {
    case TButtonGroupType.solid:
      return TButtonType.solid;
    case TButtonGroupType.tonal:
      return TButtonType.tonal;
    case TButtonGroupType.outline:
      return TButtonType.outline;
    case TButtonGroupType.softOutline:
      return TButtonType.softOutline;
    case TButtonGroupType.filledOutline:
      return TButtonType.filledOutline;
    case TButtonGroupType.text:
    case TButtonGroupType.icon:
      return TButtonType.text;
    case TButtonGroupType.softText:
      return TButtonType.softText;
    case TButtonGroupType.filledText:
    case TButtonGroupType.boxed:
      return TButtonType.filledText;
  }
}

TColorType mapButtonTypeToColorType(TButtonType buttonType) {
  switch (buttonType) {
    case TButtonType.solid:
      return TColorType.solid;
    case TButtonType.tonal:
      return TColorType.tonal;
    case TButtonType.outline:
      return TColorType.outline;
    case TButtonType.softOutline:
      return TColorType.softOutline;
    case TButtonType.filledOutline:
      return TColorType.filledOutline;
    case TButtonType.text:
    case TButtonType.icon:
      return TColorType.text;
    case TButtonType.softText:
      return TColorType.softText;
    case TButtonType.filledText:
      return TColorType.filledText;
  }
}

extension TButtonGroupExtension on TButton {
  TButton copyWith({
    TButtonType? type,
    Color? color,
    TButtonSize? size,
    bool? block,
    bool? loading,
    String? loadingText,
    IconData? icon,
    String? text,
    String? tooltip,
    Function(TButtonPressOptions)? onPressed,
    bool? active,
    double? width,
    double? height,
    Widget? child,
    OutlinedBorder? shape,
  }) {
    return TButton(
      type: type ?? this.type,
      color: color ?? this.color,
      size: size ?? this.size,
      block: block ?? this.block,
      loading: loading ?? this.loading,
      loadingText: loadingText ?? this.loadingText,
      icon: icon ?? this.icon,
      text: text ?? this.text,
      tooltip: tooltip ?? this.tooltip,
      onPressed: onPressed ?? this.onPressed,
      active: active ?? this.active,
      width: width ?? this.width,
      height: height ?? this.height,
      shape: shape ?? this.shape,
      child: child ?? this.child,
    );
  }

  double estimateWidth() {
    final sizeData = TButtonSizeData.from(size ?? TButtonSize.md);

    double width = sizeData.minW;

    if (icon != null) {
      width += sizeData.icon + sizeData.spacing;
    }

    if (text != null && text!.isNotEmpty) {
      width += text!.length * (sizeData.font * 0.6);
    }

    return width;
  }
}

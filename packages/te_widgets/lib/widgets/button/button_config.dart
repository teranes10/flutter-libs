import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/button/button.dart';

enum TButtonType { fill, inverse, outline, outlineFill, text, textFill, icon }

enum TButtonGroupType { fill, inverse, outline, outlineFill, text, textFill, icon, boxed }

enum TButtonSize { xxs, xs, sm, md, lg }

class TButtonPressOptions {
  final VoidCallback stopLoading;
  TButtonPressOptions({required this.stopLoading});
}

class TButtonColorScheme {
  final Color bg, fg, bgActive, fgActive;
  final Color? border, borderActive;

  TButtonColorScheme({
    required this.bg,
    required this.bgActive,
    required this.fg,
    required this.fgActive,
    this.border,
    this.borderActive,
  });

  factory TButtonColorScheme.from(MaterialColor c, TButtonType type) {
    switch (type) {
      case TButtonType.fill:
        return TButtonColorScheme(
          bg: c.shade400,
          bgActive: c.shade400.withAlpha(225),
          fg: c.shade50,
          fgActive: c.shade50,
        );
      case TButtonType.inverse:
        return TButtonColorScheme(
          bg: c.shade50,
          bgActive: c.shade100.withAlpha(150),
          fg: c.shade400,
          fgActive: c.shade400,
        );
      case TButtonType.outline:
        return TButtonColorScheme(
          bg: Colors.transparent,
          bgActive: c.shade50,
          fg: c.shade400,
          fgActive: c.shade400,
          border: c.shade300,
          borderActive: c.shade200.withAlpha(200),
        );
      case TButtonType.outlineFill:
        return TButtonColorScheme(
          bg: Colors.transparent,
          bgActive: c.shade400,
          fg: c.shade400,
          fgActive: c.shade50,
          border: c.shade300,
          borderActive: c.shade300,
        );
      case TButtonType.text:
        return TButtonColorScheme(
          bg: Colors.transparent,
          bgActive: c.shade50,
          fg: c.shade400,
          fgActive: c.shade400,
        );
      case TButtonType.textFill:
        return TButtonColorScheme(
          bg: Colors.transparent,
          bgActive: c.shade400,
          fg: c.shade400,
          fgActive: c.shade50,
        );
      case TButtonType.icon:
        return TButtonColorScheme(
          bg: Colors.transparent,
          bgActive: Colors.transparent,
          fg: c.shade400,
          fgActive: c.shade600.withAlpha(225),
        );
    }
  }
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
    case TButtonGroupType.fill:
      return TButtonType.fill;
    case TButtonGroupType.outline:
      return TButtonType.outline;
    case TButtonGroupType.outlineFill:
      return TButtonType.outlineFill;
    case TButtonGroupType.text:
      return TButtonType.text;
    case TButtonGroupType.textFill:
      return TButtonType.textFill;
    case TButtonGroupType.icon:
      return TButtonType.icon;
    case TButtonGroupType.boxed:
      return TButtonType.textFill;
    case TButtonGroupType.inverse:
      return TButtonType.inverse;
  }
}

extension TButtonGroupExtension on TButton {
  TButton copyWith({
    TButtonType? type,
    MaterialColor? color,
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
}

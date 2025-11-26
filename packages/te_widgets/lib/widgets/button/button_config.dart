part of 'button.dart';

class TButtonPressOptions {
  final VoidCallback stopLoading;
  TButtonPressOptions({required this.stopLoading});
}

class TButtonGroupItem {
  final IconData? icon;
  final String? text;
  final bool loading;
  final String loadingText;
  final Color? color;
  final String? tooltip;
  final bool active;
  final VoidCallback? onTap;
  final Function(TButtonPressOptions)? onPressed;
  final Widget? child;

  TButtonGroupItem({
    this.icon,
    this.text,
    this.loading = false,
    this.loadingText = 'Loading...',
    this.color,
    this.tooltip,
    this.active = false,
    this.child,
    this.onTap,
    this.onPressed,
  });
}

extension TButtonExtension on TButton {
  TButton copyWith({
    TButtonTheme? theme,
    TButtonType? type,
    Color? color,
    TButtonSize? size,
    bool? loading,
    String? loadingText,
    IconData? icon,
    String? text,
    String? tooltip,
    VoidCallback? onTap,
    Function(TButtonPressOptions)? onPressed,
    bool? active,
    Widget? child,
  }) {
    return TButton(
      theme: theme ?? this.theme,
      type: type ?? this.type,
      color: color ?? this.color,
      size: size ?? this.size,
      loading: loading ?? this.loading,
      loadingText: loadingText ?? this.loadingText,
      icon: icon ?? this.icon,
      text: text ?? this.text,
      tooltip: tooltip ?? this.tooltip,
      onTap: onTap ?? this.onTap,
      onPressed: onPressed ?? this.onPressed,
      active: active ?? this.active,
      child: child ?? this.child,
    );
  }

  double estimateWidth() {
    final sizeData = size ?? TButtonSize.md;

    double width = sizeData.minW;

    if (icon != null) {
      width += sizeData.icon + sizeData.spacing;
    }

    if (text != null && text!.isNotEmpty) {
      width += text!.length * (sizeData.font * 0.75);
    }

    return width;
  }
}

part of 'button.dart';

/// Options passed to the `onPressed` callback.
class TButtonPressOptions {
  /// Callback to stop the button's loading state.
  final VoidCallback stopLoading;

  /// Creates button press options.
  TButtonPressOptions({required this.stopLoading});
}

/// Defines an item within a [TButtonGroup].
class TButtonGroupItem {
  /// Optional icon for the button.
  final IconData? icon;

  /// Optional text label.
  final String? text;

  /// Whether the button is in a loading state.
  final bool loading;

  /// Text to display while loading.
  final String loadingText;

  /// Custom color for the button.
  final Color? color;

  /// Tooltip text.
  final String? tooltip;

  /// Whether the button is currently active/selected.
  final bool active;

  /// Simple tap callback.
  final VoidCallback? onTap;

  /// Async press callback with loading control.
  final Function(TButtonPressOptions)? onPressed;

  /// Custom child widget (overrides icon/text).
  final Widget? child;

  /// Creates a button group item.
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

/// Utility extension for [TButton] updates.
extension TButtonExtension on TButton {
  /// Creates a copy of the button with updated properties.
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

  /// Estimates the width of the button based on its content and size settings.
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

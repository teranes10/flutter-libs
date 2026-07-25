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
    TWidgetTheme? baseTheme,
    TButtonShape? shape,
    TButtonType? type,
    TButtonSize? size,
    IconData? icon,
    String? imageUrl,
    Color? color,
    String? text,
    bool? loading,
    String? loadingText,
    String? tooltip,
    bool? active,
    IconData? activeIcon,
    Color? activeColor,
    Widget? child,
    VoidCallback? onTap,
    Function(TButtonPressOptions)? onPressed,
    ValueChanged<bool>? onChanged,
    Duration? duration,
    Duration? throttleDuration,
  }) {
    return TButton(
      theme: theme ?? this.theme,
      baseTheme: baseTheme ?? this.baseTheme,
      shape: shape ?? this.shape,
      type: type ?? this.type,
      size: size ?? this.size,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      text: text ?? this.text,
      loading: loading ?? this.loading,
      loadingText: loadingText ?? this.loadingText,
      tooltip: tooltip ?? this.tooltip,
      active: active ?? this.active,
      activeIcon: activeIcon ?? this.activeIcon,
      activeColor: activeColor ?? this.activeColor,
      onTap: onTap ?? this.onTap,
      onPressed: onPressed ?? this.onPressed,
      onChanged: onChanged ?? this.onChanged,
      duration: duration ?? this.duration,
      throttleDuration: throttleDuration ?? this.throttleDuration,
      child: child ?? this.child,
    );
  }
}

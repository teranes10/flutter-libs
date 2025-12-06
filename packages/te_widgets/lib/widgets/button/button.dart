import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'button_config.dart';
part 'button_group_theme.dart';
part 'button_group.dart';
part 'button_theme.dart';

/// A customizable button widget with multiple variants, sizes, and states.
///
/// `TButton` provides a comprehensive button solution with support for:
/// - Multiple visual types (solid, tonal, outline, text, icon)
/// - Different sizes (xxs, xs, sm, md, lg, block)
/// - Various shapes (normal, pill, circle)
/// - Loading states with automatic management
/// - Active/toggle states
/// - Icons and images
/// - Custom theming
///
/// ## Basic Usage
///
/// ```dart
/// TButton(
///   text: 'Click Me',
///   icon: Icons.check,
///   color: AppColors.primary,
///   onTap: () => print('Tapped!'),
/// )
/// ```
///
/// ## With Loading State
///
/// ```dart
/// TButton(
///   text: 'Submit',
///   loading: true,
///   onPressed: (options) async {
///     await performAsyncOperation();
///     options.stopLoading();
///   },
/// )
/// ```
///
/// ## Toggle Button
///
/// ```dart
/// TButton(
///   icon: Icons.favorite_border,
///   activeIcon: Icons.favorite,
///   color: Colors.grey,
///   activeColor: Colors.red,
///   onChanged: (isActive) => print('Active: $isActive'),
/// )
/// ```
///
/// See also:
/// - [TButtonTheme] for customizing button appearance
/// - [TButtonSize] for available size options
/// - [TButtonType] for available visual variants
class TButton extends StatefulWidget {
  /// The theme configuration for this button.
  ///
  /// If provided, [baseTheme], [type], [size], [shape], and [color] must be null.
  final TButtonTheme? theme;

  /// The base widget theme to use.
  ///
  /// If provided, [type], [color], and [activeColor] must be null.
  final TWidgetTheme? baseTheme;

  /// The shape of the button.
  ///
  /// Available options: [TButtonShape.normal], [TButtonShape.pill], [TButtonShape.circle].
  /// Defaults to the theme's default shape.
  final TButtonShape? shape;

  /// The visual type/variant of the button.
  ///
  /// Available options: solid, tonal, outline, softOutline, filledOutline,
  /// text, softText, filledText, icon.
  /// Defaults to the theme's default type.
  final TButtonType? type;

  /// The size configuration for the button.
  ///
  /// Available presets: [TButtonSize.xxs], [TButtonSize.xs], [TButtonSize.sm],
  /// [TButtonSize.md], [TButtonSize.lg], [TButtonSize.block].
  /// Defaults to [TButtonSize.md].
  final TButtonSize? size;

  /// The icon to display in the button.
  ///
  /// Cannot be used together with [imageUrl].
  final IconData? icon;

  /// The URL of an image to display in the button.
  ///
  /// Cannot be used together with [icon].
  final String? imageUrl;

  /// The primary color of the button.
  ///
  /// This affects the button's background, border, or text color depending on [type].
  final Color? color;

  /// The text to display in the button.
  final String? text;

  /// Whether to show a loading indicator when [onPressed] is called.
  ///
  /// When true, a loading indicator will be shown automatically when [onPressed]
  /// is triggered. Call `options.stopLoading()` to hide it.
  /// Defaults to false.
  final bool loading;

  /// The text to display while loading.
  ///
  /// Only shown when [loading] is true and the button is in loading state.
  /// Defaults to 'Loading...'.
  final String loadingText;

  /// The tooltip message to show on hover.
  final String? tooltip;

  /// Whether the button is in an active state.
  ///
  /// When true, [activeIcon] and [activeColor] will be used if provided.
  /// Defaults to false.
  final bool active;

  /// The icon to display when the button is active.
  ///
  /// Falls back to [icon] if not provided.
  final IconData? activeIcon;

  /// The color to use when the button is active.
  ///
  /// Falls back to [color] if not provided.
  final Color? activeColor;

  /// A custom child widget to display in the button.
  ///
  /// If provided, this takes precedence over [icon], [imageUrl], and [text].
  final Widget? child;

  /// Callback fired when the button is tapped.
  ///
  /// This is a simple tap handler without loading state management.
  final VoidCallback? onTap;

  /// Callback fired when the button is pressed with loading state support.
  ///
  /// Provides [TButtonPressOptions] to control the loading state.
  /// Call `options.stopLoading()` when the async operation completes.
  final Function(TButtonPressOptions)? onPressed;

  /// Callback fired when the button's active state changes.
  ///
  /// Useful for toggle buttons. The callback receives the new active state.
  final ValueChanged<bool>? onChanged;

  /// The duration for animations (icon changes, color transitions).
  ///
  /// Defaults to 400 milliseconds.
  final Duration duration;

  /// Creates a customizable button widget.
  ///
  /// At least one of [onTap], [onPressed], or [onChanged] should be provided
  /// for the button to be interactive.
  const TButton({
    super.key,
    this.baseTheme,
    this.theme,
    this.shape,
    this.type,
    this.size,
    this.color,
    this.loading = false,
    this.loadingText = 'Loading...',
    this.icon,
    this.imageUrl,
    this.text,
    this.tooltip,
    this.onTap,
    this.onPressed,
    this.active = false,
    this.activeIcon,
    this.activeColor,
    this.child,
    this.onChanged,
    this.duration = const Duration(milliseconds: 400),
  })  : assert(
          theme == null || (baseTheme == null && type == null && size == null && shape == null && color == null),
          'If theme is provided, baseTheme, type, shape, color and size must be null.',
        ),
        assert(baseTheme == null || (type == null && color == null && activeColor == null),
            'If baseTheme is provided, type, color and activeColor must be null.'),
        assert(imageUrl == null || icon == null, 'Provide either `imageUrl` or `icon`, but not both.');

  @override
  State<TButton> createState() => _TButtonState();

  /// Creates a custom button with minimal styling.
  ///
  /// This factory provides a button with zero padding and normal shape,
  /// allowing complete customization via the [child] parameter.
  ///
  /// Example:
  /// ```dart
  /// TButton.custom(
  ///   onTap: () => print('Custom button tapped'),
  ///   child: Container(
  ///     padding: EdgeInsets.all(16),
  ///     decoration: BoxDecoration(
  ///       gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
  ///     ),
  ///     child: Text('Custom Styled Button'),
  ///   ),
  /// )
  /// ```
  static custom({required Widget child, VoidCallback? onTap, String? tooltip}) {
    return TButton(
      size: TButtonSize.zero,
      shape: TButtonShape.normal,
      onTap: onTap,
      tooltip: tooltip,
      child: child,
    );
  }
}

class _TButtonState extends State<TButton> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isActive = false;

  late final WidgetStatesController _statesController;

  late final AnimationController _pressController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
    parent: _pressController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  ));

  @override
  void initState() {
    super.initState();
    _isActive = widget.active;
    _statesController = WidgetStatesController();
  }

  @override
  void didUpdateWidget(TButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != _isActive) {
      setState(() => _isActive = widget.active);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _statesController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (_isLoading || (widget.onPressed == null && widget.onTap == null && widget.onChanged == null)) return;

    _pressController.forward().then((_) {
      if (mounted) _pressController.reverse();
    });

    if (widget.onChanged != null) {
      final newActive = !_isActive;
      setState(() => _isActive = newActive);
      widget.onChanged?.call(newActive);
    }

    if (widget.onTap != null) {
      widget.onTap!();
    }

    if (widget.onPressed != null) {
      if (widget.loading) {
        setState(() => _isLoading = true);
      }

      widget.onPressed!(TButtonPressOptions(
        stopLoading: () {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = context.theme.buttonTheme;
    final size = widget.size ?? widget.theme?.size ?? defaultTheme.size;
    final activeColor = _isActive ? (widget.activeColor ?? widget.color) : widget.color;
    final icon = _isActive ? (widget.activeIcon ?? widget.icon) : widget.icon;
    final text = widget.text;
    final baseTheme =
        widget.baseTheme ?? widget.theme?.baseTheme ?? defaultTheme.baseTheme.rebuild(color: activeColor, type: widget.type?.colorType);
    final theme = widget.theme ?? defaultTheme.copyWith(size: size, shape: widget.shape, baseTheme: baseTheme);

    assert(theme.shape != TButtonShape.circle || text.isNullOrBlank, 'Circle shape only supports icon, no text.');

    final buttonContent = AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: size.minW.isInfinite ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: size.spacing,
        children: [
          if (_isLoading)
            SizedBox(
              width: size.icon,
              height: size.icon,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(theme.baseTheme.foregroundState.resolve(_statesController.value)),
              ),
            )
          else if (icon != null)
            AnimatedSwitcher(
              duration: widget.duration,
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(key: ValueKey(_isActive), icon, size: size.icon),
            )
          else if (widget.imageUrl != null)
            if (theme.shape == TButtonShape.normal)
              TImage(
                size: size.icon,
                url: widget.imageUrl,
                color: theme.baseTheme.onContainerVariant.withAlpha(50),
                disabled: true,
                border: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              )
            else
              TImage.circle(
                size: size.icon,
                url: widget.imageUrl,
                color: theme.baseTheme.onContainerVariant.withAlpha(50),
                disabled: true,
              ),
          if (!text.isNullOrBlank) Text(_isLoading ? widget.loadingText : text!),
          if (widget.child != null) widget.child!,
        ],
      ),
    );

    final button = ScaleTransition(
      scale: _scaleAnimation,
      child: ElevatedButton(
        onPressed: (widget.onPressed == null && widget.onTap == null && widget.onChanged == null) ? null : _handlePress,
        style: theme.buttonStyle,
        child: buttonContent,
      ),
    );

    if (widget.tooltip != null) {
      return TTooltip(
        message: widget.tooltip!,
        color: theme.baseTheme.color,
        child: button,
      );
    }

    return button;
  }
}

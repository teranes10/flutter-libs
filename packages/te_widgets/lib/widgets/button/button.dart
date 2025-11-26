import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'button_config.dart';
part 'button_group_theme.dart';
part 'button_group.dart';
part 'button_theme.dart';

class TButton extends StatefulWidget {
  final TButtonTheme? theme;
  final TWidgetTheme? baseTheme;
  final TButtonShape? shape;
  final TButtonType? type;
  final TButtonSize? size;
  final IconData? icon;
  final String? imageUrl;
  final Color? color;
  final String? text;
  final bool loading;
  final String loadingText;
  final String? tooltip;
  final bool active;
  final IconData? activeIcon;
  final Color? activeColor;
  final Widget? child;
  final VoidCallback? onTap;
  final Function(TButtonPressOptions)? onPressed;
  final ValueChanged<bool>? onChanged;
  final Duration duration;

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

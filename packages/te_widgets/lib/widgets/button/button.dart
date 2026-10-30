import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
///   icon: HugeIcons.strokeRoundedTick01,
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
///   icon: HugeIcons.strokeRoundedFavouriteCircle,
///   activeIcon: HugeIcons.strokeRoundedFavourite,
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
  /// Supports [IconData], [List<List<dynamic>>] (HugeIcon), or [Widget].
  /// Cannot be used together with [imageUrl].
  final dynamic icon;

  /// The URL of an image to display in the button.
  ///
  /// Cannot be used together with [icon].
  final String? imageUrl;

  /// Whether [imageUrl] is persistently cached via [TImageStorage] instead of
  /// just Flutter's in-memory [ImageCache]. See [TImage.forceCache].
  final bool forceCache;

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

  /// An optional notifier to dynamically update the loading message.
  ///
  /// If provided, the button will listen to this notifier and update its text
  /// while in the loading state, ignoring [loadingText].
  final ValueNotifier<String>? loadingNotifier;

  /// The tooltip message to show on hover.
  final String? tooltip;

  /// Whether the button is in an active state.
  ///
  /// When true, [activeIcon] and [activeColor] will be used if provided.
  /// Defaults to false.
  final bool active;

  /// The icon to display when the button is active.
  ///
  /// Supports [IconData], [List<List<dynamic>>] (HugeIcon), or [Widget].
  /// Falls back to [icon] if not provided.
  final dynamic activeIcon;

  /// The color to use when the button is active.
  ///
  /// Falls back to [color] if not provided.
  final Color? activeColor;

  /// Rotation turns (initial, active) for animation when active state changes.
  /// Rotation turns (initial, active) for animation when active state changes.
  final (double initial, double active)? turns;

  /// Whether to show a checkmark tick when the button is active.
  final bool showTick;

  /// The alignment of the tick indicator (e.g. top right). Defaults to [Alignment.topRight].
  final Alignment tickAlignment;

  /// Custom widget to display for the tick indicator.
  final Widget? tickWidget;

  /// An optional badge to display on the button (e.g. notification count, status dot, text, or custom widget).
  ///
  /// Supports [Widget], [String], [num]/[int], or [bool] (for dot indicator).
  final dynamic badge;

  /// The size configuration for the badge. Defaults to null (uses standard badge size).
  final TSize? badgeSize;

  /// Permission required to use this button (a `String` or [TPermission]),
  /// checked against the nearest [TAuthScope]. Null means no restriction.
  final Object? permission;

  /// What to do when [permission] is denied. Null uses the [TAuthConfig] default
  /// (disabled for buttons).
  final TAuthMode? onDenied;

  /// The alignment of the badge overlay. Defaults to [Alignment.topRight].
  final Alignment badgeAlignment;

  /// The background color for the badge. Defaults to [AppColors.danger] or error theme color.
  final Color? badgeColor;

  /// The text color for the badge. Defaults to [Colors.white].
  final Color? badgeTextColor;

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

  /// The duration to throttle/debounce button taps to prevent duplicate submissions.
  ///
  /// Defaults to null (no throttle).
  final Duration? throttleDuration;

  /// An optional gradient for the button background.
  ///
  /// If not provided, a subtle lighting gradient is automatically generated
  /// for filled buttons (solid and tonal) to provide tactile depth.
  final Gradient? gradient;

  /// The elevation of the button.
  ///
  /// Defaults to null, resolving to minimal elevation (resting 1.0, hover 2.0, pressed 0.5)
  /// for solid buttons, 0.5 for tonal buttons, and 0.0 for outline/text buttons.
  final double? elevation;

  /// Custom shadow color for the button elevation.
  final Color? shadowColor;

  /// Accessible label for icon-only buttons. Falls back to [tooltip], then [text].
  final String? semanticLabel;

  /// Stable identifier exposed as `flt-semantics-identifier` on Flutter web for e2e tests.
  final String? semanticIdentifier;

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
    this.loadingNotifier,
    this.icon,
    this.imageUrl,
    this.forceCache = false,
    this.text,
    this.tooltip,
    this.onTap,
    this.onPressed,
    this.active = false,
    this.activeIcon,
    this.activeColor,
    this.turns,
    this.showTick = false,
    this.tickAlignment = Alignment.topRight,
    this.tickWidget,
    this.badge,
    this.badgeSize,
    this.badgeAlignment = Alignment.topRight,
    this.badgeColor,
    this.badgeTextColor,
    this.child,
    this.onChanged,
    this.duration = const Duration(milliseconds: 400),
    this.throttleDuration,
    this.gradient,
    this.elevation,
    this.shadowColor,
    this.semanticLabel,
    this.semanticIdentifier,
    this.permission,
    this.onDenied,
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
  static TButton custom({
    required Widget child,
    VoidCallback? onTap,
    String? tooltip,
    dynamic badge,
    Alignment badgeAlignment = Alignment.topRight,
    Color? badgeColor,
    Color? badgeTextColor,
    double? elevation,
    Gradient? gradient,
    Color? shadowColor,
  }) {
    return TButton(
      size: TButtonSize.zero,
      shape: TButtonShape.normal,
      elevation: elevation ?? 0.0,
      gradient: gradient,
      shadowColor: shadowColor,
      onTap: onTap,
      tooltip: tooltip,
      badge: badge,
      badgeAlignment: badgeAlignment,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      child: child,
    );
  }
}

class _TButtonState extends State<TButton> with SingleTickerProviderStateMixin {
  final _TightWidthState _tightProbe = _TightWidthState();
  bool _isLoading = false;
  bool _isActive = false;
  DateTime? _lastTapTime;
  bool _authDisabled = false;

  late final WidgetStatesController _statesController;

  late final AnimationController _pressController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 1.0,
    end: widget.theme?.scaleOnPress ?? 0.96,
  ).animate(CurvedAnimation(
    parent: _pressController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  ));

  @override
  void initState() {
    super.initState();
    _isActive = widget.active;
    _statesController = WidgetStatesController();
    if (_isActive) {
      _statesController.update(WidgetState.selected, true);
      _statesController.update(WidgetState.pressed, true);
    }
  }

  @override
  void didUpdateWidget(TButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      setState(() {
        _isActive = widget.active;
        _statesController.update(WidgetState.selected, _isActive);
        _statesController.update(WidgetState.pressed, _isActive);
      });
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _statesController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.throttleDuration != null) {
      final now = DateTime.now();
      if (_lastTapTime != null && now.difference(_lastTapTime!) < widget.throttleDuration!) {
        return;
      }
      _lastTapTime = now;
    }

    if (_isLoading || _authDisabled || (widget.onPressed == null && widget.onTap == null && widget.onChanged == null)) return;

    _pressController.forward().then((_) {
      if (mounted) _pressController.reverse();
    });

    if (widget.onChanged != null) {
      final newActive = !_isActive;
      setState(() {
        _isActive = newActive;
        _statesController.update(WidgetState.selected, _isActive);
        _statesController.update(WidgetState.pressed, _isActive);
      });
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

  Gradient? _resolveGradient({
    required TWidgetTheme baseTheme,
    required bool isFill,
  }) {
    if (widget.gradient != null) return widget.gradient;
    if (widget.theme?.gradient != null) return widget.theme!.gradient;
    if (!isFill) return null;

    final baseColor = baseTheme.container;
    if (baseColor.isTransparent) return null;

    final isDark = baseTheme.isDarkMode;
    final isTonal = baseTheme.type == TVariant.tonal;
    final topAmount = isTonal ? (isDark ? 0.03 : 0.04) : (isDark ? 0.06 : 0.07);
    final bottomAmount = isTonal ? (isDark ? 0.02 : 0.02) : (isDark ? 0.04 : 0.04);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor.lighten(topAmount),
        baseColor.darken(bottomAmount),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.authResolve(widget.permission, target: TAuthTarget.button, onDenied: widget.onDenied);
    if (auth.isHidden) return const SizedBox.shrink();
    _authDisabled = auth.isDisabled;
    final defaultTheme = context.theme.buttonTheme;
    final size = widget.size ?? widget.theme?.size ?? defaultTheme.size;
    final activeColor = _isActive ? (widget.activeColor ?? widget.color) : widget.color;
    final icon = _isActive ? (widget.activeIcon ?? widget.icon) : widget.icon;
    final text = widget.text;
    final baseTheme =
        widget.baseTheme ?? widget.theme?.baseTheme ?? defaultTheme.baseTheme.rebuild(color: activeColor, type: widget.type?.colorType);
    final theme = widget.theme ??
        defaultTheme.copyWith(
          size: size,
          shape: widget.shape,
          baseTheme: baseTheme,
          elevation: widget.elevation,
          gradient: widget.gradient,
          shadowColor: widget.shadowColor,
        );

    assert(theme.shape != TButtonShape.circle || text.isNullOrBlank, 'Circle shape only supports icon, no text.');

    final hasIcon = icon != null;

    final contentChildren = [
      if (_isLoading)
        SizedBox(
          width: size.icon,
          height: size.icon,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(theme.baseTheme.foregroundState.resolve(_statesController.value)),
          ),
        )
      else if (hasIcon)
        widget.turns != null
            ? TIcon(
                icon: widget.icon,
                activeIcon: widget.activeIcon,
                active: _isActive,
                size: size.icon,
                padding: EdgeInsets.zero,
                color: theme.baseTheme.foregroundState.resolve(_statesController.value),
                turns: widget.turns,
                animationMilliseconds: widget.duration.inMilliseconds,
              )
            : AnimatedSwitcher(
                duration: widget.duration,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: TIcon(
                  key: ValueKey(_isActive),
                  icon: icon,
                  size: size.icon,
                  padding: EdgeInsets.zero,
                  color: theme.baseTheme.foregroundState.resolve(_statesController.value),
                  animationMilliseconds: widget.duration.inMilliseconds,
                ),
              )
      else if (widget.imageUrl != null)
        if (theme.shape == TButtonShape.normal)
          TImage(
            size: size.icon,
            url: widget.imageUrl,
            color: theme.baseTheme.onContainerVariant.withAlpha(50),
            disabled: true,
            forceCache: widget.forceCache,
            border: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          )
        else
          TImage.circle(
            size: size.icon,
            url: widget.imageUrl,
            color: theme.baseTheme.onContainerVariant.withAlpha(50),
            disabled: true,
            forceCache: widget.forceCache,
          ),
      if (!text.isNullOrBlank)
        Flexible(
          child: widget.loadingNotifier != null && _isLoading
              ? ValueListenableBuilder<String>(
                  valueListenable: widget.loadingNotifier!,
                  builder: (context, value, _) => Text(value, overflow: TextOverflow.ellipsis),
                )
              : Text(_isLoading ? widget.loadingText : text!, overflow: TextOverflow.ellipsis),
        ),
      if ((hasIcon || widget.imageUrl != null) && !text.isNullOrBlank && theme.shape == TButtonShape.pill)
        SizedBox(width: theme.size.spacing),
      if (widget.child != null) widget.child!,
    ];

    Widget buildButton() {
      final isExpandedOrBlock = size.minW.isInfinite;

      final buttonContent = AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeInOut,
        padding: widget.showTick ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2) : EdgeInsets.zero,
        child: theme.shape.vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: size.spacing,
                children: contentChildren,
              )
            : Row(
                mainAxisSize: isExpandedOrBlock ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: size.spacing,
                children: contentChildren,
              ),
      );

      final isCustomChildOnly =
          widget.child != null && widget.text == null && widget.icon == null && widget.imageUrl == null && size == TButtonSize.zero;

      final isFill = baseTheme.type == TVariant.solid ||
          (!baseTheme.container.isTransparent && baseTheme.type != TVariant.outline && baseTheme.type != TVariant.text);

      final isDisabled = _authDisabled || (widget.onPressed == null && widget.onTap == null && widget.onChanged == null);
      final states = _statesController.value;
      final effectiveElevation = widget.elevation ?? theme.elevation ?? (isFill ? (baseTheme.type == TVariant.solid ? 1.0 : 0.5) : 0.0);

      final effectiveShadowColor =
          (widget.shadowColor ?? theme.shadowColor ?? baseTheme.shadow ?? baseTheme.color.shade(900)).withValues(alpha: 0.18);

      final OutlinedBorder effectiveBorder = theme.buttonStyle.shape?.resolve(states) ?? theme.shape.border;

      final resolvedPadding = switch (theme.shape) {
        TButtonShape.tile => size.tilePaddingState.resolve(states),
        _ => size.paddingState.resolve(states),
      };

      final effectiveGradient = (isCustomChildOnly || isDisabled)
          ? widget.gradient
          : _resolveGradient(
              baseTheme: baseTheme,
              isFill: isFill,
            );

      final effectiveButtonStyle = theme.buttonStyle.copyWith(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (effectiveGradient != null && !s.contains(WidgetState.disabled)) {
            return Colors.transparent;
          }
          return baseTheme.backgroundState.resolve(s);
        }),
        elevation: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return 0.0;
          if (!isFill && widget.elevation == null && theme.elevation == null) return 0.0;
          if (s.contains(WidgetState.pressed)) return (effectiveElevation * 0.5).clamp(0.0, 1.0);
          if (s.contains(WidgetState.hovered)) return effectiveElevation + 1.0;
          return effectiveElevation;
        }),
        shadowColor: WidgetStateProperty.resolveWith((s) {
          if (!isFill && widget.shadowColor == null && theme.shadowColor == null) return Colors.transparent;
          return effectiveShadowColor;
        }),
      );

      final decorationBorder = effectiveBorder.copyWith(side: BorderSide.none);

      final Widget innerWidget = isCustomChildOnly
          ? buttonContent
          : Ink(
              decoration: effectiveGradient != null && !isDisabled
                  ? ShapeDecoration(
                      shape: decorationBorder,
                      gradient: effectiveGradient,
                    )
                  : null,
              child: _FillIfTight(
                probe: _tightProbe,
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Container(
                    width: isExpandedOrBlock ? double.infinity : null,
                    alignment: isExpandedOrBlock ? Alignment.center : null,
                    constraints: BoxConstraints(minWidth: size.minW, minHeight: size.minH),
                    padding: resolvedPadding,
                    child: buttonContent,
                  ),
                ),
              ),
            );

      Widget resultButton = ScaleTransition(
        scale: _scaleAnimation,
        // Fill the width when the parent forces it (e.g. Expanded in a Row), so the
        // gradient/content isn't left floating inside a wider ElevatedButton.
        child: _TightWidthProbe(
          probe: _tightProbe,
          child: ElevatedButton(
            statesController: _statesController,
            onPressed: isDisabled ? null : _handlePress,
            style: effectiveButtonStyle,
            child: innerWidget,
          ),
        ),
      );

      if (widget.tooltip != null) {
        resultButton = TTooltip(
          triggerMode: TTooltipTriggerMode.hover,
          message: widget.tooltip!,
          color: theme.baseTheme.color,
          child: resultButton,
        );
      }

      final a11yLabel = widget.semanticLabel ?? (text.isNullOrBlank ? widget.tooltip : null);
      if (a11yLabel != null || widget.semanticIdentifier != null) {
        resultButton = Semantics(
          container: true,
          button: true,
          enabled: !isDisabled,
          label: a11yLabel,
          identifier: widget.semanticIdentifier,
          child: resultButton,
        );
      }

      final showTick = widget.showTick && _isActive;

      if (showTick) {
        final isTop = widget.tickAlignment.y < 0;
        final isBottom = widget.tickAlignment.y > 0;
        final isLeft = widget.tickAlignment.x < 0;
        final isRight = widget.tickAlignment.x > 0;

        final tickColor = widget.activeColor ?? widget.color ?? context.colors.primary;
        final offset = theme.shape.vertical ? 5.0 : 4.0;

        final tickPositioned = Positioned(
          top: isTop ? offset : null,
          bottom: isBottom ? offset : null,
          left: isLeft ? offset : null,
          right: isRight ? offset : null,
          child: widget.tickWidget ??
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tickColor,
                ),
                child: TIcon.raw(HugeIcons.strokeRoundedCheck, size: 9, color: Colors.white),
              ),
        );

        resultButton = Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            resultButton,
            tickPositioned,
          ],
        );
      }

      if (widget.badge != null) {
        resultButton = TBadge(
          badge: widget.badge,
          size: widget.badgeSize,
          alignment: widget.badgeAlignment,
          color: widget.badgeColor,
          textColor: widget.badgeTextColor,
          child: resultButton,
        );
      }

      return resultButton;
    }

    return buildButton();
  }
}

/// Whether the button was given a tight width by its parent.
class _TightWidthState {
  bool tight = false;
}

/// Records, at layout time, whether the incoming width is tight.
///
/// Unlike a `LayoutBuilder` this keeps intrinsic sizing working, so parents that
/// measure intrinsics (e.g. the key-value grid) can still size the button.
class _TightWidthProbe extends SingleChildRenderObjectWidget {
  const _TightWidthProbe({required this.probe, required super.child});

  final _TightWidthState probe;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTightWidthProbe(probe);

  @override
  void updateRenderObject(BuildContext context, _RenderTightWidthProbe renderObject) => renderObject.probe = probe;
}

class _RenderTightWidthProbe extends RenderProxyBox {
  _RenderTightWidthProbe(this.probe);

  _TightWidthState probe;

  @override
  void performLayout() {
    probe.tight = constraints.hasTightWidth;
    super.performLayout();
  }
}

/// Forces its child to the available width when [probe] reports a tight width.
class _FillIfTight extends SingleChildRenderObjectWidget {
  const _FillIfTight({required this.probe, required super.child});

  final _TightWidthState probe;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFillIfTight(probe);

  @override
  void updateRenderObject(BuildContext context, _RenderFillIfTight renderObject) => renderObject.probe = probe;
}

class _RenderFillIfTight extends RenderProxyBox {
  _RenderFillIfTight(this.probe);

  _TightWidthState probe;

  BoxConstraints _childConstraints(BoxConstraints c) => probe.tight && c.hasBoundedWidth ? c.tighten(width: c.maxWidth) : c;

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = child.size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => child?.getDryLayout(_childConstraints(constraints)) ?? constraints.smallest;
}

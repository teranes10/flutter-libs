part of 'button.dart';

/// A group of connected buttons with shared styling.
///
/// `TButtonGroup` displays multiple buttons as a unified component with:
/// - Shared theme and styling
/// - Connected appearance (no gaps between buttons)
/// - Optional boxed mode with container
/// - Customizable alignment
/// - Individual button customization
/// - **Cycle Mode**: Show only one button at a time, cycling through items on tap.
/// - **Stateful Selection**: Maintain active state and highlight selected buttons when cycle is false.
///
/// ## Basic Usage
///
/// ```dart
/// TButtonGroup(
///   items: [
///     TButtonGroupItem(text: 'Left', onPressed: () {}),
///     TButtonGroupItem(text: 'Center', onPressed: () {}),
///     TButtonGroupItem(text: 'Right', onPressed: () {}),
///   ],
/// )
/// ```
///
/// ## Cycle Mode (Show Single Button & Cycle on Tap)
///
/// ```dart
/// TButtonGroup(
///   cycle: true,
///   onIndexChanged: (index) => print('Cycled to item $index'),
///   items: [
///     TButtonGroupItem(icon: HugeIcons.strokeRoundedPlay, text: 'Play'),
///     TButtonGroupItem(icon: HugeIcons.strokeRoundedPause, text: 'Pause'),
///     TButtonGroupItem(icon: HugeIcons.strokeRoundedStop, text: 'Stop'),
///   ],
/// )
/// ```
///
/// ## Stateful Selection Mode
///
/// ```dart
/// TButtonGroup(
///   initialIndex: 0,
///   onIndexChanged: (index) => print('Selected item $index'),
///   items: [
///     TButtonGroupItem(text: 'Option A'),
///     TButtonGroupItem(text: 'Option B'),
///     TButtonGroupItem(text: 'Option C'),
///   ],
/// )
/// ```
///
/// See also:
/// - [TButton] for individual buttons
/// - [TButtonGroupItem] for item configuration
class TButtonGroup extends StatefulWidget {
  /// Custom theme for the button group.
  final TButtonGroupTheme? theme;

  /// The visual style of the button group.
  final TButtonGroupType? type;

  /// The size of buttons in the group.
  final TButtonSize? size;

  /// The color scheme for the button group.
  final Color? color;

  /// The list of button items to display.
  final List<TButtonGroupItem> items;

  /// Alignment of the button group.
  final WrapAlignment alignment;

  /// Whether to show only one button at a time and cycle through the items on tap.
  final bool cycle;

  /// The initial index of the item to show when [cycle] is true, or the active item index when [cycle] is false.
  ///
  /// If provided, this enables stateful selection. If an item in [items] has `active` set to true, that item's index will take precedence.
  final int? initialIndex;

  /// Callback fired when the active index changes (triggered in both [cycle] mode and stateful selection mode).
  final ValueChanged<int>? onIndexChanged;

  /// Whether the buttons in the group are separated by a gap (not joined).
  final bool separated;

  /// Spacing between buttons when [separated] is true.
  final double? spacing;

  /// Whether to show a checkmark tick when a button is active.
  final bool? showTick;

  /// The alignment of the tick indicator.
  final Alignment? tickAlignment;

  /// Custom widget to display for the tick indicator.
  final Widget? tickWidget;

  /// Whether the buttons should expand to fill the available width evenly inside a Row.
  final bool expanded;

  /// Label text displayed above the button group.
  final String? label;

  /// Optional tag text next to the label.
  final String? tag;

  /// Whether this group selection is required.
  final bool isRequired;

  /// Helper text displayed below the group.
  final String? helperText;

  /// Informational tooltip text.
  final String? info;

  /// Creates a button group.
  const TButtonGroup({
    super.key,
    this.theme,
    this.type,
    this.color,
    this.size,
    this.items = const [],
    this.alignment = WrapAlignment.start,
    this.cycle = false,
    this.initialIndex,
    this.onIndexChanged,
    this.separated = false,
    this.spacing,
    this.showTick,
    this.tickAlignment,
    this.tickWidget,
    this.expanded = false,
    this.label,
    this.tag,
    this.isRequired = false,
    this.helperText,
    this.info,
  }) : assert(
          theme == null || (type == null && size == null && color == null),
          'If theme is provided, type, color and size must be null.',
        );

  @override
  State<TButtonGroup> createState() => _TButtonGroupState();
}

class _TButtonGroupState extends State<TButtonGroup> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _initIndex();
  }

  @override
  void didUpdateWidget(TButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex || widget.cycle != oldWidget.cycle || widget.items != oldWidget.items) {
      _initIndex();
    }
  }

  void _initIndex() {
    final activeIndex = widget.items.indexWhere((item) => item.active);
    if (activeIndex != -1) {
      _currentIndex = activeIndex;
    } else if (widget.cycle) {
      _currentIndex = (widget.initialIndex ?? 0).clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    } else if (widget.initialIndex != null) {
      _currentIndex = widget.initialIndex!.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    } else {
      _currentIndex = -1;
    }
  }

  void _advanceIndex() {
    if (widget.items.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.items.length;
    });
    widget.onIndexChanged?.call(_currentIndex);
  }

  void _updateIndex(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    widget.onIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ??
        TButtonGroupTheme.fromBaseTheme(
          context: context,
          type: widget.type ?? TButtonGroupType.solid,
          size: widget.size,
          color: widget.color,
        );

    Widget buttonGroup = _buildButtonRow(context, effectiveTheme);

    final glass = TGlassStyle.resolve(context);
    if (effectiveTheme.enableBoxedMode && glass != null && glass.isLiquid && effectiveTheme.type == TButtonGroupType.segmented) {
      // Liquid: the segmented track is a liquid pane rather than a flat frosted wash.
      final radius = (effectiveTheme.boxedDecoration?.borderRadius ?? BorderRadius.circular(12)).resolve(Directionality.of(context));
      buttonGroup = TGlassSurface.wrap(
        context,
        radius: radius,
        color: context.colors.surface,
        child: Padding(padding: effectiveTheme.boxedPadding ?? EdgeInsets.zero, child: buttonGroup),
      );
    } else if (effectiveTheme.enableBoxedMode) {
      buttonGroup = Container(
        padding: effectiveTheme.boxedPadding,
        decoration: effectiveTheme.boxedDecoration,
        child: buttonGroup,
      );
    }

    final inputTheme = context.theme.inputFieldTheme;
    final states = <WidgetState>{
      if (widget.isRequired) WidgetState.selected,
    };

    final labelWidget = TInputFieldTheme.buildDefaultLabelBuilder(
      inputTheme.labelStyle,
      inputTheme.tagStyle,
      inputTheme.errorTextStyle,
    ).resolve(states)(
      widget.label,
      widget.tag,
      widget.isRequired,
      widget.info != null ? inputTheme.buildInfoIcon(widget.info!, context.colors) : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.tag != null || widget.info != null) ...[
          labelWidget,
          const SizedBox(height: 8),
        ],
        buttonGroup,
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: inputTheme.helperTextStyle.resolve(states),
          ),
        ],
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context, TButtonGroupTheme groupTheme) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    if (widget.cycle) {
      final index = _currentIndex.clamp(0, widget.items.length - 1);
      final item = widget.items[index];
      final button = _buildButton(
        context,
        groupTheme: groupTheme,
        item: item,
        index: index,
        position: 0,
        total: 1,
      );
      return button;
    }

    // Items hidden by permission are dropped up front so separators and the
    // first/last rounding only consider what is actually shown.
    final visible = [
      for (int i = 0; i < widget.items.length; i++)
        if (!context.authResolve(widget.items[i].permission, target: TAuthTarget.button, onDenied: widget.items[i].onDenied).isHidden) i,
    ];
    if (visible.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    final total = visible.length;

    for (int p = 0; p < total; p++) {
      final i = visible[p];
      var button = _buildButton(context, groupTheme: groupTheme, item: widget.items[i], index: i, position: p, total: total);
      button = widget.items[i].wrap?.call(button) ?? button;

      children.add(button);

      if (!widget.separated && p < total - 1 && groupTheme.needsSeparator()) {
        children.add(groupTheme.buildSeparator());
      }
    }

    // Segmented groups keep one shared track but space the segments slightly apart.
    final segmentGap = groupTheme.type == TButtonGroupType.segmented && !widget.separated ? (widget.spacing ?? 4) : 0.0;

    if (widget.expanded) {
      final rowChildren = <Widget>[];
      for (int p = 0; p < children.length; p++) {
        rowChildren.add(Expanded(
            flex: groupTheme.type == TButtonGroupType.segmented ? 1 : widget.items[visible[p]].text?.length ?? 1, child: children[p]));
        if (p < total - 1) {
          if (widget.separated) {
            rowChildren.add(SizedBox(width: widget.spacing ?? 8));
          } else if (segmentGap > 0) {
            rowChildren.add(SizedBox(width: segmentGap));
          }
        }
      }
      return _glassJoined(
        context,
        groupTheme,
        visible,
        Row(mainAxisSize: MainAxisSize.max, children: rowChildren),
      );
    }

    if (widget.separated) {
      return Wrap(
        alignment: widget.alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: widget.spacing ?? 8,
        runSpacing: widget.spacing ?? 8,
        children: children,
      );
    }

    final row = Wrap(alignment: widget.alignment, crossAxisAlignment: WrapCrossAlignment.center, spacing: segmentGap, children: children);

    return _glassJoined(context, groupTheme, visible, row);
  }

  /// Glass: a joined group of bare icon buttons shares one glass pill (or the segmented track) instead of a pill per button.
  Widget _glassJoined(BuildContext context, TButtonGroupTheme groupTheme, List<int> visible, Widget row) {
    final allIconOnly = visible.every((i) {
      final it = widget.items[i];
      return it.icon != null && it.text.isNullOrBlank && it.child == null;
    });
    if (allIconOnly && TGlassStyle.resolve(context) != null) {
      // Segmented groups already have a glass track from the boxed wrapper, so only the scope is added.
      return _TButtonGlassScope(
        child: groupTheme.type == TButtonGroupType.segmented
            ? row
            : TGlassSurface.wrap(context, radius: BorderRadius.circular(999), color: context.colors.surface, child: row),
      );
    }
    return row;
  }

  Widget _buildButton(
    BuildContext context, {
    required TButtonGroupTheme groupTheme,
    required TButtonGroupItem item,
    required int index,
    required int position,
    required int total,
  }) {
    VoidCallback? onTap;
    Function(TButtonPressOptions)? onPressed;

    final isStateful = widget.cycle || widget.initialIndex != null || widget.onIndexChanged != null;

    if (widget.cycle) {
      onTap = () {
        if (item.onTap != null) {
          item.onTap!();
        }
        _advanceIndex();
      };

      if (item.onPressed != null) {
        onPressed = (options) {
          item.onPressed!(options);
          _advanceIndex();
        };
      }
    } else if (isStateful) {
      onTap = () {
        if (item.onTap != null) {
          item.onTap!();
        }
        _updateIndex(index);
      };

      if (item.onPressed != null) {
        onPressed = (options) {
          item.onPressed!(options);
          _updateIndex(index);
        };
      }
    } else {
      onTap = item.onTap;
      onPressed = item.onPressed;
    }

    final isActive = (isStateful && !widget.cycle) ? (index == _currentIndex) : item.active;

    TButton button = TButton(
      icon: item.icon,
      activeIcon: item.activeIcon,
      turns: item.turns,
      text: item.text,
      loading: item.loading,
      loadingText: item.loadingText,
      tooltip: item.tooltip,
      semanticIdentifier: item.semanticIdentifier,
      active: isActive,
      showTick: item.showTick ?? widget.showTick ?? false,
      tickAlignment: item.tickAlignment ?? widget.tickAlignment ?? Alignment.topRight,
      tickWidget: item.tickWidget ?? widget.tickWidget,
      badge: item.badge,
      badgeAlignment: item.badgeAlignment ?? Alignment.topRight,
      badgeColor: item.badgeColor,
      badgeTextColor: item.badgeTextColor,
      onTap: onTap,
      onPressed: onPressed,
      permission: item.permission,
      onDenied: item.onDenied,
      child: item.child,
    );

    final defaultTheme = context.theme.buttonTheme;
    // Separated filled-text buttons: only the active one keeps its background.
    final dropBackground =
        widget.separated && !isActive && (groupTheme.type == TButtonGroupType.filledText || groupTheme.type == TButtonGroupType.boxed);
    final hasSelection = !widget.cycle && (widget.items.any((i) => i.active) || (isStateful && _currentIndex >= 0));
    final effectiveButtonType = dropBackground ? TButtonType.text : groupTheme.type.buttonType;
    final buttonTheme = defaultTheme.copyWith(
      baseTheme: defaultTheme.baseTheme.rebuild(
        color: item.color ?? groupTheme.color,
        type: effectiveButtonType.colorType,
      ),
      size: widget.size ?? groupTheme.size,
      shape: groupTheme.shape,
    );

    if (groupTheme.type == TButtonGroupType.segmented) {
      final colors = context.colors;
      final glass = TGlassStyle.resolve(context);
      // Glass: the active pill is a bright frosted chip with a visible edge instead of an opaque raised surface.
      final liquid = glass != null && glass.isLiquid;
      final pillFill = liquid ? Colors.transparent : Colors.white.withAlpha(colors.isDarkMode ? 52 : 235);
      final activeBase = TWidgetTheme(
        isDarkMode: colors.isDarkMode,
        type: TVariant.tonal,
        color: colors.onSurface.toMaterial(),
        container: glass != null ? pillFill : colors.surface,
        containerVariant: glass != null ? pillFill : colors.surface,
        outline: liquid ? Colors.transparent : glass?.fieldEdge(context),
        outlineVariant: liquid ? Colors.transparent : glass?.fieldEdge(context),
        onContainer: colors.onSurface,
        onContainerVariant: colors.onSurface,
        shadow: glass != null ? null : colors.shadow,
      );
      final segTheme = defaultTheme.copyWith(
        baseTheme: isActive
            ? activeBase
            : TWidgetTheme.surfaceTheme(colors, variant: TVariant.text).copyWith(
                container: Colors.transparent,
                // Glass: hover is a light wash; the default hover colour is an opaque surface that shows as a dark block.
                containerVariant: glass != null ? colors.onSurface.withAlpha(colors.isDarkMode ? 28 : 20) : null,
              ),
        size: widget.size ?? groupTheme.size,
        shape: groupTheme.shape,
        elevation: isActive && glass == null ? 1 : 0,
      );
      final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(groupTheme.borderRadius));
      final segButton =
          button.copyWith(theme: segTheme.copyWith(buttonStyle: segTheme.buttonStyle.copyWith(shape: WidgetStateProperty.all(pill))));
      // Liquid: only the selected segment is a liquid glass pane; the others stay plain icons on the track.
      if (liquid) {
        return _TButtonGlassScope(
          child: isActive
              ? TGlassSurface.wrap(context, radius: BorderRadius.circular(groupTheme.borderRadius), color: colors.surface, child: segButton)
              : segButton,
        );
      }
      return segButton;
    }

    final emphasize = hasSelection && isActive && (groupTheme.type == TButtonGroupType.outline || groupTheme.type == TButtonGroupType.text);
    final dark = buttonTheme.baseTheme.isDarkMode;
    final accent = buttonTheme.baseTheme.color;
    final strongText = dark ? accent.shade(200) : accent.shade(700);
    final strongBorder = dark ? accent.shade(300) : accent.shade(600);
    // Active button keeps the group variant; it only moves to the theme's variant colours (a mid-level step, not a type change).
    final deepen = hasSelection && isActive && (groupTheme.type == TButtonGroupType.solid || groupTheme.type == TButtonGroupType.tonal);
    final themed = deepen
        ? buttonTheme.copyWith(
            baseTheme: buttonTheme.baseTheme.copyWith(
              container: buttonTheme.baseTheme.containerVariant,
              onContainer: buttonTheme.baseTheme.onContainerVariant,
            ),
          )
        : !emphasize
            ? buttonTheme
            : buttonTheme.copyWith(
                baseTheme: buttonTheme.baseTheme.copyWith(
                  onContainer: strongText,
                  onContainerVariant: strongText,
                  // Only the outline group gets a (bolder) border; text mode stays borderless.
                  outline: groupTheme.type == TButtonGroupType.outline ? strongBorder : null,
                  outlineVariant: groupTheme.type == TButtonGroupType.outline ? strongBorder : null,
                ),
              );
    final emphasizedStyle = !emphasize
        ? themed.buttonStyle
        : themed.buttonStyle.copyWith(
            side: groupTheme.type == TButtonGroupType.outline ? WidgetStateProperty.all(BorderSide(color: strongBorder, width: 1.5)) : null,
            textStyle: WidgetStateProperty.all(TextStyle(fontSize: themed.size.font, fontWeight: FontWeight.w700, letterSpacing: 0.65)),
          );

    final isSingle = total == 1 || widget.separated;
    if (isSingle) {
      return button.copyWith(theme: themed.copyWith(buttonStyle: emphasizedStyle));
    }

    final isFirst = position == 0;
    final isLast = position == total - 1;
    final borderRadius = groupTheme.borderRadius;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? borderRadius : 0),
        bottomLeft: Radius.circular(isFirst ? borderRadius : 0),
        topRight: Radius.circular(isLast ? borderRadius : 0),
        bottomRight: Radius.circular(isLast ? borderRadius : 0),
      ),
    );

    return button.copyWith(
      theme: themed.copyWith(
        buttonStyle: emphasizedStyle.copyWith(shape: WidgetStateProperty.all(shape)),
      ),
    );
  }
}

/// Tells descendant icon [TButton]s not to paint their own glass surface (the enclosing group already does).
class _TButtonGlassScope extends InheritedWidget {
  const _TButtonGlassScope({required super.child});

  @override
  bool updateShouldNotify(_TButtonGlassScope oldWidget) => false;
}

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
///     TButtonGroupItem(icon: Icons.play_arrow, text: 'Play'),
///     TButtonGroupItem(icon: Icons.pause, text: 'Pause'),
///     TButtonGroupItem(icon: Icons.stop, text: 'Stop'),
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

    if (effectiveTheme.enableBoxedMode) {
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
        total: 1,
      );
      return button;
    }

    final children = <Widget>[];
    final total = widget.items.length;

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final button = _buildButton(context, groupTheme: groupTheme, item: item, index: i, total: total);

      children.add(button);

      if (!widget.separated && i < total - 1 && groupTheme.needsSeparator()) {
        children.add(groupTheme.buildSeparator());
      }
    }

    if (widget.expanded) {
      final total = widget.items.length;
      final rowChildren = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        rowChildren.add(Expanded(flex: widget.items[i].text?.length ?? 1, child: children[i]));
        if (widget.separated && i < total - 1) {
          rowChildren.add(SizedBox(width: widget.spacing ?? 8));
        }
      }
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: rowChildren,
      );
    }

    if (widget.separated) {
      return Wrap(
        alignment: widget.alignment,
        spacing: widget.spacing ?? 8,
        runSpacing: widget.spacing ?? 8,
        children: children,
      );
    }

    return Wrap(alignment: widget.alignment, children: children);
  }

  Widget _buildButton(
    BuildContext context, {
    required TButtonGroupTheme groupTheme,
    required TButtonGroupItem item,
    required int index,
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
      text: item.text,
      loading: item.loading,
      loadingText: item.loadingText,
      tooltip: item.tooltip,
      active: isActive,
      showTick: item.showTick ?? widget.showTick ?? false,
      tickAlignment: item.tickAlignment ?? widget.tickAlignment ?? Alignment.topRight,
      tickWidget: item.tickWidget ?? widget.tickWidget,
      onTap: onTap,
      onPressed: onPressed,
      child: item.child,
    );

    final defaultTheme = context.theme.buttonTheme;
    final buttonTheme = defaultTheme.copyWith(
      baseTheme: defaultTheme.baseTheme.rebuild(
        color: item.color ?? groupTheme.color,
        type: groupTheme.type.buttonType.colorType,
      ),
      size: widget.size,
      shape: groupTheme.shape,
    );

    final isSingle = total == 1 || widget.separated;
    if (isSingle) {
      return button.copyWith(theme: buttonTheme);
    }

    final isFirst = index == 0;
    final isLast = index == total - 1;
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
      theme: buttonTheme.copyWith(
        buttonStyle: buttonTheme.buttonStyle.copyWith(shape: WidgetStateProperty.all(shape)),
      ),
    );
  }
}

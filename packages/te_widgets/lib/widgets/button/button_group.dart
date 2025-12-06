part of 'button.dart';

/// A group of connected buttons with shared styling.
///
/// `TButtonGroup` displays multiple buttons as a unified component with:
/// - Shared theme and styling
/// - Connected appearance (no gaps between buttons)
/// - Optional boxed mode with container
/// - Customizable alignment
/// - Individual button customization
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
/// ## With Icons
///
/// ```dart
/// TButtonGroup(
///   type: TButtonGroupType.outline,
///   items: [
///     TButtonGroupItem(icon: Icons.format_bold, onPressed: () {}),
///     TButtonGroupItem(icon: Icons.format_italic, onPressed: () {}),
///     TButtonGroupItem(icon: Icons.format_underlined, onPressed: () {}),
///   ],
/// )
/// ```
///
/// See also:
/// - [TButton] for individual buttons
/// - [TButtonGroupItem] for item configuration
class TButtonGroup extends StatelessWidget {
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

  /// Creates a button group.
  const TButtonGroup({
    super.key,
    this.theme,
    this.type,
    this.color,
    this.size,
    this.items = const [],
    this.alignment = WrapAlignment.start,
  }) : assert(
          theme == null || (type == null && size == null && color == null),
          'If theme is provided, type, color and size must be null.',
        );

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ??
        TButtonGroupTheme.fromBaseTheme(
          context: context,
          type: type ?? TButtonGroupType.solid,
          size: size,
          color: color,
        );

    Widget buttonGroup = _buildButtonRow(context, effectiveTheme);

    if (effectiveTheme.enableBoxedMode) {
      buttonGroup = Container(
        padding: effectiveTheme.boxedPadding,
        decoration: effectiveTheme.boxedDecoration,
        child: buttonGroup,
      );
    }

    return buttonGroup;
  }

  Widget _buildButtonRow(BuildContext context, TButtonGroupTheme groupTheme) {
    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    final total = items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final button = _buildButton(context, groupTheme: groupTheme, item: item, index: i, total: total);

      children.add(button);

      if (i < total - 1 && groupTheme.needsSeparator()) {
        children.add(groupTheme.buildSeparator());
      }
    }

    return Wrap(alignment: alignment, children: children);
  }

  Widget _buildButton(
    BuildContext context, {
    required TButtonGroupTheme groupTheme,
    required TButtonGroupItem item,
    required int index,
    required int total,
  }) {
    TButton button = TButton(
      icon: item.icon,
      text: item.text,
      loading: item.loading,
      loadingText: item.loadingText,
      tooltip: item.tooltip,
      active: item.active,
      onTap: item.onTap,
      onPressed: item.onPressed,
      child: item.child,
    );

    final defaultTheme = context.theme.buttonTheme;
    final buttonTheme = defaultTheme.copyWith(
      baseTheme: defaultTheme.baseTheme.rebuild(
        color: item.color ?? groupTheme.color,
        type: groupTheme.type.buttonType.colorType,
      ),
      size: size,
    );

    final isSingle = total == 1;
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

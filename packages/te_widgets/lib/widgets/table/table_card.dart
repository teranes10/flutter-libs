part of 'table.dart';

class TTableCard<T> extends StatelessWidget {
  final T item;
  final List<TTableHeader<T>> headers;
  final TCardStyle style;
  final double? width;

  //expandable
  final bool expandable;
  final bool isExpanded;
  final VoidCallback? onExpansionChanged;
  final Widget? expandedContent;

  //selectable
  final bool selectable;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const TTableCard({
    super.key,
    required this.item,
    required this.headers,
    this.style = const TCardStyle(),
    this.width,

    //expandable
    this.expandable = false,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.expandedContent,

    //selectable
    this.selectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: width,
      margin: style.margin,
      child: Material(
        elevation: style.elevation,
        borderRadius: style.borderRadius,
        color: style.getBackgroundColor(theme, isSelected),
        child: Container(
          decoration: BoxDecoration(borderRadius: style.borderRadius, border: style.getBorder(theme, isSelected)),
          child: Column(
            children: [
              Stack(
                children: [
                  if (selectable)
                    Positioned(
                        top: 5,
                        left: 5,
                        child: TCheckbox(
                          value: isSelected,
                          onValueChanged: (value) => onSelectionChanged?.call(),
                        )),
                  _buildMainContent(theme),
                  if (expandable) Positioned(bottom: 3, right: 5, child: _buildExpandButton(theme, isExpanded, onExpansionChanged)),
                ],
              ),
              if (isExpanded && expandedContent != null) ...[
                Padding(
                  padding: EdgeInsets.only(
                    left: style.padding.left + (selectable ? 6 : 0),
                    right: style.padding.right,
                    bottom: style.padding.bottom,
                  ),
                  child: expandedContent!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ColorScheme theme) {
    final values = TKeyValue.mapHeaders(headers, item);
    return Padding(
      padding: EdgeInsets.only(
        top: style.padding.top + (selectable ? 3 : 0),
        left: (style.padding.left) + (selectable ? 6 : 0),
        right: (style.padding.right),
        bottom: (style.padding.bottom),
      ),
      child: TKeyValueSection(values: values),
    );
  }

  static Widget _buildExpandButton(ColorScheme theme, bool isExpanded, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.onSurfaceVariant),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Helper class for rendering tab widgets with consistent styling.
class TabRenderer<T> {
  /// Builds a default tab widget with standard styling.
  static Widget buildDefaultTab<T>({
    required BuildContext context,
    required TTab<T> tab,
    required bool isSelected,
    required ColorScheme colors,
    required GlobalKey tabKey,
    required Axis axis,
    EdgeInsets? tabPadding,
    required double? indicatorWidth,
    Color? selectedColor,
    Color? unselectedColor,
    Color? disabledColor,
    Color? indicatorColor,
    Color? baselineColor,
    FontWeight? selectedFontWeight,
    TTabController<T>? controller,
    VoidCallback? onTab,
    TTabStyle style = TTabStyle.underline,
  }) {
    if (style == TTabStyle.segmented) {
      return _buildSegmentedTab<T>(
        context: context,
        tab: tab,
        isSelected: isSelected,
        colors: colors,
        tabKey: tabKey,
        tabPadding: tabPadding,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        disabledColor: disabledColor,
        onTab: onTab,
      );
    }
    final defaultSelectedColor = selectedColor ?? colors.onPrimaryContainer;
    final defaultUnselectedColor = unselectedColor ?? colors.onSurface;
    final defaultDisabledColor = disabledColor ?? colors.onSurfaceVariant;
    final danger = context.theme.danger;
    final defaultIndicatorColor = tab.hasError ? danger : (indicatorColor ?? colors.primary);

    final color = !tab.isEnabled
        ? defaultDisabledColor
        : tab.hasError
            ? danger
            : (isSelected ? defaultSelectedColor : defaultUnselectedColor);

    final effectiveIndicatorWidth = indicatorWidth ?? 1;
    final indicatorBorder = isSelected
        ? (axis == Axis.horizontal
            ? Border(bottom: BorderSide(color: defaultIndicatorColor, width: effectiveIndicatorWidth))
            : Border(right: BorderSide(color: defaultIndicatorColor, width: effectiveIndicatorWidth)))
        : (axis == Axis.horizontal
            ? Border(bottom: BorderSide(color: baselineColor ?? Colors.transparent, width: effectiveIndicatorWidth))
            : Border(right: BorderSide(color: baselineColor ?? Colors.transparent, width: effectiveIndicatorWidth)));

    // For vertical tabs on mobile, show only icons to prevent overflow unless icon is null
    final isMobile = context.isMobile;
    final showTextInVertical = axis == Axis.horizontal || !isMobile || tab.icon == null;

    final content = axis == Axis.horizontal
        ? _buildHorizontalTabContent(
            tab: tab,
            color: color,
            isSelected: isSelected,
            defaultIndicatorColor: defaultIndicatorColor,
            colors: colors,
            selectedFontWeight: selectedFontWeight,
          )
        : _buildVerticalTabContent(
            tab: tab,
            color: color,
            isSelected: isSelected,
            defaultIndicatorColor: defaultIndicatorColor,
            showText: showTextInVertical,
            selectedFontWeight: selectedFontWeight,
          );

    return Container(
      key: tabKey,
      decoration: BoxDecoration(border: indicatorBorder),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTab,
          child: Container(
              // Touch-friendly: horizontal tabs are at least 48dp tall on mobile.
              constraints: BoxConstraints(minHeight: axis == Axis.horizontal && isMobile ? 48 : 0),
              alignment: axis == Axis.vertical
                  ? (showTextInVertical ? Alignment.centerLeft : Alignment.center)
                  : (isMobile ? Alignment.center : null),
              padding: tabPadding ??
                  (axis == Axis.horizontal
                      ? const EdgeInsets.symmetric(vertical: 6, horizontal: 8)
                      : const EdgeInsets.symmetric(vertical: 4, horizontal: 8)),
              child: content),
        ),
      ),
    );
  }

  static Widget _buildSegmentedTab<T>({
    required BuildContext context,
    required TTab<T> tab,
    required bool isSelected,
    required ColorScheme colors,
    required GlobalKey tabKey,
    EdgeInsets? tabPadding,
    Color? selectedColor,
    Color? unselectedColor,
    Color? disabledColor,
    VoidCallback? onTab,
  }) {
    final color = !tab.isEnabled
        ? (disabledColor ?? colors.onSurfaceVariant.o(0.5))
        : tab.hasError
            ? context.theme.danger
            : isSelected
            ? (selectedColor ?? colors.onSurface)
            : (unselectedColor ?? colors.onSurfaceVariant);
    final radius = BorderRadius.circular(8);
    final glass = TGlassStyle.resolve(context);

    final liquid = glass?.isLiquid == true;
    final dark = colors.isDarkMode;
    final pill = Container(
      key: tabKey,
      decoration: glass != null
          // Glass: the active pill is a bright frosted chip with a visible edge instead of an opaque raised surface.
          ? BoxDecoration(
              color: isSelected && !liquid ? Colors.white.withAlpha(dark ? 52 : 235) : Colors.transparent,
              // Liquid: a raised, lit lens: top-to-bottom sheen, soft drop shadow and the rim below instead of a flat edge.
              gradient: isSelected && liquid
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withAlpha(dark ? 78 : 255), Colors.white.withAlpha(dark ? 34 : 190)],
                    )
                  : null,
              boxShadow: isSelected && liquid
                  ? [BoxShadow(color: Colors.black.withAlpha(dark ? 50 : 28), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
              borderRadius: radius,
              border: isSelected && !liquid ? Border.all(color: glass.fieldEdge(context)) : null,
            )
          : BoxDecoration(
              color: isSelected ? colors.surface : Colors.transparent,
              borderRadius: radius,
              boxShadow: isSelected ? [BoxShadow(color: colors.shadow.o(0.12), blurRadius: 3, offset: const Offset(0, 1))] : null,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTab,
          borderRadius: radius,
          child: Container(
            constraints: BoxConstraints(minHeight: context.isMobile ? 40 : 0),
            alignment: Alignment.center,
            padding: tabPadding ?? const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
            child: _buildHorizontalTabContent(
              tab: tab,
              color: color,
              isSelected: isSelected,
              defaultIndicatorColor: colors.primary,
              colors: colors,
            ),
          ),
        ),
      ),
    );
    return isSelected ? TGlassRim(borderRadius: radius, child: pill) : pill;
  }

  /// Builds horizontal tab content layout.
  static Widget _buildHorizontalTabContent<T>({
    required TTab<T> tab,
    required Color color,
    required bool isSelected,
    required Color defaultIndicatorColor,
    required ColorScheme colors,
    FontWeight? selectedFontWeight,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (tab.icon != null) ...[
          TIcon.raw(tab.icon, size: 16, color: color),
          if (tab.text != null) const SizedBox(width: 8),
        ],
        if (tab.text != null)
          Text(
            tab.text!,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isSelected ? (selectedFontWeight ?? FontWeight.w400) : FontWeight.w300,
            ),
          ),
        if (tab.count != null)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${tab.count}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ),
        if (tab.isActive)
          Container(
            margin: const EdgeInsets.only(left: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: defaultIndicatorColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  /// Builds vertical tab content layout.
  static Widget _buildVerticalTabContent<T>({
    required TTab<T> tab,
    required Color color,
    required bool isSelected,
    required Color defaultIndicatorColor,
    required bool showText,
    FontWeight? selectedFontWeight,
  }) {
    return Column(
      crossAxisAlignment: showText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (tab.icon != null) ...[
          TIcon.raw(tab.icon, size: 16, color: color),
          if (tab.text != null && showText) const SizedBox(height: 4),
        ],
        if (tab.text != null && showText)
          Text(
            tab.text!,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isSelected ? (selectedFontWeight ?? FontWeight.w400) : FontWeight.w300,
            ),
          ),
        if (tab.isActive)
          Container(
            margin: EdgeInsets.only(top: showText ? 4 : 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: defaultIndicatorColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

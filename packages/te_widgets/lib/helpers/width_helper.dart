import 'package:flutter/widgets.dart';
import 'package:te_widgets/te_widgets.dart';

class WidthHelper {
  static double? resolveWidth(BuildContext ctx, Object? action) {
    if (action == null) return null;
    return switch (action) {
      SizedBox s => s.width,
      ConstrainedBox cb => cb.constraints.resolvedWidth,
      Container c => c.constraints?.resolvedWidth ?? (c.child != null ? resolveWidth(ctx, c.child!) : null),
      BoxConstraints c => c.resolvedWidth,
      Padding p => (p.child != null ? (resolveWidth(ctx, p.child!) ?? 0) : 0.0) + p.padding.horizontal,
      Flexible f => resolveWidth(ctx, f.child),
      Row r => r.children.fold<double>(0.0, (double sum, child) => sum + (resolveWidth(ctx, child) ?? 0.0)),
      TButton b => b.estimateWidth(ctx),
      TCheckbox cb => cb.estimateWidth(ctx),
      TSwitch s => s.estimateWidth(ctx),
      TChip c => c.estimateWidth(ctx),
      TImage i => i.estimateWidth(ctx),
      TTabs t => t.estimateWidth(ctx),
      TTextField tf => tf.estimateWidth(ctx),
      TButtonGroup bg => bg.estimateWidth(ctx),
      TDropdown d => resolveWidth(ctx, d.child),
      _ => null,
    };
  }

  /// Measures the width of a string with the given style and context.
  static double measureText(BuildContext context, String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return textPainter.width;
  }
}

extension TButtonWidthX on TButton {
  /// Estimates the width of the button based on its content and size settings.
  double estimateWidth(BuildContext ctx) {
    final defaultTheme = ctx.theme.buttonTheme;
    final sizeData = size ?? theme?.size ?? defaultTheme.size;
    final shapeData = shape ?? theme?.shape ?? defaultTheme.shape;
    final baseTheme = theme?.baseTheme ?? 
        defaultTheme.baseTheme.rebuild(color: active ? (activeColor ?? color) : color, type: type?.colorType);

    // If it's a block button, it takes full width normally
    if (sizeData.minW.isInfinite && size == TButtonSize.block) return double.infinity;

    // If it's a circle, width = height (minH)
    if (shapeData == TButtonShape.circle) {
      return sizeData.minH;
    }

    double width = 0;

    // Base horizontal padding (left + right)
    width += sizeData.hPad * 2;

    // Check for icon/imageUrl
    final hasIcon = (active ? (activeIcon ?? icon) : icon) != null || imageUrl != null;

    // Check for text (use loadingText if loading is true)
    final buttonText = loading ? loadingText : text;
    final hasText = !buttonText.isNullOrBlank;

    final textStyle = TextStyle(
      fontSize: sizeData.font,
      fontWeight: baseTheme.type.fontWeight,
      letterSpacing: 0.65,
    );

    if (shapeData == TButtonShape.tile) {
      // Tile shape is a Column: width is max of (icon size) and (text width)
      double iconWidth = hasIcon ? sizeData.icon : 0;
      double textWidth = hasText ? WidthHelper.measureText(ctx, buttonText!, textStyle) : 0;
      width += (iconWidth > textWidth ? iconWidth : textWidth);
    } else {
      // Normal Row layout
      if (hasIcon) {
        width += sizeData.icon;
        if (hasText) {
          width += sizeData.spacing;
        }
      }

      if (hasText) {
        width += WidthHelper.measureText(ctx, buttonText!, textStyle);
      }
    }

    // Add child width if present
    if (child != null) {
      width += 24.0;
    }

    // Add a small buffer (4.0) to account for Material button's internal margins/rendering
    width += 4.0;

    // Clamp between minWidth and infinity
    final minW = sizeData.minW.isInfinite ? 38.0 : sizeData.minW;
    return width.clamp(minW, double.infinity);
  }
}

extension TCheckboxWidthX on TCheckbox {
  double estimateWidth(BuildContext context) {
    double width = 32.0; // Base checkbox container size
    if (label != null) {
      width += 8.0; // Gap between checkbox and label
      width += WidthHelper.measureText(context, label!, TextStyle(fontSize: size.fontSize, letterSpacing: 0.9));
    }
    return width;
  }
}

extension TChipWidthX on TChip {
  double estimateWidth(BuildContext context) {
    // Default horizontal padding is 10*2 = 20
    double width = (padding?.horizontal ?? 20.0);

    if (icon != null) {
      width += 16.0; // Icon size
      if (text != null) width += 4.0; // Spacing
    }

    if (text != null) {
      width += WidthHelper.measureText(context, text!, const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400));
    }
    return width;
  }
}

extension TImageWidthX on TImage {
  double estimateWidth(BuildContext context) {
    double width = size;
    if (!title.isNullOrBlank || !subTitle.isNullOrBlank) {
      width += 7.5; // Spacing between image and text column
      double textWidth = 0;
      if (!title.isNullOrBlank) {
        textWidth = WidthHelper.measureText(context, title!, const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400));
      }
      if (!subTitle.isNullOrBlank) {
        double subWidth = WidthHelper.measureText(context, subTitle!, const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w300));
        if (subWidth > textWidth) textWidth = subWidth;
      }
      width += textWidth;
    }
    return width;
  }
}

extension TSwitchWidthX on TSwitch {
  double estimateWidth(BuildContext context) {
    double width = switch (size) {
      TInputSize.xs => 26.0,
      TInputSize.sm => 36.0,
      TInputSize.md || null => 42.0,
      TInputSize.lg => 52.0,
    };
    if (label != null) {
      width += 8.0; // Gap between switch and label
      width += WidthHelper.measureText(context, label!, TextStyle(fontSize: size.fontSize, letterSpacing: 0.9));
    }
    return width;
  }
}

extension TTabsWidthX on TTabs {
  double estimateWidth(BuildContext context) {
    if (tabs.isEmpty) return 0;

    double totalWidth = 0;
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      double tabWidth = 0;

      // TabRenderer uses horizontal: 8 by default
      final padding = tabPadding?.horizontal ?? 16.0;
      tabWidth += padding;

      if (tab.icon != null) {
        tabWidth += 16.0; // Renderer uses size 16
        if (tab.text != null) tabWidth += 8.0; // Renderer uses spacing 8
      }

      if (tab.text != null) {
        tabWidth += WidthHelper.measureText(
          context,
          tab.text!,
          const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400),
        );
      }

      if (tab.isActive) {
        tabWidth += 10.0; // 6 dot + 4 margin
      }

      totalWidth += tabWidth;
      if (i < tabs.length - 1) {
        totalWidth += tabSpacing;
      }
    }

    return totalWidth;
  }
}

extension TTextFieldWidthX on TTextField {
  double estimateWidth(BuildContext context) {
    final themeSize = theme?.size ?? size ?? context.theme.textFieldTheme.size;
    double base = switch (themeSize) {
      TInputSize.xs => 150.0,
      TInputSize.sm => 200.0,
      _ => 250.0,
    };
    if (postWidget != null) base += 32.0;
    if (preWidget != null) base += 32.0;
    return base;
  }
}

extension TButtonGroupWidthX on TButtonGroup {
  double estimateWidth(BuildContext context) {
    if (items.isEmpty) return 0;
    if (cycle) {
      double maxItemWidth = 0;
      for (final item in items) {
        final btn = TButton(icon: item.icon, text: item.text, size: size);
        final w = btn.estimateWidth(context);
        if (w > maxItemWidth) maxItemWidth = w;
      }
      return maxItemWidth;
    }

    double totalWidth = 0;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final btn = TButton(icon: item.icon, text: item.text, size: size);
      totalWidth += btn.estimateWidth(context);
    }
    return totalWidth;
  }
}

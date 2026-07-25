import 'dart:typed_data';
import 'package:flutter/material.dart' as fm;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:te_widgets/te_widgets.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Helper for converting Flutter widgets to PDF widgets.
class TPdfWidgetHelper {
  /// Pre-fetches images from network or assets for a list of items and headers.
  static Future<Map<String, Uint8List>> preCacheImages<T, K>(
    fm.BuildContext context,
    List<TTableHeader<T, K>> headers,
    List<T> items,
  ) async {
    final Map<String, Uint8List> cache = {};
    final effectiveHeaders = headers.where((h) => h.builder != null).toList();

    for (int i = 0; i < items.length; i++) {
      for (final header in effectiveHeaders) {
        try {
          final listItem = TListItem<T, K>(key: i as dynamic, data: items[i]);
          final widget = header.builder!(context, listItem, i);

          if (widget is TImage) {
            // Cache network image
            if (widget.url != null && !cache.containsKey(widget.url)) {
              try {
                final file = await DefaultCacheManager().getSingleFile(widget.url!);
                final bytes = await file.readAsBytes();
                if (bytes.isNotEmpty) {
                  cache[widget.url!] = bytes;
                }
              } catch (_) {
                // If network fails, we'll try to fallback to placeholder in convert()
              }
            }

            // Cache placeholder asset
            if (!cache.containsKey(widget.placeholder)) {
              try {
                final assetPath = _getAssetPath(widget.placeholder);
                final ByteData data = await rootBundle.load(assetPath);
                cache[widget.placeholder] = data.buffer.asUint8List();
              } catch (_) {
                // Skip failing assets
              }
            }
          }
        } catch (_) {
          // Skip failing items
        }
      }
    }
    return cache;
  }

  /// Converts supported Flutter widgets (like [TImage], [TChip]) to their PDF equivalents.
  static pw.Widget convert(fm.Widget widget, fm.ColorScheme colors, {Map<String, Uint8List>? imageCache}) {
    if (widget is TImage) {
      return _convertTImage(colors, widget, imageCache: imageCache);
    } else if (widget is TChip) {
      return _convertTChip(colors, widget);
    } else if (widget is TRating) {
      return _convertTRating(colors, widget);
    }

    // Fallback for unknown widgets
    return pw.SizedBox();
  }

  static String _getAssetPath(String path) {
    if (path.startsWith('package:')) {
      final parts = path.substring(8).split('/');
      final package = parts.first;
      final asset = parts.sublist(1).join('/');
      return 'packages/$package/$asset';
    }
    return path;
  }

  static pw.Widget _convertTImage(fm.ColorScheme colors, TImage widget, {Map<String, Uint8List>? imageCache}) {
    final borderRadius = widget.border is fm.RoundedRectangleBorder
        ? (widget.border as fm.RoundedRectangleBorder).borderRadius.resolve(fm.TextDirection.ltr)
        : fm.BorderRadius.zero;

    final imageSize = widget.size / 2;
    pw.Widget? imageWidget;

    // Try network image first
    if (widget.url != null && imageCache != null && imageCache.containsKey(widget.url)) {
      final bytes = imageCache[widget.url];
      if (bytes != null && bytes.isNotEmpty) {
        imageWidget = pw.Image(
          pw.MemoryImage(bytes),
          width: imageSize,
          height: imageSize / widget.aspectRatio,
          fit: pw.BoxFit.cover,
        );
      }
    }

    // Fallback to placeholder asset if network image fails or is missing
    if (imageWidget == null && imageCache != null && imageCache.containsKey(widget.placeholder)) {
      final bytes = imageCache[widget.placeholder];
      if (bytes != null && bytes.isNotEmpty) {
        imageWidget = pw.Image(
          pw.MemoryImage(bytes),
          width: imageSize,
          height: imageSize / widget.aspectRatio,
          fit: pw.BoxFit.contain,
        );
      }
    }

    final imageFrame = pw.Container(
      width: imageSize,
      height: imageSize / widget.aspectRatio,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: widget.color?.toPdfColor() ?? colors.surfaceContainerLow.toPdfColor(),
        shape: widget.border is fm.CircleBorder ? pw.BoxShape.circle : pw.BoxShape.rectangle,
        borderRadius:
            widget.border is fm.RoundedRectangleBorder ? pw.BorderRadius.all(pw.Radius.circular(borderRadius.topLeft.x / 2)) : null,
        border: imageWidget == null ? pw.Border.all(color: colors.outlineVariant.toPdfColor(), width: 0.5) : null,
      ),
      child: imageWidget ??
          pw.Center(
            child: pw.Text(
              widget.url == null ? "NO URL" : "NO IMG",
              style: pw.TextStyle(
                fontSize: 5,
                color: colors.onSurfaceVariant.toPdfColor(),
              ),
            ),
          ),
    );

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        imageFrame,
        if (widget.title != null || widget.subTitle != null) ...[
          pw.SizedBox(width: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (widget.title != null)
                pw.Text(
                  widget.title!,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: widget.titleColor?.toPdfColor() ?? colors.onSurface.toPdfColor(),
                  ),
                ),
              if (widget.subTitle != null)
                pw.Text(
                  widget.subTitle!,
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: widget.subTitleColor?.toPdfColor() ?? colors.onSurfaceVariant.toPdfColor(),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _convertTChip(fm.ColorScheme colors, TChip widget) {
    final mColor = widget.color ?? colors.primary;
    final isOutline = widget.type == TVariant.outline || widget.type == TVariant.softOutline || widget.type == TVariant.filledOutline;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: isOutline ? null : (widget.background ?? mColor.withAlpha(51)).toPdfColor(),
        borderRadius: pw.BorderRadius.circular(4),
        border: isOutline ? pw.Border.all(color: mColor.toPdfColor(), width: 0.5) : null,
      ),
      child: pw.Text(
        widget.text ?? '',
        style: pw.TextStyle(
          color: (widget.textColor ?? (isOutline ? mColor : colors.onPrimaryContainer)).toPdfColor(),
          fontSize: 8,
        ),
      ),
    );
  }

  static pw.Widget _convertTRating(fm.ColorScheme colors, TRating widget) {
    final ratedColor = (widget.color ?? fm.Colors.amber).toPdfColor();
    final unratedColor = (widget.unratedColor ?? colors.surfaceContainerHighest).toPdfColor();
    final currentValue = widget.value ?? 0.0;

    String toHex(dynamic color) {
      final r = (color.red * 255).toInt().toRadixString(16).padLeft(2, '0');
      final g = (color.green * 255).toInt().toRadixString(16).padLeft(2, '0');
      final b = (color.blue * 255).toInt().toRadixString(16).padLeft(2, '0');
      return '#$r$g$b';
    }

    final starWidgets = <pw.Widget>[];

    for (int i = 0; i < widget.itemCount; i++) {
      final ratingValue = i + 1.0;
      final isRated = currentValue >= ratingValue;
      final isHalfRated = !isRated && currentValue >= (ratingValue - 0.5) && widget.allowHalfRating;

      final color = (isRated || isHalfRated) ? ratedColor : unratedColor;
      final colorHex = toHex(color);

      String svgPath;
      if (isRated) {
        svgPath = '<path fill="$colorHex" d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>';
      } else if (isHalfRated) {
        svgPath =
            '<path fill="$colorHex" d="M22 9.24l-7.19-.62L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.63-7.03L22 9.24zM12 15.4V6.1l1.71 4.04 4.38.38-3.32 2.88 1 4.28L12 15.4z"/>';
      } else {
        svgPath =
            '<path fill="$colorHex" d="M22 9.24l-7.19-.62L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.63-7.03L22 9.24zM12 15.4l-3.76 2.27 1-4.28-3.32-2.88 4.38-.38L12 6.1l1.71 4.04 4.38.38-3.32 2.88 1 4.28L12 15.4z"/>';
      }

      final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">$svgPath</svg>';

      starWidgets.add(
        pw.Container(
          width: widget.itemSize * 0.65,
          height: widget.itemSize * 0.65,
          child: pw.SvgImage(svg: svg),
        ),
      );
    }

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        for (int i = 0; i < starWidgets.length; i++) ...[
          if (i > 0) pw.SizedBox(width: widget.spacing > 0 ? widget.spacing * 0.3 : 0.3),
          starWidgets[i],
        ]
      ],
    );
  }
}

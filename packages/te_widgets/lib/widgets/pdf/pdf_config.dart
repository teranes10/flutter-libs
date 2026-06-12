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
}

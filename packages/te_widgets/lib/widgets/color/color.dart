import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A widget for displaying a visual color swatch along with its hex code or label.
class TColor extends StatelessWidget {
  final String? hex;
  final Color? color;
  final String? label;
  final double size;
  final bool showHexLabel;

  const TColor({
    super.key,
    this.hex,
    this.color,
    this.label,
    this.size = 16,
    this.showHexLabel = true,
  });

  /// Safely parses a hex color string into a Flutter [Color].
  static Color? parseHex(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) return null;
    try {
      var cleanHex = hexString.trim().replaceFirst('#', '');
      if (cleanHex.startsWith('0x') || cleanHex.startsWith('0X')) {
        cleanHex = cleanHex.substring(2);
      }
      if (cleanHex.length == 3) {
        cleanHex = cleanHex.split('').map((c) => '$c$c').join();
      }
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final parsedColor = color ?? parseHex(hex);
    final displayText = label ?? (hex != null && hex!.isNotEmpty ? (hex!.startsWith('#') ? hex : '#$hex') : null);

    if (parsedColor == null && displayText == null) {
      return Text('-', style: TextStyle(color: colors.onSurface.withAlpha(128)));
    }

    final isDark = parsedColor != null && (parsedColor.computeLuminance() < 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: parsedColor != null ? parsedColor.withAlpha(25) : colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: parsedColor != null ? parsedColor.withAlpha(75) : colors.outline.withAlpha(75),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (parsedColor != null) ...[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: parsedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(100) : Colors.black.withAlpha(50),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: parsedColor.withAlpha(75),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (displayText != null && showHexLabel) const SizedBox(width: 8),
          ],
          if (displayText != null && showHexLabel)
            Text(
              displayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}

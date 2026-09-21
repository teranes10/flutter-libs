import 'package:te_widgets/te_widgets.dart';

/// Predefined [TSize] configurations for [TTile] modeled after heading levels (h1 to h6).
abstract final class TTileSize {
  /// Heading 1: Extra-large tile for hero headers and main dashboards.
  /// (font: 24.0, icon: 32.0, radius: 16.0, hPad/vPad: 12.0, spacing: 16.0).
  static const TSize h1 = TSize(
    hPad: 12.0,
    vPad: 12.0,
    font: 24.0,
    icon: 32.0,
    radius: 16.0,
    spacing: 16.0,
  );

  /// Heading 2: Large tile for major section headers and modal titles.
  /// (font: 20.0, icon: 28.0, radius: 14.0, hPad/vPad: 10.0, spacing: 14.0).
  static const TSize h2 = TSize(
    hPad: 10.0,
    vPad: 10.0,
    font: 20.0,
    icon: 28.0,
    radius: 14.0,
    spacing: 14.0,
  );

  /// Heading 3: Medium-large tile for secondary sections and large card headers.
  /// (font: 18.0, icon: 24.0, radius: 12.0, hPad: 9.0, vPad: 9.0, spacing: 13.0).
  static const TSize h3 = TSize(
    hPad: 9.0,
    vPad: 9.0,
    font: 18.0,
    icon: 24.0,
    radius: 12.0,
    spacing: 13.0,
  );

  /// Heading 4: Standard prominent tile for regular cards and dialog sections.
  /// (font: 16.0, icon: 22.0, radius: 12.0, hPad/vPad: 8.0, spacing: 12.0).
  static const TSize h4 = TSize(
    hPad: 8.0,
    vPad: 8.0,
    font: 16.0,
    icon: 22.0,
    radius: 12.0,
    spacing: 12.0,
  );

  /// Heading 5: Standard default tile for lists, accordions, and table cells.
  /// (font: 14.0, icon: 20.0, radius: 12.0, hPad/vPad: 8.0, spacing: 12.0).
  static const TSize h5 = TSize(
    hPad: 8.0,
    vPad: 8.0,
    font: 14.0,
    icon: 20.0,
    radius: 12.0,
    spacing: 12.0,
  );

  /// Heading 6: Compact/dense tile for tight lists, sidebars, and dense table rows.
  /// (font: 12.5, icon: 16.0, radius: 8.0, hPad/vPad: 6.0, spacing: 10.0).
  static const TSize h6 = TSize(
    hPad: 6.0,
    vPad: 6.0,
    font: 12.5,
    icon: 16.0,
    radius: 8.0,
    spacing: 10.0,
  );
}

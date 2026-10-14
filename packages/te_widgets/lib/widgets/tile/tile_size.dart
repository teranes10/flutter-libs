import 'package:te_widgets/te_widgets.dart';

/// Defines tile-specific size metrics and typography configurations, extending [TSize].
///
/// Predefined presets are modeled after heading levels ([TTileSize.h1] to [TTileSize.h7])
/// and product/image dimensions ([TTileSize.sm], [TTileSize.md], [TTileSize.lg]).
class TTileSize extends TSize {
  /// Font size for the subtitle. If null, falls back to switch/formula resolution.
  final double? subtitleFont;

  /// Gap between title and subtitle. If null, falls back to switch/formula resolution.
  final double? subtitleGap;

  /// Font size for the description. If null, falls back to switch/formula resolution.
  final double? descFont;

  /// Gap between top row (or subtitle) and description. If null, falls back to switch/formula resolution.
  final double? descGap;

  const TTileSize({
    super.minW = 0,
    super.minH = 0,
    super.hPad = 0,
    super.vPad = 0,
    super.font = 14,
    super.icon = 20,
    super.radius = 6,
    super.spacing = 4,
    this.subtitleFont,
    this.subtitleGap,
    this.descFont,
    this.descGap,
  });

  @override
  TTileSize copyWith({
    double? minW,
    double? minH,
    double? hPad,
    double? vPad,
    double? font,
    double? icon,
    double? radius,
    double? spacing,
    double? subtitleFont,
    double? subtitleGap,
    double? descFont,
    double? descGap,
  }) {
    return TTileSize(
      minW: minW ?? this.minW,
      minH: minH ?? this.minH,
      hPad: hPad ?? this.hPad,
      vPad: vPad ?? this.vPad,
      font: font ?? this.font,
      icon: icon ?? this.icon,
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
      subtitleFont: subtitleFont ?? this.subtitleFont,
      subtitleGap: subtitleGap ?? this.subtitleGap,
      descFont: descFont ?? this.descFont,
      descGap: descGap ?? this.descGap,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TTileSize &&
          runtimeType == other.runtimeType &&
          subtitleFont == other.subtitleFont &&
          subtitleGap == other.subtitleGap &&
          descFont == other.descFont &&
          descGap == other.descGap;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        subtitleFont,
        subtitleGap,
        descFont,
        descGap,
      );

  // ── Heading Presets (h1 to h7) ───────────────────────────────────────────

  /// Heading 1: Extra-large tile for hero headers and main dashboards.
  /// (font: 24.0, icon: 32.0, radius: 16.0, hPad/vPad: 12.0, spacing: 16.0, subtitle: 15.0, subGap: 4.0, desc: 14.0, descGap: 8.0).
  static const TTileSize h1 = TTileSize(
    hPad: 12.0,
    vPad: 12.0,
    font: 24.0,
    icon: 32.0,
    radius: 16.0,
    spacing: 16.0,
    subtitleFont: 15.0,
    subtitleGap: 4.0,
    descFont: 14.0,
    descGap: 8.0,
  );

  /// Heading 2: Large tile for major section headers and modal titles.
  /// (font: 20.0, icon: 28.0, radius: 14.0, hPad/vPad: 10.0, spacing: 14.0, subtitle: 14.0, subGap: 3.5, desc: 13.0, descGap: 7.0).
  static const TTileSize h2 = TTileSize(
    hPad: 10.0,
    vPad: 10.0,
    font: 20.0,
    icon: 28.0,
    radius: 14.0,
    spacing: 14.0,
    subtitleFont: 14.0,
    subtitleGap: 3.5,
    descFont: 13.0,
    descGap: 7.0,
  );

  /// Heading 3: Medium-large tile for secondary sections and large card headers.
  /// (font: 18.0, icon: 24.0, radius: 12.0, hPad: 9.0, vPad: 9.0, spacing: 13.0, subtitle: 13.0, subGap: 3.0, desc: 12.5, descGap: 6.0).
  static const TTileSize h3 = TTileSize(
    hPad: 9.0,
    vPad: 9.0,
    font: 18.0,
    icon: 24.0,
    radius: 12.0,
    spacing: 13.0,
    subtitleFont: 13.0,
    subtitleGap: 3.0,
    descFont: 12.5,
    descGap: 6.0,
  );

  /// Heading 4: Standard prominent tile for regular cards and dialog sections.
  /// (font: 16.0, icon: 22.0, radius: 12.0, hPad/vPad: 8.0, spacing: 12.0, subtitle: 12.5, subGap: 2.5, desc: 12.0, descGap: 5.0).
  static const TTileSize h4 = TTileSize(
    hPad: 8.0,
    vPad: 8.0,
    font: 16.0,
    icon: 22.0,
    radius: 12.0,
    spacing: 12.0,
    subtitleFont: 12.5,
    subtitleGap: 2.5,
    descFont: 12.0,
    descGap: 5.0,
  );

  /// Heading 5: Standard default tile for lists, accordions, and table cells.
  /// (font: 14.0, icon: 20.0, radius: 12.0, hPad/vPad: 8.0, spacing: 12.0, subtitle: 12.0, subGap: 2.0, desc: 11.5, descGap: 4.0).
  static const TTileSize h5 = TTileSize(
    hPad: 8.0,
    vPad: 8.0,
    font: 14.0,
    icon: 20.0,
    radius: 12.0,
    spacing: 12.0,
    subtitleFont: 12.0,
    subtitleGap: 2.0,
    descFont: 11.5,
    descGap: 4.0,
  );

  /// Heading 6: Compact/dense tile for tight lists, sidebars, and dense table rows.
  /// (font: 12.5, icon: 16.0, radius: 8.0, hPad/vPad: 6.0, spacing: 10.0, subtitle: 11.0, subGap: 1.5, desc: 10.5, descGap: 4.0).
  static const TTileSize h6 = TTileSize(
    hPad: 6.0,
    vPad: 6.0,
    font: 12.5,
    icon: 16.0,
    radius: 8.0,
    spacing: 10.0,
    subtitleFont: 11.0,
    subtitleGap: 1.5,
    descFont: 10.5,
    descGap: 4.0,
  );

  /// Heading 7: Extra-compact tile for nested rows (e.g. batch lines under an accordion).
  /// (font: 11.5, icon: 14.0, radius: 6.0, hPad/vPad: 4.0, spacing: 8.0, subtitle: 10.0, subGap: 1.0, desc: 9.5, descGap: 3.0).
  static const TTileSize h7 = TTileSize(
    hPad: 4.0,
    vPad: 4.0,
    font: 11.5,
    icon: 14.0,
    radius: 6.0,
    spacing: 8.0,
    subtitleFont: 10.0,
    subtitleGap: 1.0,
    descFont: 9.5,
    descGap: 3.0,
  );

  // ── Product / Image Presets (sm, md, lg) ──────────────────────────────────

  /// Small product/image tile focusing on image dimensions (50px) with balanced typography.
  /// (font: 14.0, icon: 50.0, radius: 8.0, hPad/vPad: 8.0, spacing: 12.0, subtitle: 12.0, subGap: 2.0, desc: 11.5, descGap: 4.0).
  static const TTileSize sm = TTileSize(
    minW: 50.0,
    minH: 50.0,
    hPad: 8.0,
    vPad: 8.0,
    font: 14.0,
    icon: 50.0,
    radius: 8.0,
    spacing: 12.0,
    subtitleFont: 12.0,
    subtitleGap: 2.0,
    descFont: 11.5,
    descGap: 4.0,
  );

  /// Medium product/image tile focusing on image dimensions (75px) with balanced typography.
  /// (font: 16.0, icon: 75.0, radius: 10.0, hPad/vPad: 8.0, spacing: 14.0, subtitle: 13.0, subGap: 2.5, desc: 12.0, descGap: 5.0).
  static const TTileSize md = TTileSize(
    minW: 75.0,
    minH: 75.0,
    hPad: 8.0,
    vPad: 8.0,
    font: 16.0,
    icon: 75.0,
    radius: 10.0,
    spacing: 14.0,
    subtitleFont: 13.0,
    subtitleGap: 2.0,
    descFont: 12.0,
    descGap: 6.0,
  );

  /// Large product/image tile focusing on image dimensions (100px) with balanced typography.
  /// (font: 18.0, icon: 100.0, radius: 12.0, hPad/vPad: 8.0, spacing: 16.0, subtitle: 14.0, subGap: 3.0, desc: 13.0, descGap: 6.0).
  static const TTileSize lg = TTileSize(
    minW: 100.0,
    minH: 100.0,
    hPad: 8.0,
    vPad: 8.0,
    font: 18.0,
    icon: 100.0,
    radius: 12.0,
    spacing: 16.0,
    subtitleFont: 14.0,
    subtitleGap: 3.0,
    descFont: 13.0,
    descGap: 7.5,
  );
}

/// Resolves tile-specific metrics for any [TSize].
///
/// If the size is an instance of [TTileSize], its configured values are used directly.
/// Otherwise, falls back to switch expressions based on presets and font/spacing metrics.
extension TTileSizeExtension on TSize {
  /// Resolves the subtitle font size.
  double resolveSubtitleFontSize() {
    if (this is TTileSize && (this as TTileSize).subtitleFont != null) {
      return (this as TTileSize).subtitleFont!;
    }
    return switch (this) {
      TTileSize.h1 => 15.0,
      TTileSize.h2 => 14.0,
      TTileSize.h3 => 13.0,
      TTileSize.h4 => 12.5,
      TTileSize.h5 => 12.0,
      TTileSize.h6 => 11.0,
      TTileSize.h7 => 10.0,
      TTileSize.lg => 14.0,
      TTileSize.md => 13.0,
      TTileSize.sm => 12.0,
      _ => (font * 0.85).clamp(10.0, 16.0),
    };
  }

  /// Resolves the gap between title and subtitle.
  double resolveSubtitleGap() {
    if (this is TTileSize && (this as TTileSize).subtitleGap != null) {
      return (this as TTileSize).subtitleGap!;
    }
    return switch (this) {
      TTileSize.h1 => 4.0,
      TTileSize.h2 => 3.5,
      TTileSize.h3 => 3.0,
      TTileSize.h4 => 2.5,
      TTileSize.h5 => 2.0,
      TTileSize.h6 => 1.5,
      TTileSize.h7 => 1.0,
      TTileSize.lg => 3.0,
      TTileSize.md => 2.5,
      TTileSize.sm => 2.0,
      _ => (font * 0.15).clamp(1.5, 4.0),
    };
  }

  /// Resolves the description font size.
  double resolveDescFontSize() {
    if (this is TTileSize && (this as TTileSize).descFont != null) {
      return (this as TTileSize).descFont!;
    }
    return switch (this) {
      TTileSize.h1 => 14.0,
      TTileSize.h2 => 13.0,
      TTileSize.h3 => 12.5,
      TTileSize.h4 => 12.0,
      TTileSize.h5 => 11.5,
      TTileSize.h6 => 10.5,
      TTileSize.h7 => 9.5,
      TTileSize.lg => 13.0,
      TTileSize.md => 12.0,
      TTileSize.sm => 11.5,
      _ => (font * 0.8).clamp(10.0, 15.0),
    };
  }

  /// Resolves the gap between top row and description.
  double resolveDescGap() {
    if (this is TTileSize && (this as TTileSize).descGap != null) {
      return (this as TTileSize).descGap!;
    }
    return switch (this) {
      TTileSize.h1 => 8.0,
      TTileSize.h2 => 7.0,
      TTileSize.h3 => 6.0,
      TTileSize.h4 => 5.0,
      TTileSize.h5 => 4.0,
      TTileSize.h6 => 4.0,
      TTileSize.h7 => 3.0,
      TTileSize.lg => 6.0,
      TTileSize.md => 5.0,
      TTileSize.sm => 4.0,
      _ => (spacing * 0.5).clamp(4.0, 8.0),
    };
  }
}

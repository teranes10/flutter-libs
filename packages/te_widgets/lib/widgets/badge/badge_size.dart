import 'package:te_widgets/te_widgets.dart';

/// Predefined size configurations for [TBadge].
abstract final class TBadgeSize {
  /// Status dot size.
  static const TSize dot = TSize(
    minW: 8.0,
    minH: 8.0,
    radius: 4.0,
  );

  /// Extra extra small badge size (minW/minH: 12, font: 8.5, icon: 8, hPad: 2, vPad: 1, radius: 6).
  static const TSize xxs = TSize(
    minW: 12.0,
    minH: 12.0,
    hPad: 2.0,
    vPad: 1.0,
    font: 8.5,
    icon: 8.0,
    radius: 6.0,
    spacing: 2.0,
  );

  /// Extra small badge size (minW/minH: 14, font: 9.5, icon: 10, hPad: 3, vPad: 1.0, radius: 7).
  static const TSize xs = TSize(
    minW: 14.0,
    minH: 14.0,
    hPad: 3.0,
    vPad: 0.0,
    font: 9.5,
    icon: 10.0,
    radius: 7.0,
    spacing: 2.0,
  );

  /// Small standard badge size (minW/minH: 18, font: 10.0, icon: 12, hPad: 4, vPad: 1.5, radius: 9).
  static const TSize sm = TSize(
    minW: 16.0,
    minH: 16.0,
    hPad: 4.0,
    vPad: 1.0,
    font: 10.0,
    icon: 12.0,
    radius: 9.0,
    spacing: 3.0,
  );

  /// Medium badge size (minW/minH: 20, font: 11.0, icon: 14, hPad: 5, vPad: 2.0, radius: 10).
  static const TSize md = TSize(
    minW: 20.0,
    minH: 20.0,
    hPad: 5.0,
    vPad: 2.0,
    font: 11.0,
    icon: 14.0,
    radius: 10.0,
    spacing: 4.0,
  );

  /// Large prominent badge size (minW/minH: 24, font: 12.0, icon: 16, hPad: 6, vPad: 2.5, radius: 12).
  static const TSize lg = TSize(
    minW: 24.0,
    minH: 24.0,
    hPad: 6.0,
    vPad: 2.5,
    font: 12.0,
    icon: 16.0,
    radius: 12.0,
    spacing: 4.0,
  );
}

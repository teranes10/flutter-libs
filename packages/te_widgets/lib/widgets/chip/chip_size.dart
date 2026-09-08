import 'package:te_widgets/te_widgets.dart';

/// Predefined size configurations for [TChip].
abstract final class TChipSize {
  /// Small compact chip size (fontSize: 10.5, icon: 11, radius: 4, hPad: 6, vPad: 2).
  static const TSize sm = TSize(
    hPad: 5.0,
    vPad: 1.0,
    font: 11,
    icon: 11.0,
    radius: 4.0,
    spacing: 3.5,
  );

  /// Medium standard chip size (fontSize: 12, icon: 13, radius: 6, hPad: 8, vPad: 3).
  static const TSize md = TSize(
    hPad: 8.0,
    vPad: 3.0,
    font: 12.0,
    icon: 13.0,
    radius: 6.0,
    spacing: 4.0,
  );

  /// Large prominent chip size (fontSize: 13.5, icon: 15, radius: 8, hPad: 10, vPad: 4).
  static const TSize lg = TSize(
    hPad: 10.0,
    vPad: 4.0,
    font: 13.5,
    icon: 15.0,
    radius: 8.0,
    spacing: 5.0,
  );
}

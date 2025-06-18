import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/configs/theme/theme_text.dart';

ThemeData teWidgetsTheme() {
  return ThemeData(
    colorScheme: getTColorScheme(),
    textTheme: getTTextTheme(),
  );
}

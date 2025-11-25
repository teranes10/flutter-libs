import 'package:flutter/material.dart';

extension ColorSchemeX on ColorScheme {
  bool get isDarkMode => brightness == Brightness.dark;
}

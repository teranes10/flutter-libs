import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

extension ColorX on Color {
  Color shade(int shade) {
    if (this is MaterialColor) return (this as MaterialColor)[shade]!;

    return switch (shade) {
      50 => Color.lerp(this, Colors.white, 0.9)!,
      100 => Color.lerp(this, Colors.white, 0.8)!,
      200 => Color.lerp(this, Colors.white, 0.6)!,
      300 => Color.lerp(this, Colors.white, 0.4)!,
      400 => Color.lerp(this, Colors.white, 0.2)!,
      500 => this,
      600 => Color.lerp(this, Colors.black, 0.1)!,
      700 => Color.lerp(this, Colors.black, 0.2)!,
      800 => Color.lerp(this, Colors.black, 0.3)!,
      900 => Color.lerp(this, Colors.black, 0.4)!,
      _ => throw ArgumentError("Invalid shade value."),
    };
  }

  MaterialColor toMaterial() {
    if (this is MaterialColor) return (this as MaterialColor);

    return MaterialColor(toARGB32(), <int, Color>{
      50: Color.lerp(this, Colors.white, 0.9)!,
      100: Color.lerp(this, Colors.white, 0.8)!,
      200: Color.lerp(this, Colors.white, 0.6)!,
      300: Color.lerp(this, Colors.white, 0.4)!,
      400: Color.lerp(this, Colors.white, 0.2)!,
      500: this,
      600: Color.lerp(this, Colors.black, 0.1)!,
      700: Color.lerp(this, Colors.black, 0.2)!,
      800: Color.lerp(this, Colors.black, 0.3)!,
      900: Color.lerp(this, Colors.black, 0.4)!,
    });
  }

  bool get isTransparent {
    return a == 0;
  }

  Color o(double opacity) {
    if (isTransparent) return this;
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }

  PdfColor toPdfColor() {
    int r = (this.r * 255.0).round() & 0xff;
    int g = (this.g * 255.0).round() & 0xff;
    int b = (this.b * 255.0).round() & 0xff;
    int a = (this.a * 255.0).round() & 0xff;

    return PdfColor(
      r / 255.0,
      g / 255.0,
      b / 255.0,
      a / 255.0,
    );
  }
}

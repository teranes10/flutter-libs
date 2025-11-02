import 'package:flutter/material.dart';

enum TInputSize { sm, md, lg }

extension TInputSizeX on TInputSize? {
  double get height {
    return switch (this) {
      TInputSize.sm => 38.0,
      TInputSize.lg => 46.0,
      _ => 42.0,
    };
  }

  double get fontSize {
    return switch (this) {
      TInputSize.sm => 13.0,
      TInputSize.lg => 16.0,
      _ => 14.0,
    };
  }

  EdgeInsets get padding {
    return switch (this) {
      TInputSize.sm => const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      TInputSize.lg => const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      _ => const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
    };
  }
}

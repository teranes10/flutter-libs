import 'package:flutter/material.dart';

enum TInputSize { xs, sm, md, lg }

extension TInputSizeX on TInputSize? {
  double get height {
    return switch (this) {
      TInputSize.xs => 32.0,
      TInputSize.sm => 38.0,
      TInputSize.md => 48.0,
      TInputSize.lg => 56.0,
      _ => 48.0,
    };
  }

  double get fontSize {
    return switch (this) {
      TInputSize.xs => 12.0,
      TInputSize.sm => 13.0,
      TInputSize.lg => 18.0,
      _ => 14.0,
    };
  }

  EdgeInsets get padding {
    return switch (this) {
      TInputSize.xs => const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      TInputSize.sm => const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
      TInputSize.lg => const EdgeInsets.symmetric(vertical: 19, horizontal: 14),
      _ => const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    };
  }
}

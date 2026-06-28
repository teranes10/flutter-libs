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
      TInputSize.xs => const EdgeInsets.only(top: 10, bottom: 3, left: 8, right: 8),
      TInputSize.sm => const EdgeInsets.only(top: 15, bottom: 6, left: 10, right: 10),
      TInputSize.lg => const EdgeInsets.only(top: 24, bottom: 10, left: 14, right: 14),
      _ => const EdgeInsets.only(top: 22, bottom: 8, left: 12, right: 12),
    };
  }
}

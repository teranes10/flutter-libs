import 'package:flutter/material.dart';

enum TShadowLevel { none, low, medium, high }

extension TShadowLevelExtensions on TShadowLevel {
  double toElevation() {
    switch (this) {
      case TShadowLevel.none:
        return 0;
      case TShadowLevel.low:
        return 1;
      case TShadowLevel.medium:
        return 4;
      case TShadowLevel.high:
        return 8;
    }
  }

  List<BoxShadow> toBoxShadow() {
    switch (this) {
      case TShadowLevel.none:
        return [];
      case TShadowLevel.low:
        return [BoxShadow(color: Colors.grey.shade50, offset: const Offset(0, 2), blurRadius: 0, spreadRadius: 0)];
      case TShadowLevel.medium:
        return [
          BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0),
          BoxShadow(color: Colors.grey.shade100, offset: const Offset(0, 1), blurRadius: 2, spreadRadius: 0),
        ];
      case TShadowLevel.high:
        return [
          BoxShadow(color: Colors.grey.shade400, offset: const Offset(0, 4), blurRadius: 8, spreadRadius: 0),
          BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0),
        ];
    }
  }
}

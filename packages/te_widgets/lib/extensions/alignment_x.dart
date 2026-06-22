import 'package:flutter/material.dart';

extension AlignmentX on Alignment {
  MainAxisAlignment get rowMainAxis {
    if (x == -1.0) return MainAxisAlignment.start;
    if (x == 1.0) return MainAxisAlignment.end;
    return MainAxisAlignment.center;
  }

  CrossAxisAlignment get rowCrossAxis {
    if (y == -1.0) return CrossAxisAlignment.start;
    if (y == 1.0) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }

  MainAxisAlignment get colMainAxis {
    if (y == -1.0) return MainAxisAlignment.start;
    if (y == 1.0) return MainAxisAlignment.end;
    return MainAxisAlignment.center;
  }

  CrossAxisAlignment get colCrossAxis {
    if (x == -1.0) return CrossAxisAlignment.start;
    if (x == 1.0) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }
}

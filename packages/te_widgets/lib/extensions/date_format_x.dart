import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateFormatX on DateFormat {
  /// Formats a [TimeOfDay] using this [DateFormat] instance.
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return format(dateTime);
  }
}

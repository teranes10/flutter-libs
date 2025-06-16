import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension TimeOfDayFormat on TimeOfDay {
  String format([String pattern = 'hh:mm a']) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat(pattern).format(dateTime);
  }
}

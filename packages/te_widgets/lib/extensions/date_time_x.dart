import 'package:flutter/material.dart';

extension DateTimeX on DateTime {
  TimeOfDay get toTimeOfDay => TimeOfDay.fromDateTime(this);
}

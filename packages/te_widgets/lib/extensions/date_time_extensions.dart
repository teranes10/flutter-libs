import 'package:flutter/material.dart';

extension DateTimeToTimeOfDay on DateTime {
  TimeOfDay get toTimeOfDay => TimeOfDay.fromDateTime(this);
}

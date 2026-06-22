import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  TimeOfDay get toTimeOfDay => TimeOfDay.fromDateTime(this);

  String format(DateFormat formatter) {
    return formatter.format(this);
  }

  String formatPattern(String pattern) {
    return format(DateFormat(pattern));
  }

  /// Formats the [DateTime] into a relative "time ago" string.
  /// Handles "seconds ago", "minutes ago", "yesterday", "days ago", and above a week "YYYY-MM-DD".
  /// Also includes "hours ago" to bridge the gap between minutes and yesterday.
  String formatAgo({DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return DateFormat('yyyy-MM-dd').format(this);
    }

    if (difference.inSeconds < 60) {
      final seconds = difference.inSeconds;
      if (seconds <= 0) return 'just now';
      return seconds == 1 ? '1 second ago' : '$seconds seconds ago';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    }

    // Check calendar dates to determine "today" (hours ago), "yesterday", "days ago"
    final todayStart = DateTime(now.year, now.month, now.day);
    final dateStart = DateTime(year, month, day);
    final daysDiff = todayStart.difference(dateStart).inDays;

    if (daysDiff == 0) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }

    if (daysDiff == 1) {
      return 'yesterday';
    }

    if (daysDiff < 7) {
      return '$daysDiff days ago';
    }

    return DateFormat('yyyy-MM-dd').format(this);
  }
}

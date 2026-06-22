import 'package:intl/intl.dart';

class TFormats {
  /// e.g. 2026-06-18
  static const String dateStandard = "yyyy-MM-dd";

  /// e.g. 18 Jun 2026
  static const String dateDescriptive = "d MMM yyyy";

  /// e.g. 18/06/2026
  static const String dateSlash = "dd/MM/yyyy";

  /// e.g. 06/18/2026
  static const String dateSlashUS = "MM/dd/yyyy";

  /// e.g. Jun 18, 2026
  static const String dateShort = "MMM d, yyyy";

  /// e.g. June 18, 2026
  static const String dateFull = "MMMM d, yyyy";

  /// e.g. 10:15 pm
  static const String time12h = "h:mm a";

  /// e.g. 10:15:30 pm
  static const String time12hWithSec = "h:mm:ss a";

  /// e.g. 22:15
  static const String time24h = "HH:mm";

  /// e.g. 22:15:30
  static const String time24hWithSec = "HH:mm:ss";

  /// e.g. 2026-06-18T22:15:35Z
  static const String dateTimeISO = "yyyy-MM-dd'T'HH:mm:ss'Z'";

  /// e.g. 18 Jun 2026, 10:15:30 pm
  static const String dateTimeDescriptive = "dd MMM yyyy, h:mm:ss a";

  /// e.g. Thursday, June 18, 2026, 10:15:30 pm
  static const String dateTimeFull = "EEEE, MMMM d, yyyy, h:mm:ss a";

  /// e.g. 2026-06-18 22:15:30
  static const String dateTimeDB = "yyyy-MM-dd HH:mm:ss";

  /// e.g. 18.06.2026 T 22:15
  static const String dateTimeRangeDefault = "dd.MM.yyyy 'T' HH:mm";

  static String currentDateFormat = dateStandard;
  static String currentTimeFormat = time12hWithSec;
  static String currentDateTimeFormat = dateTimeDescriptive;
  static String currentCurrencySymbol = '\$';
}

/// A helper class containing standard formatting utilities for numbers, distances, currencies,
/// contact numbers, date-times, and ranges.
class TFormatter {
  /// Validates standard ISO date strings, ensuring they are valid and exceed [minYear].
  static String? validateDateTime(String dateTime, [int minYear = 1900]) {
    if (dateTime == "0001-01-01T00:00:00" || dateTime == "0001-01-01") {
      return null;
    }

    final parsed = DateTime.tryParse(dateTime);
    if (parsed == null || parsed.year < minYear) {
      return null;
    }

    return dateTime;
  }

  static DateTime? parseDate(String input, {String format = 'YYYY-MM-DD'}) {
    try {
      return DateFormat(format).parse(input);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseUtcISO(String input) {
    var value = input.trim();
    if (value.isEmpty) return null;

    try {
      if (RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(value)) throw FormatException('Not a UTC timestamp');

      if (!value.endsWith('Z')) {
        value += 'Z';
      }

      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Format date
  static String date(DateTime date) {
    final formatter = DateFormat(TFormats.currentDateFormat);
    return formatter.format(date);
  }

  /// Format time
  static String time(DateTime time) {
    final formatter = DateFormat(TFormats.currentTimeFormat);
    return formatter.format(time);
  }

  /// Format datetime
  static String dateTime(DateTime dateTime) {
    final formatter = DateFormat(TFormats.currentDateTimeFormat);
    return formatter.format(dateTime);
  }

  /// Formats duration string representing difference between two dates.
  static String duration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return seconds(diff.inSeconds);
  }

  /// Formats raw seconds into a human-readable duration (e.g. "1d 2h 3m 4s").
  static String seconds(num? secs) {
    if (secs == null) return "";
    if (secs <= 0) return "0s";

    final d = (secs / (3600 * 24)).floor();
    final h = ((secs % (3600 * 24)) / 3600).floor();
    final m = ((secs % 3600) / 60).floor();
    final s = (secs % 60).floor();

    final parts = <String>[];
    if (d > 0) parts.add("${d}d");
    if (h > 0 || parts.isNotEmpty) parts.add("${h}h");
    if (m > 0 || parts.isNotEmpty) parts.add("${m}m");
    parts.add("${s}s");

    return parts.join(" ");
  }

  /// Formats raw minutes into a human-readable duration.
  static String minutes(num? mins) {
    if (mins == null) return "";
    return seconds(mins * 60);
  }

  /// Formats cents value into currency representation.
  static String cents(num? centsVal, [int decimals = 2, String symbol = "\$"]) {
    if (centsVal == null) return "";
    if (centsVal <= 0) return symbol + (0.0).toStringAsFixed(decimals);
    return symbol + (centsVal / 100).toStringAsFixed(decimals);
  }

  /// Formats dollars value into currency representation.
  static String dollars(num? dollarsVal, [int decimals = 2, String symbol = "\$"]) {
    if (dollarsVal == null) return "";
    return cents(dollarsVal * 100, decimals, symbol);
  }

  /// Formats meters into metric distance (e.g., "1km 200m" or "500m").
  static String meters(num? metersVal, [int decimals = 1]) {
    if (metersVal == null) return "";
    if (metersVal <= 0) return "0m";

    if (metersVal >= 1000) {
      final km = (metersVal / 1000).floor();
      final remainingMeters = metersVal % 1000;
      final mStr = remainingMeters.toStringAsFixed(decimals);
      final m = double.tryParse(mStr) ?? 0.0;
      final mFormatted = m % 1 == 0 ? m.toInt().toString() : m.toString();
      return m > 0 ? "${km}km ${mFormatted}m" : "${km}km";
    }
    final formatted = double.tryParse(metersVal.toStringAsFixed(decimals)) ?? 0.0;
    final formattedStr = formatted % 1 == 0 ? formatted.toInt().toString() : formatted.toString();
    return "${formattedStr}m";
  }

  /// Formats speed in meters per second to km/h representation.
  static String metersPerSecond(num? speed) {
    if (speed == null || speed == 0) {
      return "0 km/h";
    }
    return "${(speed * 3.6).toStringAsFixed(0)} km/h";
  }

  /// Formats contact numbers, normalising '+61' to '0' and spacing 10-digit numbers.
  static String formatContactNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return "";
    }

    var cleaned = phone.replaceFirst(RegExp(r'^\+61'), '0').replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      return "${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6)}";
    }

    return cleaned;
  }

  /// Formats [value] using a standard decimal format with a configurable number of [decimals].
  static String number(num value, {int decimals = 0}) {
    final formatter = NumberFormat('#,##0${decimals > 0 ? '.${'0' * decimals}' : ''}');
    return formatter.format(value);
  }

  /// Formats [value] (e.g. 0.15) to its percentage representation (e.g. "15.0%").
  static String percentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Formats file size in bytes to a human-readable format (e.g., "12.5 MB").
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Formats currency values (defaulting to the en_LK locale, e.g. Rs. 1,000.00).
  static String currency(double amount, {bool? showSymbol, bool? showDecimals, String? unitSymbol}) {
    final symbol = showSymbol == false ? '' : TFormats.currentCurrencySymbol;
    final hasDecimal = amount % 1 != 0;
    final decimalDigits = showDecimals == true || hasDecimal ? 2 : 0;

    return NumberFormat.currency(locale: 'en_LK', symbol: symbol, decimalDigits: decimalDigits).format(amount) +
        (unitSymbol != null ? ' / $unitSymbol' : '');
  }
}

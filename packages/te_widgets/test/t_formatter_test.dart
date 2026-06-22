import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:intl/intl.dart';

void main() {
  group('TFormatter tests', () {
    test('seconds and minutes formatting', () {
      expect(TFormatter.seconds(null), "");
      expect(TFormatter.seconds(0), "0s");
      expect(TFormatter.seconds(-5), "0s");
      expect(TFormatter.seconds(5), "5s");
      expect(TFormatter.seconds(65), "1m 5s");
      expect(TFormatter.seconds(3665), "1h 1m 5s");
      expect(TFormatter.seconds(90065), "1d 1h 1m 5s");

      expect(TFormatter.minutes(null), "");
      expect(TFormatter.minutes(1.5), "1m 30s");
    });

    test('meters formatting', () {
      expect(TFormatter.meters(null), "");
      expect(TFormatter.meters(0), "0m");
      expect(TFormatter.meters(500.55, 1), "500.6m");
      expect(TFormatter.meters(1000), "1km");
      expect(TFormatter.meters(1500), "1km 500m");
      expect(TFormatter.meters(1500.5, 1), "1km 500.5m");
    });

    test('cents and dollars formatting', () {
      expect(TFormatter.cents(null), "");
      expect(TFormatter.cents(0), "\$0.00");
      expect(TFormatter.cents(1234), "\$12.34");
      expect(TFormatter.cents(1234, 1), "\$12.3");

      expect(TFormatter.dollars(null), "");
      expect(TFormatter.dollars(0), "\$0.00");
      expect(TFormatter.dollars(12.34), "\$12.34");
    });

    test('metersPerSecond formatting', () {
      expect(TFormatter.metersPerSecond(null), "0 km/h");
      expect(TFormatter.metersPerSecond(0), "0 km/h");
      expect(TFormatter.metersPerSecond(10), "36 km/h");
    });

    test('formatContactNumber formatting', () {
      expect(TFormatter.formatContactNumber(null), "");
      expect(TFormatter.formatContactNumber(""), "");
      expect(TFormatter.formatContactNumber("+61412345678"), "0412 34 5678");
      expect(TFormatter.formatContactNumber("0412345678"), "0412 34 5678");
      expect(TFormatter.formatContactNumber("123"), "123");
    });

    test('validateDateTime validation', () {
      expect(TFormatter.validateDateTime("0001-01-01T00:00:00"), null);
      expect(TFormatter.validateDateTime("2026-06-18T22:06:52"), "2026-06-18T22:06:52");
      expect(TFormatter.validateDateTime("1800-01-01"), null); // under default minYear (1900)
    });

    test('Common pattern constants formatting', () {
      final dt = DateTime(2026, 6, 18, 22, 15, 30);

      // Date patterns
      expect(dt.formatPattern(TFormats.dateStandard), "2026-06-18");
      expect(dt.formatPattern(TFormats.dateDescriptive), "18 Jun 2026");
      expect(dt.formatPattern(TFormats.dateSlash), "18/06/2026");
      expect(dt.formatPattern(TFormats.dateSlashUS), "06/18/2026");
      expect(dt.formatPattern(TFormats.dateShort), "Jun 18, 2026");
      expect(dt.formatPattern(TFormats.dateFull), "June 18, 2026");

      // Time patterns
      expect(dt.formatPattern(TFormats.time12h), "10:15 PM");
      expect(dt.formatPattern(TFormats.time12hWithSec), "10:15:30 PM");
      expect(dt.formatPattern(TFormats.time24h), "22:15");
      expect(dt.formatPattern(TFormats.time24hWithSec), "22:15:30");

      // DateTime patterns
      expect(dt.formatPattern(TFormats.dateTimeDB), "2026-06-18 22:15:30");
      expect(dt.formatPattern(TFormats.dateTimeDescriptive), "18 Jun 2026, 10:15:30 PM");
      expect(dt.formatPattern(TFormats.dateTimeFull), "Thursday, June 18, 2026, 10:15:30 PM");

      // DateFormat instance
      expect(dt.format(DateFormat.yMMMMd()), "June 18, 2026");
      expect(TFormatter.parseUtcISO("2026-06-18T22:15:30"), DateTime.utc(2026, 6, 18, 22, 15, 30));
    });

    test('Number, percentage, fileSize, and currency formatting', () {
      // number
      expect(TFormatter.number(1234567.89, decimals: 2), "1,234,567.89");
      expect(TFormatter.number(1234567, decimals: 0), "1,234,567");

      // percentage
      expect(TFormatter.percentage(0.15), "15.0%");
      expect(TFormatter.percentage(0.1234, decimals: 2), "12.34%");

      // fileSize
      expect(TFormatter.fileSize(500), "500 B");
      expect(TFormatter.fileSize(1500), "1.5 KB");
      expect(TFormatter.fileSize(1024 * 1024 * 5), "5.0 MB");
      expect(TFormatter.fileSize(1024 * 1024 * 1024 * 3), "3.0 GB");

      // currency
      final curVal = TFormatter.currency(1500.5, showSymbol: true);
      expect(curVal, "\$1,500.50");

      final curValWithUnit = TFormatter.currency(1500.0, showDecimals: false, unitSymbol: "kg");
      expect(curValWithUnit, contains("1,500 / kg"));
    });
  });
}

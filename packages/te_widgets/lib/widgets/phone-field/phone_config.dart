import '../../helpers/countries.dart';

/// Global configuration for [TPhoneField].
class TPhoneConfig {
  /// ISO country code (e.g. 'LK') used when a field has no `initialCountry`.
  static String? initialCountryCode;

  /// Resolved default country; falls back to the first country in [TCountries.all].
  static TCountry get initialCountry {
    final code = initialCountryCode?.toUpperCase();
    return TCountries.all.firstWhere((c) => c.code.toUpperCase() == code, orElse: () => TCountries.all.first);
  }
}

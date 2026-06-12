class TCountry {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final String format;
  final List<String> timezones;

  const TCountry({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.format,
    required this.timezones,
  });
}

class TCountries {
  static const List<TCountry> all = [
    TCountry(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flag: '🇦🇺',
      format: '000 000 000',
      timezones: [
        'Australia/Sydney',
        'Australia/Melbourne',
        'Australia/Brisbane',
        'Australia/Perth',
        'Australia/Adelaide',
        'Australia/Darwin'
      ],
    ),
    TCountry(
      name: 'Sri Lanka',
      code: 'LK',
      dialCode: '+94',
      flag: '🇱🇰',
      format: '00 000 0000',
      timezones: ['Asia/Colombo'],
    ),
    TCountry(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
      format: '000 000 0000',
      timezones: ['America/New_York', 'America/Chicago', 'America/Denver', 'America/Los_Angeles', 'America/Anchorage', 'Pacific/Honolulu'],
    ),
    TCountry(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
      format: '0000 000000',
      timezones: ['Europe/London', 'GMT', 'BST'],
    ),
    TCountry(
      name: 'Canada',
      code: 'CA',
      dialCode: '+1',
      flag: '🇨🇦',
      format: '000 000 0000',
      timezones: ['America/Toronto', 'America/Vancouver', 'America/Edmonton', 'America/Winnipeg', 'America/Halifax', 'America/St_Johns'],
    ),
    TCountry(
      name: 'Germany',
      code: 'DE',
      dialCode: '+49',
      flag: '🇩🇪',
      format: '000 0000000',
      timezones: ['Europe/Berlin'],
    ),
    TCountry(
      name: 'France',
      code: 'FR',
      dialCode: '+33',
      flag: '🇫🇷',
      format: '0 00 00 00 00',
      timezones: ['Europe/Paris'],
    ),
    TCountry(
      name: 'Italy',
      code: 'IT',
      dialCode: '+39',
      flag: '🇮🇹',
      format: '000 000 0000',
      timezones: ['Europe/Rome'],
    ),
    TCountry(
      name: 'Spain',
      code: 'ES',
      dialCode: '+34',
      flag: '🇪🇸',
      format: '000 000 000',
      timezones: ['Europe/Madrid'],
    ),
    TCountry(
      name: 'India',
      code: 'IN',
      dialCode: '+91',
      flag: '🇮🇳',
      format: '00000 00000',
      timezones: ['Asia/Kolkata'],
    ),
    TCountry(
      name: 'China',
      code: 'CN',
      dialCode: '+86',
      flag: '🇨🇳',
      format: '000 0000 0000',
      timezones: ['Asia/Shanghai', 'Asia/Urumqi'],
    ),
    TCountry(
      name: 'Japan',
      code: 'JP',
      dialCode: '+81',
      flag: '🇯🇵',
      format: '00 0000 0000',
      timezones: ['Asia/Tokyo'],
    ),
    TCountry(
      name: 'South Korea',
      code: 'KR',
      dialCode: '+82',
      flag: '🇰🇷',
      format: '00 0000 0000',
      timezones: ['Asia/Seoul'],
    ),
    TCountry(
      name: 'Brazil',
      code: 'BR',
      dialCode: '+55',
      flag: '🇧🇷',
      format: '00 00000 0000',
      timezones: ['America/Sao_Paulo', 'America/Manaus', 'America/Belem', 'America/Recife'],
    ),
    TCountry(
      name: 'Mexico',
      code: 'MX',
      dialCode: '+52',
      flag: '🇲🇽',
      format: '00 0000 0000',
      timezones: ['America/Mexico_City', 'America/Monterrey', 'America/Tijuana'],
    ),
    TCountry(
      name: 'United Arab Emirates',
      code: 'AE',
      dialCode: '+971',
      flag: '🇦🇪',
      format: '0 000 0000',
      timezones: ['Asia/Dubai'],
    ),
    TCountry(
      name: 'Saudi Arabia',
      code: 'SA',
      dialCode: '+966',
      flag: '🇸🇦',
      format: '0 000 0000',
      timezones: ['Asia/Riyadh'],
    ),
    TCountry(
      name: 'Singapore',
      code: 'SG',
      dialCode: '+65',
      flag: '🇸🇬',
      format: '0000 0000',
      timezones: ['Asia/Singapore'],
    ),
    TCountry(
      name: 'Malaysia',
      code: 'MY',
      dialCode: '+60',
      flag: '🇲🇾',
      format: '00 000 0000',
      timezones: ['Asia/Kuala_Lumpur', 'Asia/Kuching'],
    ),
    TCountry(
      name: 'Indonesia',
      code: 'ID',
      dialCode: '+62',
      flag: '🇮🇩',
      format: '000 000 000',
      timezones: ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'],
    ),
  ];

  static TCountry? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  static TCountry? findByTimezone(String timezone) {
    try {
      // Direct match or partial match for common names
      return all.firstWhere((c) => c.timezones.any((tz) => tz == timezone || timezone.contains(tz)));
    } catch (_) {
      return null;
    }
  }
}

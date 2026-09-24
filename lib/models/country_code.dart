/// A dialling code with the shape of a valid national phone number.
///
/// Numbers are validated and stored without the domestic trunk prefix, so
/// `08012345678` (as Nigerians often type it) becomes `8012345678`.
/// Keep [nationalPattern] in sync with `backend/utils/validation.ts`.
class CountryCode {
  const CountryCode(
    this.dialCode,
    this.name, {
    required this.nationalPattern,
    required this.example,
    this.trunkPrefix = '0',
  });

  final String dialCode;
  final String name;

  /// Matches a valid national significant number (no trunk prefix).
  final String nationalPattern;

  /// A valid number, used as the field's placeholder.
  final String example;

  /// Domestic prefix that may be typed before the number and is dropped.
  final String trunkPrefix;

  /// Longest input to allow: the national number plus the trunk prefix.
  int get maxInputLength => example.length + trunkPrefix.length;

  /// Digits only, trunk prefix removed.
  String normalize(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return trunkPrefix.isNotEmpty && digits.startsWith(trunkPrefix)
        ? digits.substring(trunkPrefix.length)
        : digits;
  }

  bool isValid(String input) =>
      RegExp('^$nationalPattern\$').hasMatch(normalize(input));
}

const countryCodes = [
  // Mobile: 70x, 71x, 80x, 81x, 90x, 91x + 7 digits.
  CountryCode(
    '+234',
    'Nigeria',
    nationalPattern: r'[789][01]\d{8}',
    example: '8012345678',
  ),
  CountryCode(
    '+233',
    'Ghana',
    nationalPattern: r'[235]\d{8}',
    example: '241234567',
  ),
  CountryCode(
    '+254',
    'Kenya',
    nationalPattern: r'[17]\d{8}',
    example: '712345678',
  ),
  CountryCode(
    '+27',
    'South Africa',
    nationalPattern: r'[1-8]\d{8}',
    example: '821234567',
  ),
  CountryCode(
    '+44',
    'United Kingdom',
    nationalPattern: r'[1-9]\d{9}',
    example: '7400123456',
  ),
  // North American Numbering Plan: area code and exchange can't start 0/1.
  CountryCode(
    '+1',
    'United States',
    nationalPattern: r'[2-9]\d{2}[2-9]\d{6}',
    example: '2015550123',
    trunkPrefix: '1',
  ),
];

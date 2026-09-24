
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
  final String nationalPattern;
  final String example;
  final String trunkPrefix;
  int get maxInputLength => example.length + trunkPrefix.length;
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
  CountryCode(
    '+1',
    'United States',
    nationalPattern: r'[2-9]\d{2}[2-9]\d{6}',
    example: '2015550123',
    trunkPrefix: '1',
  ),
];

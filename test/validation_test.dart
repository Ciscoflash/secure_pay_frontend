import 'package:flutter_test/flutter_test.dart';

import 'package:securepay/models/country_code.dart';
import 'package:securepay/utils/password_policy.dart';
import 'package:securepay/utils/validators.dart';

CountryCode _country(String dial) =>
    countryCodes.firstWhere((c) => c.dialCode == dial);

void main() {
  group('phone', () {
    final nigeria = _country('+234');
    final validate = Validators.phone(nigeria);

    test('accepts Nigerian mobiles with or without the leading 0', () {
      expect(validate('8012345678'), isNull);
      expect(validate('08012345678'), isNull);
      expect(validate('9112345678'), isNull);
      expect(nigeria.normalize('0801 234 5678'), '8012345678');
    });

    test('rejects empty, short and invalid prefixes', () {
      expect(validate(''), 'Enter your phone number');
      expect(validate('1234567'), contains('valid Nigeria number'));
      expect(validate('6012345678'), isNotNull); // no 60x mobiles
      expect(validate('80123456789'), isNotNull); // too long
    });

    test('uses each country\'s own rules', () {
      expect(Validators.phone(_country('+44'))('07400123456'), isNull);
      expect(Validators.phone(_country('+1'))('2015550123'), isNull);
      expect(Validators.phone(_country('+1'))('12015550123'), isNull);
      expect(Validators.phone(_country('+1'))('1015550123'), isNotNull);
      expect(Validators.phone(_country('+233'))('241234567'), isNull);
      // A valid Nigerian number is not a valid Ghanaian one.
      expect(Validators.phone(_country('+233'))('8012345678'), isNotNull);
    });

    test('every country example is valid for that country', () {
      for (final c in countryCodes) {
        expect(c.isValid(c.example), isTrue, reason: c.name);
      }
    });
  });

  group('password', () {
    test('requires every rule', () {
      expect(Validators.newPassword(''), 'Create a password');
      expect(
        Validators.newPassword('password123'),
        allOf(contains('an uppercase letter'), contains('a symbol')),
      );
      expect(Validators.newPassword('Ab1!'), contains('at least 8'));
      expect(Validators.newPassword('Str0ng!Pass'), isNull);
    });

    test('rejects common passwords and overly long ones', () {
      expect(Validators.newPassword('P@ssw0rd'), contains('too common'));
      expect(Validators.newPassword('Aa1!${'x' * 69}'), contains('at most 72'));
    });

    test('strength grows with the rules met and length', () {
      expect(PasswordPolicy.strength(''), 0);
      expect(PasswordPolicy.strength('abc'), 1);
      expect(PasswordPolicy.strength('abcDEF12'), 2);
      expect(PasswordPolicy.strength('Str0ng!Pa'), 3);
      expect(PasswordPolicy.strength('Str0ng!Passphrase'), 4);
      expect(PasswordPolicy.strength('P@ssw0rd'), 2); // common caps it
    });
  });
}

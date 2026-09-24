/// Password rules for new accounts, shared by the validator and the strength
/// meter. Keep in sync with `backend/utils/validation.ts`.
abstract final class PasswordPolicy {
  static const minLength = 8;

  /// bcrypt only hashes the first 72 bytes; longer input would be silently
  /// truncated, so cap it.
  static const maxLength = 72;

  static final rules = <PasswordRule>[
    PasswordRule(
      'At least $minLength characters',
      (p) => p.length >= minLength,
    ),
    PasswordRule('An uppercase letter', (p) => p.contains(RegExp('[A-Z]'))),
    PasswordRule('A lowercase letter', (p) => p.contains(RegExp('[a-z]'))),
    PasswordRule('A number', (p) => p.contains(RegExp(r'\d'))),
    PasswordRule(
      'A symbol (e.g. ! @ # \$ %)',
      (p) => p.contains(RegExp(r'[^A-Za-z0-9\s]')),
    ),
  ];

  /// Frequently breached passwords that technically pass the rules above.
  static const _common = {
    'password1!',
    'password@1',
    'password123!',
    'p@ssw0rd',
    'p@ssword1',
    'passw0rd!',
    'qwerty123!',
    'welcome1!',
    'welcome@123',
    'admin@123',
    'abc@1234',
    'letmein1!',
  };

  static bool isCommon(String password) =>
      _common.contains(password.toLowerCase());

  /// First problem with [password], or null if it is acceptable.
  static String? validate(String password) {
    if (password.isEmpty) return 'Create a password';
    if (password.length > maxLength) {
      return 'Password must be at most $maxLength characters';
    }
    final missing = rules.where((r) => !r.test(password)).toList();
    if (missing.isNotEmpty) {
      return 'Password needs: ${missing.map((r) => r.label.toLowerCase()).join(', ')}';
    }
    if (isCommon(password)) {
      return 'This password is too common. Choose something harder to guess';
    }
    return null;
  }

  /// 0 (empty) to 4 (strong).
  static int strength(String password) {
    if (password.isEmpty) return 0;
    final met = rules.where((r) => r.test(password)).length;
    if (met < rules.length || isCommon(password)) {
      return met <= 2 ? 1 : 2;
    }
    return password.length >= 12 ? 4 : 3;
  }
}

class PasswordRule {
  const PasswordRule(this.label, this.test);

  final String label;
  final bool Function(String password) test;
}

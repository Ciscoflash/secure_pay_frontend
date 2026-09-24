import 'package:flutter/widgets.dart';
import '../models/country_code.dart';
import 'password_policy.dart';
abstract final class Validators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static FormFieldValidator<String> required(String message) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(v)) {
      return 'Enter a valid email, e.g. user@example.com';
    }
    return null;
  }
  static FormFieldValidator<String> phone(CountryCode country) => (value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your phone number';
    if (!country.isValid(v)) {
      return 'Enter a valid ${country.name} number, e.g. ${country.example}';
    }
    return null;
  };
  static String? newPassword(String? value) =>
      PasswordPolicy.validate(value ?? '');
}

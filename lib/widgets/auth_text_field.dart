import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country_code.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'line_icons.dart';
export '../models/country_code.dart';
final _inputTextStyle = AppText.style(
  16,
  color: AppColors.textPrimary,
  height: 1.5,
  letterSpacing: -0.2,
);
final _placeholderStyle = AppText.style(
  16,
  weight: 300,
  color: AppColors.textPlaceholder,
  height: 1.5,
  letterSpacing: -0.2,
);
InputDecoration _decoration({
  required String hint,
  Widget? prefix,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: color),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: _placeholderStyle,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    constraints: const BoxConstraints(minHeight: 48),
    prefixIcon: prefix,
    prefixIconConstraints: const BoxConstraints(minHeight: 46),
    suffixIcon: suffix,
    suffixIconConstraints: const BoxConstraints(minHeight: 46, minWidth: 48),
    errorStyle: AppText.style(13, color: AppColors.error),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error),
  );
}
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
  });
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        style: _inputTextStyle,
        decoration: _decoration(hint: hint),
      ),
    );
  }
}
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.label = 'Password',
    this.controller,
    this.autofillHints = const [AutofillHints.password],
    this.validator,
    this.onFieldSubmitted,
    this.maxLength,
  });
  final String label;
  final TextEditingController? controller;
  final Iterable<String> autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}
class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;
  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label: widget.label,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscured,
        inputFormatters: [
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        autofillHints: widget.autofillHints,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: _inputTextStyle,
        decoration: _decoration(
          hint: 'Enter Password',
          suffix: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: _obscured ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscured = !_obscured),
              icon: EyeIcon(crossedOut: _obscured),
              splashRadius: 20,
            ),
          ),
        ),
      ),
    );
  }
}
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.countryCode,
    required this.onCountryCodeChanged,
    this.controller,
    this.validator,
    this.autovalidateMode,
  });
  final CountryCode countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label: 'Phone Number',
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.telephoneNumberNational],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(countryCode.maxInputLength),
        ],
        autovalidateMode: autovalidateMode,
        validator: validator,
        style: _inputTextStyle,
        decoration: _decoration(
          hint: countryCode.example,
          prefix: PopupMenuButton<CountryCode>(
            tooltip: 'Country code',
            initialValue: countryCode,
            onSelected: onCountryCodeChanged,
            position: PopupMenuPosition.under,
            color: AppColors.surface,
            itemBuilder: (context) => [
              for (final code in countryCodes)
                PopupMenuItem(
                  value: code,
                  child: Text(
                    '${code.dialCode}  ${code.name}',
                    style: AppText.style(14, color: AppColors.textPrimary),
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(countryCode.dialCode, style: _placeholderStyle),
                  const SizedBox(width: 4),
                  const ChevronDownIcon(),
                ],
              ),
            ),
          ),
        ).copyWith(contentPadding: const EdgeInsets.fromLTRB(0, 12, 16, 12)),
      ),
    );
  }
}
class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppText.style(16, color: AppColors.textPrimary, height: 1.5),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

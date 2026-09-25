import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/feedback.dart';
import '../utils/password_policy.dart';
import '../utils/validators.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/inline_link_text.dart';
import '../widgets/password_strength.dart';
import '../widgets/primary_button.dart';
import '../widgets/terms_notice.dart';
import 'routes.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  var _countryCode = countryCodes.first;
  var _autovalidate = AutovalidateMode.disabled;
  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    final success = await _auth.signUp(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      phone: _countryCode.normalize(_phone.text),
      countryCode: _countryCode.dialCode,
      password: _password.text,
    );
    if (!success) {
      showAppSnackbar(
        'Sign up failed',
        _auth.errorMessage.value ?? 'Please try again.',
        error: true,
      );
      return;
    }
    Get.offAllNamed(_auth.isVerified ? Routes.dashboard : Routes.verifyEmail);
  }
  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      panelTitle: 'Seamlessly Delivering to Over 300 Countries from Nigeria!',
      panelBody:
          'Access global markets with our quick shipping from Nigeria! '
          'Fast delivery and easy customs to 300+ countries.',
      form: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Create an account',
                subtitle: InlineLinkText(
                  segments: [
                    const TextSegment(
                      'Sign up for Myafrimall and gain unlimited access to '
                      'shipping to over 300 countries from Nigeria. Do you '
                      'already have an account? ',
                    ),
                    TextSegment.link(
                      'Login',
                      onTap: () => Get.offNamed(Routes.signIn),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthTextField(
                      label: 'First name',
                      hint: 'John',
                      controller: _firstName,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.givenName],
                      validator: Validators.required('Enter your first name'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: AuthTextField(
                      label: 'Last name',
                      hint: 'Doe',
                      controller: _lastName,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.familyName],
                      validator: Validators.required('Enter your last name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AuthTextField(
                label: 'Email',
                hint: 'user@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 28),
              PhoneField(
                controller: _phone,
                countryCode: _countryCode,
                onCountryCodeChanged: (c) => setState(() => _countryCode = c),
                validator: Validators.phone(_countryCode),
              ),
              const SizedBox(height: 28),
              PasswordField(
                controller: _password,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.newPassword,
                maxLength: PasswordPolicy.maxLength,
                onFieldSubmitted: (_) => _submit(),
              ),
              PasswordStrength(controller: _password),
              const SizedBox(height: 40),
              Obx(
                () => PrimaryButton(
                  label: 'Create account',
                  onPressed: _auth.isLoading.value ? null : _submit,
                  isLoading: _auth.isLoading.value,
                ),
              ),
              const SizedBox(height: 24),
              const TermsNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

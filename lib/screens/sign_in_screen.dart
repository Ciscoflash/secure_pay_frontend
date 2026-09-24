import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/validators.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/inline_link_text.dart';
import '../widgets/primary_button.dart';
import '../widgets/terms_notice.dart';
import 'routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    final success = await _auth.signIn(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!success) {
      Get.snackbar(
        'Sign in failed',
        _auth.errorMessage.value ?? 'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.offAllNamed(_auth.isVerified ? Routes.dashboard : Routes.verifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      panelTitle: 'Effortlessly Track Your Shipments from Nigeria!',
      panelBody:
          'Monitor your shipments from Nigeria! Enjoy swift delivery '
          'and seamless customs processing',
      form: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Sign in to your account',
                subtitle: InlineLinkText(
                  segments: [
                    const TextSegment(
                      'Log in to Myafrimall to enjoy seamless shipping to '
                      'over 300 countries right from Nigeria.. Don’t have an '
                      'account yet? ',
                    ),
                    TextSegment.link(
                      'Sign Up',
                      onTap: () => Get.offNamed(Routes.signUp),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                label: 'Email',
                hint: 'user@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 28),
              PasswordField(
                controller: _password,
                validator: Validators.required('Enter your password'),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              InlineLinkText(
                segments: [
                  TextSegment.link(
                    'Forgot Password?',
                    onTap: () {
                      // TODO: forgot-password flow.
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Obx(
                () => PrimaryButton(
                  label: 'Login',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/feedback.dart';
import '../widgets/auth_layout.dart';
import '../widgets/inline_link_text.dart';
import '../widgets/primary_button.dart';
import 'routes.dart';
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}
class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  var _autovalidate = AutovalidateMode.disabled;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _auth.isVerified) {
        Get.offAllNamed(Routes.dashboard);
      }
    });
  }
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    final success = await _auth.verifyEmail(_code.text.trim());
    if (!mounted) return;
    if (!success) {
      showAppSnackbar(
        'Verification failed',
        _auth.errorMessage.value ?? 'Please try again.',
        error: true,
      );
      return;
    }
    Get.offAllNamed(Routes.dashboard);
  }
  Future<void> _resend() async {
    final success = await _auth.resendVerification();
    if (!mounted) return;
    showAppSnackbar(
      success ? 'Code sent' : 'Could not send code',
      success
          ? 'A new verification code was generated and shown below.'
          : _auth.errorMessage.value ?? 'Please try again.',
      error: !success,
    );
  }
  Future<void> _signOut() async {
    await _auth.logout();
    Get.offAllNamed(Routes.signIn);
  }
  void _fillDemoCode(String? code) {
    if (code == null) return;
    _code.text = code;
  }
  @override
  Widget build(BuildContext context) {
    final email = _auth.user?.email ?? '';
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
                title: 'Verify your email',
                subtitle: InlineLinkText(
                  segments: [
                    TextSegment(
                      'We sent a 5-digit code to $email. Enter it below to '
                      'activate your account.',
                    ),
                  ],
                ),
              ),
              Obx(() {
                final code = _auth.demoVerificationCode.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _DemoCodeCard(
                    code: code,
                    onFill: () => _fillDemoCode(code),
                  ),
                );
              }),
              const SizedBox(height: 32),
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                textAlign: TextAlign.center,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  return value.length == 5
                      ? null
                      : 'Enter the 5-digit code from your email';
                },
                style: AppText.style(
                  24,
                  weight: 600,
                  color: AppColors.textPrimary,
                  letterSpacing: 16,
                ),
                decoration: InputDecoration(
                  hintText: '00000',
                  hintStyle: AppText.style(
                    24,
                    weight: 600,
                    color: AppColors.textPlaceholder,
                    letterSpacing: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  errorStyle: AppText.style(13, color: AppColors.error),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The code expires in 24 hours.',
                style: AppText.style(
                  13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () => PrimaryButton(
                  label: 'Verify code',
                  onPressed: _auth.isLoading.value ? null : _submit,
                  isLoading: _auth.isLoading.value,
                ),
              ),
              const SizedBox(height: 24),
              InlineLinkText(
                segments: [
                  const TextSegment("Didn't get it? "),
                  TextSegment.link(
                    'Resend code',
                    onTap: _auth.isLoading.value ? null : _resend,
                  ),
                  const TextSegment('  ·  '),
                  TextSegment.link('Sign out', onTap: _signOut),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _DemoCodeCard extends StatelessWidget {
  const _DemoCodeCard({required this.code, required this.onFill});
  final String? code;
  final VoidCallback onFill;
  @override
  Widget build(BuildContext context) {
    final value = code;
    final hasCode = value != null && value.isNotEmpty;
    return Material(
      color: const Color(0xFFEDEFFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasCode ? onFill : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                hasCode ? Icons.verified_user_outlined : Icons.info_outline,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo mode',
                      style: AppText.style(
                        13,
                        weight: 600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasCode
                          ? 'Your verification code is $code. Tap to use it.'
                          : 'No code in this session. Resend to generate a new one.',
                      style: AppText.style(
                        13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCode) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onFill,
                  child: const Text(
                    'Use code',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.form,
    required this.panelTitle,
    required this.panelBody,
  });
  final Widget form;
  final String panelTitle;
  final String panelBody;
  static const _splitBreakpoint = 900.0;
  static const _formContentWidth = 535.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSplit = constraints.maxWidth >= _splitBreakpoint;
          final formPane = _FormPane(form: form, isSplit: isSplit);
          if (!isSplit) return formPane;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 700, child: formPane),
              Expanded(
                flex: 740,
                child: _BrandPanel(title: panelTitle, body: panelBody),
              ),
            ],
          );
        },
      ),
    );
  }
}
class _FormPane extends StatelessWidget {
  const _FormPane({required this.form, required this.isSplit});
  final Widget form;
  final bool isSplit;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final leftInset = isSplit && width >= 700
            ? 100.0
            : ((width - AuthLayout._formContentWidth) / 2).clamp(24.0, 100.0);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(leftInset, 48, 24, 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AuthLayout._formContentWidth,
                  ),
                  child: form,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/world_map_dots.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),
          ),
          Positioned(
            left: 70,
            right: 70,
            bottom: 156,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    title,
                    style: AppText.style(
                      24,
                      weight: 600,
                      color: Colors.white,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    body,
                    style: AppText.style(
                      18,
                      weight: 300,
                      color: Colors.white,
                      height: 1.65,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});
  final String title;
  final Widget subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppText.style(
              32,
              weight: 700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 436),
          child: subtitle,
        ),
      ],
    );
  }
}

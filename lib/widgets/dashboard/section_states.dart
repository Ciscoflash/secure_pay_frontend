import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

/// Pulsing placeholder shown while a section loads for the first time.
class SectionLoading extends StatefulWidget {
  const SectionLoading({super.key, required this.height});

  final double height;

  @override
  State<SectionLoading> createState() => _SectionLoadingState();
}

class _SectionLoadingState extends State<SectionLoading>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      label: 'Loading',
      child: FadeTransition(
        opacity: reduceMotion
            ? const AlwaysStoppedAnimation(0.7)
            : Tween(begin: 0.45, end: 0.9).animate(_controller),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class SectionError extends StatelessWidget {
  const SectionError({
    super.key,
    required this.message,
    required this.onRetry,
    this.height,
  });

  final String message;
  final VoidCallback onRetry;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height ?? 0),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: AppText.style(14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text('Retry', style: AppText.style(14, weight: 600)),
          ),
        ],
      ),
    );
  }
}

class SectionEmpty extends StatelessWidget {
  const SectionEmpty({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppText.style(16, weight: 500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.style(14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Keeps already-loaded content visible while it refreshes, dimmed, with a
/// small spinner; shows a retry strip if the refresh failed.
class ReloadingOverlay extends StatelessWidget {
  const ReloadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.error,
    this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isLoading ? 0.55 : 1,
              child: child,
            ),
            if (isLoading)
              const Positioned.fill(
                child: Center(
                  child: SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (error != null && onRetry != null) ...[
          const SizedBox(height: 10),
          SectionError(message: error!, onRetry: onRetry!),
        ],
      ],
    );
  }
}

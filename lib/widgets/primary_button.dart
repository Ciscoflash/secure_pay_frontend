import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}
class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool get _enabled => widget.onPressed != null && !widget.isLoading;
  @override
  Widget build(BuildContext context) {
    final (top, bottom) = switch ((_pressed, _hovered)) {
      (true, _) => (AppColors.primary, AppColors.primaryDark),
      (false, true) => (const Color(0xFF6A72AF), const Color(0xFF545D9D)),
      _ => (AppColors.primaryLight, AppColors.primary),
    };
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed?.call(),
          ),
        },
        child: GestureDetector(
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTap: _enabled ? widget.onPressed : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: widget.onPressed == null ? 0.5 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top, bottom],
                ),
                border: Border.all(color: AppColors.primaryDark),
                boxShadow: _pressed
                    ? const []
                    : const [
                        BoxShadow(
                          color: Color(0x1F101828),
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading) ...[
                    const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: AppText.style(14, weight: 500, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// A run of text or an underlined, tappable link inside [InlineLinkText].
class TextSegment {
  const TextSegment(this.text) : onTap = null;
  const TextSegment.link(this.text, {required this.onTap});

  final String text;
  final VoidCallback? onTap;
}

/// Paragraph with inline links, e.g. "Do you already have an account? Login".
class InlineLinkText extends StatefulWidget {
  const InlineLinkText({super.key, required this.segments});

  static final _style = AppText.style(
    14,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: -0.1,
  );

  static final _linkStyle = AppText.style(
    14,
    weight: 600,
    color: AppColors.primary,
    height: 1.5,
    letterSpacing: -0.1,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  final List<TextSegment> segments;

  @override
  State<InlineLinkText> createState() => _InlineLinkTextState();
}

class _InlineLinkTextState extends State<InlineLinkText> {
  final _recognizers = <TapGestureRecognizer>[];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _track(TapGestureRecognizer recognizer) {
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    return Text.rich(
      TextSpan(
        style: InlineLinkText._style,
        children: [
          for (final segment in widget.segments)
            if (segment.onTap == null)
              TextSpan(text: segment.text)
            else
              TextSpan(
                text: segment.text,
                style: InlineLinkText._linkStyle,
                mouseCursor: SystemMouseCursors.click,
                recognizer: _track(
                  TapGestureRecognizer()..onTap = segment.onTap,
                ),
              ),
        ],
      ),
    );
  }
}

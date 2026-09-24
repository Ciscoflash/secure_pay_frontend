import 'package:flutter/material.dart';

import 'inline_link_text.dart';

/// "By clicking on create account you agree to our privacy policy and terms
/// of use" — shared by both auth screens (the copy is identical in both).
class TermsNotice extends StatelessWidget {
  const TermsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: InlineLinkText(
        segments: [
          const TextSegment('By clicking on create account you agree to our '),
          TextSegment.link('privacy policy', onTap: () {}),
          const TextSegment(' and '),
          TextSegment.link('terms of use', onTap: () {}),
        ],
      ),
    );
  }
}

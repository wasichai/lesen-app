import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../domain/known_words.dart';

/// El estado de una palabra con icono y texto (nunca solo color).
class WordStatusBadge extends StatelessWidget {
  const WordStatusBadge(this.status, {super.key});

  final WordStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      WordStatus.SAVED => (Icons.bookmark_outline, LesenTokens.tones[2]),
      WordStatus.LEARNING => (Icons.autorenew, LesenTokens.tones[0]),
      WordStatus.FAMILIAR => (Icons.thumb_up_alt_outlined, LesenTokens.tones[3]),
      WordStatus.MASTERED => (Icons.verified_outlined, LesenTokens.tones[1]),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(LesenTokens.radiusSm)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(context.l10n.wordStatus(status), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

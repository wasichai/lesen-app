import 'package:flutter/material.dart';

import '../../app/l10n.dart';
import '../../app/theme/tokens.dart';
import '../networking/api_failure.dart';

/// Un fallo con su explicación y, si tiene sentido, un botón para reintentar.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.error, this.onRetry, this.compact = false});

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = ApiFailure.from(error);
    final icon = failure is OfflineFailure ? Icons.cloud_off_outlined : Icons.error_outline;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 28 : 40, color: LesenTokens.of(context).inkMuted),
        const SizedBox(height: 12),
        Text(l10n.failure(failure), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        if (onRetry != null) ...[const SizedBox(height: 16), OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry))],
      ],
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(liveRegion: true, child: content),
      ),
    );
  }
}

/// Estado vacío con ilustración tipográfica, título y texto.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body, this.icon = Icons.auto_stories_outlined, this.action});

  final String title;
  final String body;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: t.brandSoft, shape: BoxShape.circle),
                child: Icon(icon, size: 44, color: t.brandStrong),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: t.inkMuted),
              ),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator.adaptive());
}

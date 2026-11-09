import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../catalog/domain/reading.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/domain/learner_profile.dart';
import 'onboarding_steps.dart';

/// Onboarding en cinco pasos cortos. Con `editing`, los mismos pasos para cambiar el perfil.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const steps = 5;
  final _pages = PageController();
  int _step = 0;
  LearnerProfile? _draft;
  bool _saving = false;
  Object? _error;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  LearnerProfile _initialDraft(LanguageCatalog languages) {
    final existing = ref.read(profileProvider).value;
    if (existing != null) return existing;
    final device = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final interfaces = languages.interfaceLanguages.map((l) => l.code).toList();
    final interface = interfaces.contains(device) ? device : (interfaces.firstOrNull ?? 'es');
    final target = languages.studyLanguages.map((l) => l.code).firstWhere((c) => c != interface, orElse: () => 'de');
    return LearnerProfile(
      interfaceLanguage: interface,
      targetLanguage: target,
      level: CefrLevel.A2,
      levelEstimated: true,
      goals: const {},
      topics: const [],
      dailyMinutes: 10,
      difficulty: ReadingDifficulty.BALANCED,
    );
  }

  void _go(int step) {
    setState(() => _step = step);
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _pages.jumpToPage(step);
    } else {
      _pages.animateToPage(step, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(profileProvider.notifier).save(_draft!);
      if (mounted && widget.editing) context.go(Routes.profile);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = ref.watch(languagesProvider);
    return languages.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        body: FailureView(error: e, onRetry: () => ref.invalidate(languagesProvider)),
      ),
      data: (catalog) {
        final draft = _draft ??= _initialDraft(catalog);
        // la interfaz cambia de idioma en cuanto se elige, antes de guardar
        return Localizations.override(
          context: context,
          locale: Locale(draft.interfaceLanguage),
          child: Builder(builder: (context) => _scaffold(context, catalog, draft)),
        );
      },
    );
  }

  Widget _scaffold(BuildContext context, LanguageCatalog catalog, LearnerProfile draft) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    void update(LearnerProfile p) => setState(() => _draft = p);
    final canContinue = switch (_step) {
      1 => draft.targetLanguage != draft.interfaceLanguage,
      _ => true,
    };
    final last = _step == steps - 1;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l10n.commonBack,
                        onPressed: _step == 0 ? (widget.editing ? () => context.go(Routes.profile) : null) : () => _go(_step - 1),
                        icon: Icon(_step == 0 && widget.editing ? Icons.close : Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Semantics(
                          label: l10n.onboardingStep(_step + 1, steps),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(end: (_step + 1) / steps),
                              duration: const Duration(milliseconds: 300),
                              builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: t.surfaceMuted),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.onboardingStep(_step + 1, steps), style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      InterfaceStep(catalog: catalog, draft: draft, onChanged: update),
                      TargetStep(catalog: catalog, draft: draft, onChanged: update),
                      LevelStep(catalog: catalog, draft: draft, onChanged: update),
                      InterestsStep(draft: draft, onChanged: update),
                      HabitStep(draft: draft, onChanged: update),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(l10n.onboardingError, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: !canContinue || _saving ? null : (last ? _finish : () => _go(_step + 1)),
                      child: Text(_saving ? l10n.onboardingSaving : (last ? (widget.editing ? l10n.commonSave : l10n.onboardingFinish) : l10n.commonContinue)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

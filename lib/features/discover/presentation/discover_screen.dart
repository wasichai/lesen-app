import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/routing/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/reading.dart';
import '../../catalog/presentation/widgets/cover_image.dart';
import '../../catalog/presentation/widgets/reading_card_view.dart';
import '../../catalog/presentation/widgets/reading_meta.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/domain/learner_profile.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discover = ref.watch(discoverProvider);
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(discoverProvider.future),
        child: CustomScrollView(
          slivers: [
            _Header(profile: profile),
            ...switch (discover) {
              AsyncData(:final value) when value == null || value.isEmpty => [SliverFillRemaining(hasScrollBody: false, child: _Empty(profile: profile))],
              AsyncData(:final value) => _sections(context, ref, value!, profile),
              AsyncError(:final error) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: FailureView(error: error, onRetry: () => ref.invalidate(discoverProvider)),
                ),
              ],
              _ => [const SliverFillRemaining(child: LoadingView())],
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, WidgetRef ref, Discover d, LearnerProfile? profile) {
    final l10n = context.l10n;
    void open(ReadingCard r) => context.go(Routes.reading(r.slug));
    final hero = d.featured.firstOrNull;
    final locale = profile?.interfaceLanguage ?? Localizations.localeOf(context).languageCode;
    return [
      if (hero != null)
        SliverToBoxAdapter(
          child: _Hero(reading: hero, onTap: () => open(hero)),
        ),
      if (d.continueReading.isNotEmpty) _Carousel(title: l10n.discoverContinue, readings: d.continueReading, onTap: open),
      if (d.recommended.isNotEmpty)
        _Carousel(
          title: l10n.discoverRecommended,
          lead: l10n.discoverRecommendedLead,
          readings: [for (final r in d.recommended) r.reading],
          badges: [for (final r in d.recommended) r.reasons.map(l10n.reason).whereType<String>().firstOrNull],
          onTap: open,
        ),
      if (d.featured.length > 1) _Carousel(title: l10n.discoverFeatured, readings: d.featured.skip(1).toList(), onTap: open),
      if (d.thisWeek.isNotEmpty)
        _Carousel(
          title: l10n.discoverThisWeek,
          readings: [for (final w in d.thisWeek) w.$1],
          badges: [for (final w in d.thisWeek) l10n.readersThisWeek(w.$2)],
          onTap: open,
        ),
      if (d.fresh.isNotEmpty) _Carousel(title: l10n.discoverFresh, readings: d.fresh, onTap: open),
      for (final c in d.collections)
        if (c.readings.isNotEmpty)
          _Carousel(title: c.labels[locale] ?? c.labels.values.firstOrNull ?? c.slug, lead: c.descriptions[locale], readings: c.readings, onTap: open),
      if (d.topics.isNotEmpty)
        SliverToBoxAdapter(
          child: _TopicsSection(topics: d.topics, locale: locale),
        ),
      SliverToBoxAdapter(child: _LevelsSection(language: profile?.targetLanguage)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: OutlinedButton.icon(onPressed: () => context.go(Routes.catalog), icon: const Icon(Icons.search), label: Text(l10n.discoverCatalog)),
        ),
      ),
    ];
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.profile});

  final LearnerProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final user = ref.watch(sessionControllerProvider.select((s) => s.session?.user));
    // clock y no DateTime: los goldens fijan la hora para que el saludo no dependa de cuándo se ejecutan
    final hour = clock.now().hour;
    final greeting = hour < 12 ? l10n.greetingMorning : (hour < 20 ? l10n.greetingAfternoon : l10n.greetingEvening);
    final languageName = profile == null ? null : ref.watch(languagesProvider).value?.nameOf(profile!.targetLanguage);
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(user == null ? greeting : l10n.greetingNamed(greeting, user.firstName), style: text.headlineLarge)),
                    if (profile != null && languageName != null) ...[
                      const SizedBox(height: 6),
                      Text(l10n.discoverLead(languageName, profile!.dailyMinutes), style: text.bodyLarge?.copyWith(color: t.inkMuted)),
                    ],
                  ],
                ),
              ),
              IconButton(tooltip: l10n.navSearch, onPressed: () => context.go(Routes.catalog), icon: const Icon(Icons.search)),
              IconButton(tooltip: l10n.dictTitle, onPressed: () => context.push(Routes.dictionary), icon: const Icon(Icons.translate)),
              IconButton(tooltip: l10n.navProfile, onPressed: () => context.push(Routes.profile), icon: const Icon(Icons.account_circle_outlined)),
            ],
          ),
        ),
      ),
    );
  }
}

/// La lectura destacada, grande: en tableta, portada y texto lado a lado.
class _Hero extends StatelessWidget {
  const _Hero({required this.reading, required this.onTap});

  final ReadingCard reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.discoverFeatured.toUpperCase(), style: text.labelMedium?.copyWith(color: t.brand, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(reading.title, style: text.headlineMedium, locale: Locale(reading.language)),
        if (reading.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            reading.subtitle!,
            style: text.titleMedium?.copyWith(color: t.inkMuted, fontWeight: FontWeight.w400),
            locale: Locale(reading.language),
          ),
        ],
        const SizedBox(height: 10),
        Text(reading.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: text.bodyMedium, locale: Locale(reading.language)),
        const SizedBox(height: 12),
        ReadingMetaLine(reading),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Semantics(
        button: true,
        child: Material(
          color: t.surfaceRaised,
          borderRadius: BorderRadius.circular(t.radiusXl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: LayoutBuilder(
              builder: (context, c) => c.maxWidth >= 640
                  ? Row(
                      children: [
                        SizedBox(
                          width: c.maxWidth * 0.48,
                          child: CoverImage(reading: reading, radius: 0),
                        ),
                        Expanded(
                          child: Padding(padding: const EdgeInsets.all(24), child: info),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CoverImage(reading: reading, radius: 0, aspectRatio: 16 / 10),
                        Padding(padding: const EdgeInsets.all(18), child: info),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.lead});

  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: text.headlineSmall)),
          if (lead != null) ...[const SizedBox(height: 4), Text(lead!, style: text.bodyMedium?.copyWith(color: LesenTokens.of(context).inkMuted))],
        ],
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({required this.title, this.lead, required this.readings, this.badges, required this.onTap});

  final String title;
  final String? lead;
  final List<ReadingCard> readings;
  final List<String?>? badges;
  final void Function(ReadingCard) onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width >= 900 ? 280.0 : (width >= 600 ? 260.0 : 232.0);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, lead: lead),
          SizedBox(
            height: cardWidth * 3 / 4 + 172 * scale,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: readings.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => SizedBox(
                width: cardWidth,
                child: ReadingCardView(reading: readings[i], badge: badges?[i], onTap: () => onTap(readings[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicsSection extends ConsumerWidget {
  const _TopicsSection({required this.topics, required this.locale});

  final List<TopicCount> topics;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tree = ref.watch(topicsProvider).value ?? const <Topic>[];
    final labels = <String, String>{};
    void walk(List<Topic> ts) {
      for (final t in ts) {
        labels[t.slug] = t.label(locale);
        walk(t.children);
      }
    }

    walk(tree);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.discoverTopics),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, topic) in topics.indexed)
                ActionChip(
                  avatar: CircleAvatar(backgroundColor: LesenTokens.of(context).tones[i % LesenTokens.of(context).tones.length], radius: 6),
                  label: Text('${labels[topic.slug] ?? topic.slug} · ${topic.readings}'),
                  tooltip: l10n.readingsCount(topic.readings),
                  onPressed: () => context.go(Routes.catalogWith(topic: topic.slug)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelsSection extends StatelessWidget {
  const _LevelsSection({required this.language});

  final String? language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.discoverLevels),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: CefrLevel.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final level = CefrLevel.values[i];
              return Semantics(
                button: true,
                label: '${level.name}. ${l10n.levelDescription(level)}',
                excludeSemantics: true,
                child: Material(
                  color: Color.lerp(t.brandSoft, t.surfaceRaised, i / 6),
                  borderRadius: BorderRadius.circular(t.radiusLg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(t.radiusLg),
                    onTap: () => context.go(Routes.catalogWith(level: level.name, language: language)),
                    child: SizedBox(
                      width: 168,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(level.name, style: text.headlineSmall?.copyWith(color: t.brandStrong)),
                            const SizedBox(height: 2),
                            Expanded(
                              child: Text(l10n.levelDescription(level), maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty({required this.profile});

  final LearnerProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = profile == null ? '' : (ref.watch(languagesProvider).value?.nameOf(profile!.targetLanguage) ?? profile!.targetLanguage);
    return EmptyState(
      title: l10n.discoverEmpty(name),
      body: l10n.discoverEmptyBody,
      action: OutlinedButton(onPressed: () => context.go(Routes.catalog), child: Text(l10n.discoverCatalog)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/connectivity/connectivity.dart';
import '../../../core/widgets/lesen_mark.dart';
import '../../audio/presentation/mini_player.dart';

/// Ancho a partir del cual se usa la composición de tableta.
const tabletBreakpoint = 600.0;

/// Armazón con las cuatro ramas: barra inferior en teléfono, raíl de navegación en tableta.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _select(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final wide = MediaQuery.sizeOf(context).width >= tabletBreakpoint;
    final destinations = [
      (Icons.explore_outlined, Icons.explore, l10n.navDiscover),
      (Icons.auto_stories_outlined, Icons.auto_stories, l10n.navLibrary),
      (Icons.style_outlined, Icons.style, l10n.navVocabulary),
      (Icons.insights_outlined, Icons.insights, l10n.navProgress),
    ];
    final offline = ref.watch(onlineProvider).value == false;
    final body = Column(
      children: [
        if (offline) const _OfflineBanner(),
        Expanded(child: shell),
        const MiniPlayer(),
      ],
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.85,
              leading: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: LesenMark(size: 40)),
              destinations: [for (final d in destinations) NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3))],
            ),
            VerticalDivider(width: 1, color: LesenTokens.of(context).surfaceMuted),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _select,
        destinations: [for (final d in destinations) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3)],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final t = LesenTokens.of(context);
    return Semantics(
      liveRegion: true,
      child: Material(
        color: t.surfaceMuted,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.cloud_off_outlined, size: 18, color: t.inkMuted),
                const SizedBox(width: 8),
                Expanded(child: Text(context.l10n.offlineBanner, style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

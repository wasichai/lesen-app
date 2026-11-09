import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../core/widgets/feedback_views.dart';

/// Lo que llega en una fase siguiente, dicho con claridad: no hay datos simulados detrás.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen._(this._kind);

  const ComingSoonScreen.progress() : this._(_Kind.progress);

  final _Kind _kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, body, icon) = switch (_kind) {
      _Kind.progress => (l10n.navProgress, l10n.progressComingSoon, Icons.insights_outlined),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(title: l10n.comingSoonTitle, body: body, icon: icon),
    );
  }
}

enum _Kind { progress }

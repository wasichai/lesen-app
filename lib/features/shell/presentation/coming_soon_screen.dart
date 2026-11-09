import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../core/widgets/feedback_views.dart';

/// Lo que llega en una fase siguiente, dicho con claridad: no hay datos simulados detrás.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen._(this._kind, {this.slug});

  const ComingSoonScreen.library() : this._(_Kind.library);
  const ComingSoonScreen.vocabulary() : this._(_Kind.vocabulary);
  const ComingSoonScreen.progress() : this._(_Kind.progress);
  const ComingSoonScreen.reader({required String slug}) : this._(_Kind.reader, slug: slug);

  final _Kind _kind;
  final String? slug;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, body, icon) = switch (_kind) {
      _Kind.library => (l10n.navLibrary, l10n.libraryComingSoon, Icons.auto_stories_outlined),
      _Kind.vocabulary => (l10n.navVocabulary, l10n.vocabularyComingSoon, Icons.style_outlined),
      _Kind.progress => (l10n.navProgress, l10n.progressComingSoon, Icons.insights_outlined),
      _Kind.reader => (l10n.comingSoonTitle, l10n.readerComingSoon, Icons.menu_book_outlined),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(title: l10n.comingSoonTitle, body: body, icon: icon),
    );
  }
}

enum _Kind { library, vocabulary, progress, reader }

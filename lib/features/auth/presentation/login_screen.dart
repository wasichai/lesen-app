import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/networking/api_failure.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/lesen_mark.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionControllerProvider.notifier).signIn(_email.text, _password.text);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(
        () => _error = switch (e) {
          UnauthorizedFailure() || ValidationFailure() => l10n.loginInvalid,
          RateLimitedFailure() => l10n.loginTooMany,
          _ => l10n.failure(e),
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = LesenTokens.of(context);
    final text = Theme.of(context).textTheme;
    final expired = ref.watch(sessionControllerProvider.select((s) => s.reason == SignOutReason.expired));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(alignment: Alignment.centerLeft, child: LesenMark(size: 56)),
                      const SizedBox(height: 28),
                      Text(l10n.loginTitle, style: text.displaySmall),
                      const SizedBox(height: 10),
                      Text(l10n.loginLead, style: text.bodyLarge?.copyWith(color: t.inkMuted)),
                      const SizedBox(height: 32),
                      if (expired && _error == null) _Notice(text: l10n.sessionExpired, color: t.brandSoft),
                      if (_error != null) _Notice(text: _error!, color: t.brandSoft, live: true),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email, AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: InputDecoration(labelText: l10n.loginEmail),
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.loginEmailRequired : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: l10n.loginPassword,
                          suffixIcon: IconButton(
                            tooltip: _obscure ? l10n.loginShowPassword : l10n.loginHidePassword,
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? l10n.loginPasswordRequired : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5)) : Text(l10n.loginSubmit),
                      ),
                      const SizedBox(height: 20),
                      Text(l10n.loginNoAccount, textAlign: TextAlign.center, style: text.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.color, this.live = false});

  final String text;
  final Color color;
  final bool live;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Semantics(
      liveRegion: live,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(LesenTokens.of(context).radiusMd)),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: LesenTokens.of(context).brandStrong),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/auth/auth_provider.dart';
import 'package:thaqafa/features/auth/auth_state.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/thaqafa_mark.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    await ref.read(authProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
    if (!mounted) return;
    final s = ref.read(authProvider);
    if (s.hasError) {
      setState(() {
        _submitting = false;
        _error = s.error.toString();
      });
    } else if (s.value is AuthSignedIn) {
      context.go(AppRoutes.today);
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(backgroundColor: t.paper),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          children: [
            const Center(child: ThaqafaMark(size: 56)),
            const SizedBox(height: 18),
            Text(
              i18n.auth.sign_in_title,
              textAlign: TextAlign.center,
              style: ThaqafaTypography.serif(
                size: 30,
                color: t.ink,
                weight: FontWeight.w500,
                height: 1.05,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 28),
            _Field(label: i18n.auth.email, controller: _email, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _Field(label: i18n.auth.password, controller: _password, obscure: true),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: ThaqafaTypography.serif(size: 14, color: t.warn, style: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 22),
            _SubmitButton(
              label: i18n.auth.sign_in,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.signUp),
                child: Text(
                  i18n.auth.no_account_cta.toUpperCase(),
                  style: ThaqafaTypography.mono(
                    size: 11,
                    color: t.accent,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ThaqafaTypography.mono(
            size: 10.5,
            color: t.inkMute,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: t.rule, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            autocorrect: false,
            enableSuggestions: false,
            style: ThaqafaTypography.serif(size: 18, color: t.ink),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: t.ink,
          foregroundColor: t.paper,
          disabledBackgroundColor: t.inkMute,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          label.toUpperCase(),
          style: ThaqafaTypography.mono(
            size: 12,
            color: t.paper,
            letterSpacing: 1.6,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

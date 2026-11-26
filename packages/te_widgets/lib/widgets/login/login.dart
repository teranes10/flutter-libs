import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// What the first field of [TLogin] asks for.
enum TLoginIdentifier { username, email }

/// A full-screen sign-in page: icon, title, subtitle, username or email, password and a submit button.
///
/// [onLogin] does the signing in: return `null` on success, or the message to show on failure. Thrown errors are
/// shown too. Update `status` to change the button's loading text while a long login runs (e.g. 'Syncing data...').
///
/// ```dart
/// TLogin(
///   title: 'POS System',
///   subtitle: 'Sign in to continue',
///   icon: HugeIcons.strokeRoundedCashier02,
///   identifier: TLoginIdentifier.email,
///   onLogin: (email, password, status) async {
///     final error = await auth.login(email, password);
///     if (error == null && context.mounted) context.go('/');
///     return error;
///   },
/// )
/// ```
class TLogin extends StatefulWidget {
  final String title;
  final String? subtitle;

  /// Shown above the title; anything [TIcon.raw] accepts (HugeIcon data or [IconData]).
  final dynamic icon;

  /// Whether the user signs in with a username or an email address.
  final TLoginIdentifier identifier;

  final Future<String?> Function(String identifier, String password, ValueNotifier<String> status) onLogin;

  const TLogin({
    super.key,
    required this.title,
    required this.onLogin,
    this.subtitle,
    this.icon,
    this.identifier = TLoginIdentifier.username,
  });

  @override
  State<TLogin> createState() => _TLoginState();
}

class _TLoginState extends State<TLogin> {
  static const _loadingText = 'Logging in...';

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _status = ValueNotifier<String>(_loadingText);
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  bool get _isEmail => widget.identifier == TLoginIdentifier.email;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _status.dispose();
    super.dispose();
  }

  String? _validate(String identifier, String password) {
    if (identifier.isEmpty || password.isEmpty) return 'Please enter your ${_isEmail ? 'email' : 'username'} and password';
    if (!_isEmail) return null;
    final error = Validations.email()(identifier);
    return error.isEmpty ? null : error;
  }

  Future<void> _submit([TButtonPressOptions? options]) async {
    // Enter on the password field can fire while a login is already running.
    if (_isLoading) return;

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    final invalid = _validate(identifier, password);
    if (invalid != null) {
      setState(() => _error = invalid);
      options?.stopLoading();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    _status.value = _loadingText;

    String? error;
    try {
      error = await widget.onLogin(identifier, password, _status);
      // Lets the browser / password manager offer to save the credentials.
      if (error == null) TextInput.finishAutofillContext();
    } catch (e) {
      error = 'Login failed: $e';
    }

    // onLogin may have navigated away, disposing this page.
    if (!mounted) return;
    options?.stopLoading();
    setState(() {
      _isLoading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final glass = TGlassStyle.resolve(context) != null;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final form = AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.icon != null) ...[
            Center(child: TIcon.raw(widget.icon, size: 80, color: colors.onSurfaceVariant)),
            const SizedBox(height: 16),
          ],
          Text(widget.title, textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(widget.subtitle!, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ],
          const SizedBox(height: 48),
          if (_error != null) TBanner(type: TBannerType.error, message: _error, margin: const EdgeInsets.only(bottom: 16)),
          TTextField<String>(
            key: const Key('login_identifier_field'),
            textController: _identifierController,
            label: _isEmail ? 'Email' : 'Username',
            preWidget: TIcon.raw(_isEmail ? HugeIcons.strokeRoundedMail01 : HugeIcons.strokeRoundedUser),
            disabled: _isLoading,
            textInputAction: TextInputAction.next,
            keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.text,
            autofillHints: [_isEmail ? AutofillHints.email : AutofillHints.username],
          ),
          const SizedBox(height: 16),
          TTextField<String>(
            key: const Key('login_password_field'),
            textController: _passwordController,
            label: 'Password',
            preWidget: TIcon.raw(HugeIcons.strokeRoundedSquareLockPassword),
            postWidget: TButton(
              size: TSize.xxs.copyWith(icon: 16),
              type: TButtonType.icon,
              icon: _obscurePassword ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOff,
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            obscureText: _obscurePassword,
            disabled: _isLoading,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          TButton(
            key: const Key('login_submit_button'),
            type: TButtonType.solid,
            size: TButtonSize.lg.copyWith(minW: double.infinity),
            onPressed: _submit,
            loading: true,
            loadingNotifier: _status,
            text: 'Sign In',
          ),
        ],
      ),
    );

    final scaffold = Scaffold(
      backgroundColor: glass ? Colors.transparent : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            // Glass mode: a frosted pane behind the form.
            child: glass
                ? TGlassSurface.wrap(
                    context,
                    radius: BorderRadius.circular(24),
                    color: colors.surface,
                    child: Padding(padding: const EdgeInsets.all(28), child: form),
                  )
                : form,
          ),
        ),
      ),
    );
    return glass ? TGlassBackground(child: scaffold) : scaffold;
  }
}

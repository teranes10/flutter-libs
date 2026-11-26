import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Opens [TLogin] full screen. Any credentials work; the password `wrong` shows the error state.
class LoginSamplePage extends StatelessWidget {
  const LoginSamplePage({super.key});

  void _open(BuildContext context, TLoginIdentifier identifier) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => Stack(
          children: [
            TLogin(
              title: 'POS System',
              subtitle: 'Sign in to continue',
              icon: HugeIcons.strokeRoundedCashier02,
              identifier: identifier,
              onLogin: (user, password, status) async {
                await Future<void>.delayed(const Duration(seconds: 1));
                if (password == 'wrong') return 'Invalid login.';
                status.value = 'Syncing data...';
                await Future<void>.delayed(const Duration(seconds: 1));
                if (context.mounted) {
                  TToastService.success(context, 'Signed in as $user');
                  Navigator.of(context).pop();
                }
                return null;
              },
            ),
            const Positioned(
              top: 16,
              left: 16,
              child: Material(type: MaterialType.transparency, child: BackButton()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Use any credentials to sign in. Enter the password "wrong" to see the error state.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TButton(text: 'Username login', onTap: () => _open(context, TLoginIdentifier.username)),
              TButton(text: 'Email login', type: TButtonType.tonal, onTap: () => _open(context, TLoginIdentifier.email)),
            ],
          ),
        ],
      ),
    );
  }
}

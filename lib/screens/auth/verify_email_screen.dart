import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Shown until the user clicks the verification link sent to their ALU email.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Icon(Icons.mark_email_unread_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Verify your email', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('We sent a verification link to\n${auth.user?.email ?? ''}.\nOpen it, then come back here.',
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () async {
                final ok = await context.read<AuthProvider>().checkVerified();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Not verified yet. Check your inbox.')));
                }
              },
              child: const Text("I've verified my email"),
            ),
            OutlinedButton(
              onPressed: auth.busy
                  ? null
                  : () async {
                      final ok = await context.read<AuthProvider>().resendVerification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Verification email sent.' : (auth.error ?? 'Could not send email.'))));
                      }
                    },
              child: const Text('Resend email'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
              },
              child: const Text('Use a different account'),
            ),
          ]),
        ),
      ),
    );
  }
}

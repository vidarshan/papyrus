import 'package:firebase_auth/firebase_auth.dart';
import 'package:papyrus/authentication/Login.dart';
import 'package:papyrus/ui/ui.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        PapyrusPageRoute(
          settings: const RouteSettings(name: '/login'),
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return PapyrusScaffold(
      title: 'Profile',
      padHorizontal: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user?.email != null)
            PapyrusText(
              user!.email!,
              variant: PTextVariant.body,
              color: theme.textSecondary,
              align: TextAlign.center,
            ),
          const SizedBox(height: 32),
          PapyrusButton(
            label: 'Log Out',
            variant: PButtonVariant.subtle,
            color: theme.error,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

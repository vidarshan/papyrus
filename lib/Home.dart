import 'package:firebase_auth/firebase_auth.dart';
import 'package:papyrus/ui/ui.dart';

import 'authentication/Login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
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
    return PapyrusScaffold(
      padHorizontal: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PapyrusButton(
              label: 'Log Out',
              variant: PButtonVariant.subtle,
              color: theme.error,
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

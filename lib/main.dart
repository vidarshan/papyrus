import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:papyrus/authentication/Login.dart';
import 'package:papyrus/authentication/Register.dart';
import 'package:papyrus/navigation/MainTabScreen.dart';
import 'package:papyrus/ui/ui.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PapyrusApp(
      title: 'Papyrus',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PapyrusScaffold(
              body: Center(child: PapyrusLoader(size: 28)),
            );
          }
          if (snapshot.hasData) {
            return const MainTabScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegisterScreen(),
        '/home': (context) => const MainTabScreen(),
      },
    );
  }
}

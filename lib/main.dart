import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:papyrus/authentication/Login.dart';
import 'package:papyrus/authentication/Register.dart';
import 'package:papyrus/navigation/MainTabScreen.dart';
import 'package:papyrus/providers/theme_controller.dart';
import 'package:papyrus/ui/ui.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeController = ThemeController();
    _themeController.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Reacts to the OS theme changing while the app is open and the user's
  // preference is "system" - ThemeController itself only recomputes on its
  // own notifyListeners(), which a platform brightness change doesn't touch.
  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _themeController,
      child: Consumer<ThemeController>(
        builder: (context, controller, _) {
          final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
          return PapyrusApp(
            title: 'Papyrus',
            theme: controller.resolve(brightness),
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
        },
      ),
    );
  }
}

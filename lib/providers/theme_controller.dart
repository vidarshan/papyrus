import 'package:papyrus/ui/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PapyrusThemeMode { light, dark, system }

/// Holds the user's preferred theme mode (persisted locally so it survives
/// restarts) and resolves it against the current [Brightness] when set to
/// [PapyrusThemeMode.system].
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  PapyrusThemeMode mode = PapyrusThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    mode = PapyrusThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => PapyrusThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setMode(PapyrusThemeMode newMode) async {
    mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newMode.name);
  }

  PapyrusThemeData resolve(Brightness platformBrightness) {
    final effective = mode == PapyrusThemeMode.system
        ? (platformBrightness == Brightness.dark
              ? PapyrusThemeMode.dark
              : PapyrusThemeMode.light)
        : mode;
    return effective == PapyrusThemeMode.dark
        ? PapyrusThemeData.dark
        : PapyrusThemeData.light;
  }
}

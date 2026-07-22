import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// Semantic color/typography values consumed by every Papyrus UI component.
class PapyrusThemeData {
  final Color primary;
  final Color primaryHover;
  final Color primaryText;
  final Color background;
  final Color surface;
  final Color border;
  final Color borderFocus;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color error;
  final Color success;
  final String fontFamily;

  const PapyrusThemeData({
    required this.primary,
    required this.primaryHover,
    required this.primaryText,
    required this.background,
    required this.surface,
    required this.border,
    required this.borderFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.error,
    required this.success,
    required this.fontFamily,
  });

  static final PapyrusThemeData light = PapyrusThemeData(
    primary: PColors.primary[6],
    primaryHover: PColors.primary[7],
    primaryText: PColors.white,
    background: PColors.white,
    surface: PColors.white,
    border: PColors.gray[3],
    borderFocus: PColors.primary[6],
    textPrimary: PColors.gray[9],
    textSecondary: PColors.gray[6],
    textDisabled: PColors.gray[4],
    error: PColors.red[7],
    success: PColors.green[7],
    fontFamily: GoogleFonts.notoSerif().fontFamily!,
  );
}

class PapyrusTheme extends InheritedWidget {
  final PapyrusThemeData data;

  const PapyrusTheme({super.key, required this.data, required super.child});

  static PapyrusThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<PapyrusTheme>();
    return theme?.data ?? PapyrusThemeData.light;
  }

  @override
  bool updateShouldNotify(PapyrusTheme oldWidget) => data != oldWidget.data;
}

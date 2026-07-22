import 'package:flutter/widgets.dart';
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
    // Tinted off-white rather than pure white, so surfaces (cards, sheets)
    // sitting on top of it in the same white actually read as raised instead
    // of blending into the page.
    background: PColors.gray[0],
    surface: PColors.white,
    border: PColors.gray[3],
    borderFocus: PColors.primary[6],
    textPrimary: PColors.gray[9],
    textSecondary: PColors.gray[6],
    textDisabled: PColors.gray[4],
    error: PColors.red[7],
    success: PColors.green[7],
    fontFamily: 'Plus Jakarta Sans',
  );

  // Surface sits one step lighter than background (rather than the other
  // way round, like light mode) so cards still visibly lift off the page.
  // Error/success move to lighter shades of the same scale since the dark
  // shades used in light mode read as too low-contrast on a dark surface.
  static final PapyrusThemeData dark = PapyrusThemeData(
    primary: PColors.primary[6],
    primaryHover: PColors.primary[7],
    primaryText: PColors.white,
    background: PColors.gray[9],
    surface: PColors.gray[8],
    border: PColors.gray[7],
    borderFocus: PColors.primary[4],
    textPrimary: PColors.gray[0],
    textSecondary: PColors.gray[4],
    textDisabled: PColors.gray[6],
    error: PColors.red[5],
    success: PColors.green[5],
    fontFamily: 'Plus Jakarta Sans',
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

import 'package:flutter/widgets.dart';

/// Design tokens for the Papyrus UI kit, modeled after Mantine's
/// 10-shade color scales and spacing/radius scale conventions.
class PColors {
  PColors._();

  static const List<Color> gray = [
    Color(0xFFF8F9FA),
    Color(0xFFF1F3F5),
    Color(0xFFE9ECEF),
    Color(0xFFDEE2E6),
    Color(0xFFCED4DA),
    Color(0xFFADB5BD),
    Color(0xFF868E96),
    Color(0xFF495057),
    Color(0xFF343A40),
    Color(0xFF212529),
  ];

  static const List<Color> primary = [
    Color(0xFFEDF2FF),
    Color(0xFFDBE4FF),
    Color(0xFFBAC8FF),
    Color(0xFF91A7FF),
    Color(0xFF748FFC),
    Color(0xFF5C7CFA),
    Color(0xFF4C6EF5),
    Color(0xFF4263EB),
    Color(0xFF3B5BDB),
    Color(0xFF364FC7),
  ];

  static const List<Color> red = [
    Color(0xFFFFF5F5),
    Color(0xFFFFE3E3),
    Color(0xFFFFC9C9),
    Color(0xFFFFA8A8),
    Color(0xFFFF8787),
    Color(0xFFFF6B6B),
    Color(0xFFFA5252),
    Color(0xFFF03E3E),
    Color(0xFFE03131),
    Color(0xFFC92A2A),
  ];

  static const List<Color> green = [
    Color(0xFFEBFBEE),
    Color(0xFFD3F9D8),
    Color(0xFFB2F2BB),
    Color(0xFF8CE99A),
    Color(0xFF69DB7C),
    Color(0xFF51CF66),
    Color(0xFF40C057),
    Color(0xFF37B24D),
    Color(0xFF2F9E44),
    Color(0xFF2B8A3E),
  ];

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

class PRadius {
  PRadius._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class PSpacing {
  PSpacing._();
  static const double xs = 10;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 32;
}

class PFontSize {
  PFontSize._();
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 28;
}

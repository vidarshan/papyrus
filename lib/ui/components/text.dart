import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';

enum PTextVariant { title, subtitle, body, caption }

/// Typography helper covering the handful of text styles the app needs.
class PapyrusText extends StatelessWidget {
  const PapyrusText(
    this.data, {
    super.key,
    this.variant = PTextVariant.body,
    this.color,
    this.align,
    this.weight,
    this.size,
  });

  final String data;
  final PTextVariant variant;
  final Color? color;
  final TextAlign? align;
  final FontWeight? weight;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    late double defaultSize;
    late FontWeight defaultWeight;
    late Color defaultColor;

    switch (variant) {
      case PTextVariant.title:
        defaultSize = PFontSize.xxl;
        defaultWeight = FontWeight.w700;
        defaultColor = theme.textPrimary;
        break;
      case PTextVariant.subtitle:
        defaultSize = PFontSize.lg;
        defaultWeight = FontWeight.w500;
        defaultColor = theme.textPrimary;
        break;
      case PTextVariant.body:
        defaultSize = PFontSize.md;
        defaultWeight = FontWeight.normal;
        defaultColor = theme.textPrimary;
        break;
      case PTextVariant.caption:
        defaultSize = PFontSize.xs;
        defaultWeight = FontWeight.normal;
        defaultColor = theme.textSecondary;
        break;
    }

    return Text(
      data,
      textAlign: align,
      style: TextStyle(
        fontFamily: theme.fontFamily,
        fontSize: size ?? defaultSize,
        fontWeight: weight ?? defaultWeight,
        color: color ?? defaultColor,
        height: 1.3,
      ),
    );
  }
}

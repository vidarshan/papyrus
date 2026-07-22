import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';

/// A small pill-shaped label, matching Mantine's Badge (light variant).
class PapyrusBadge extends StatelessWidget {
  const PapyrusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final base = color ?? theme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PRadius.xl),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: theme.fontFamily,
          color: base,
          fontSize: PFontSize.xs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

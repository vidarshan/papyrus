import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';

/// A Mantine-style Card: surface with border, radius and padding.
class PapyrusCard extends StatelessWidget {
  const PapyrusCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PSpacing.md),
    this.radius = PRadius.md,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: PColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

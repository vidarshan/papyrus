import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'text.dart';

enum PAlertVariant { error, success, info }

/// An inline banner for form/network errors, matching Mantine's Alert.
class PapyrusAlert extends StatelessWidget {
  const PapyrusAlert({
    super.key,
    required this.message,
    this.title,
    this.variant = PAlertVariant.error,
  });

  final String message;
  final String? title;
  final PAlertVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final color = switch (variant) {
      PAlertVariant.error => theme.error,
      PAlertVariant.success => theme.success,
      PAlertVariant.info => theme.primary,
    };

    return Container(
      padding: const EdgeInsets.all(PSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            PapyrusText(title!, variant: PTextVariant.body, weight: FontWeight.w600, color: color),
            const SizedBox(height: 2),
          ],
          PapyrusText(message, variant: PTextVariant.caption, color: color),
        ],
      ),
    );
  }
}

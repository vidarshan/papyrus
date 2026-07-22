import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'button.dart';
import 'text.dart';

/// A centered modal dialog with a title, message and action buttons,
/// built on [showGeneralDialog] rather than Material/Cupertino dialogs.
class PapyrusDialog extends StatelessWidget {
  const PapyrusDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'OK',
    this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(PSpacing.lg),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(PRadius.md),
          boxShadow: [
            BoxShadow(
              color: PColors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PapyrusText(title, variant: PTextVariant.subtitle),
            const SizedBox(height: 8),
            PapyrusText(message, variant: PTextVariant.body, color: theme.textSecondary),
            const SizedBox(height: 20),
            PapyrusButton(
              label: confirmLabel,
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPapyrusDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'OK',
  VoidCallback? onConfirm,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: const Color(0x66000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PapyrusDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

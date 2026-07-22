import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'button.dart';
import 'text.dart';

/// A centered modal dialog with a title, optional message/custom content and
/// action buttons, built on [showGeneralDialog] rather than Material/
/// Cupertino dialogs.
class PapyrusDialog extends StatelessWidget {
  const PapyrusDialog({
    super.key,
    required this.title,
    this.message,
    this.child,
    this.confirmLabel = 'OK',
    this.cancelLabel,
    this.destructive = false,
    this.onConfirm,
  });

  final String title;
  final String? message;
  final Widget? child;
  final String confirmLabel;
  final String? cancelLabel;
  final bool destructive;
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
            if (message != null) ...[
              const SizedBox(height: 8),
              PapyrusText(
                message!,
                variant: PTextVariant.body,
                color: theme.textSecondary,
              ),
            ],
            if (child != null) ...[const SizedBox(height: 16), child!],
            const SizedBox(height: 20),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: PapyrusButton(
                      label: cancelLabel!,
                      variant: PButtonVariant.subtle,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: PSpacing.sm),
                ],
                Expanded(
                  child: PapyrusButton(
                    label: confirmLabel,
                    color: destructive ? theme.error : null,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
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
  String? message,
  Widget? child,
  String confirmLabel = 'OK',
  String? cancelLabel,
  bool destructive = false,
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
        cancelLabel: cancelLabel,
        destructive: destructive,
        onConfirm: onConfirm,
        child: child,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

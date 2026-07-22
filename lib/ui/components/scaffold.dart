import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'text.dart';

/// A minimal page scaffold: optional top bar + safe-area body, replacing
/// CupertinoPageScaffold / Material Scaffold.
class PapyrusScaffold extends StatelessWidget {
  const PapyrusScaffold({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions = const [],
    this.padHorizontal = false,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool padHorizontal;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    return ColoredBox(
      color: theme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: PSpacing.md),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.border)),
                ),
                child: Row(
                  children: [
                    ?leading,
                    Expanded(
                      child: PapyrusText(
                        title!,
                        variant: PTextVariant.subtitle,
                        align: leading == null ? TextAlign.start : TextAlign.center,
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
            Expanded(
              child: padHorizontal
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg),
                      child: body,
                    )
                  : body,
            ),
          ],
        ),
      ),
    );
  }
}

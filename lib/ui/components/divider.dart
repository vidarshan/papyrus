import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';

/// A simple 1px horizontal rule matching Mantine's Divider.
class PapyrusDivider extends StatelessWidget {
  const PapyrusDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    return Container(height: 1, color: theme.border);
  }
}

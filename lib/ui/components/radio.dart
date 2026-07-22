import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'text.dart';

/// A single Mantine-style Radio button. Compose several with the same
/// [groupValue]/[onChanged] to form a radio group.
class PapyrusRadio<T> extends StatelessWidget {
  const PapyrusRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = 20,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final double size;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final disabled = onChanged == null;
    final color = disabled ? PColors.gray[4] : theme.primary;

    return MouseRegion(
      cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => onChanged!(value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.surface,
                border: Border.all(
                  color: _selected ? color : theme.border,
                  width: 1.5,
                ),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: _selected ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.all(size * 0.24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              PapyrusText(label!, variant: PTextVariant.body),
            ],
          ],
        ),
      ),
    );
  }
}

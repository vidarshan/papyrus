import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'text.dart';

/// A Mantine-style Checkbox with a hand-painted check mark.
class PapyrusCheckbox extends StatelessWidget {
  const PapyrusCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = 20,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final disabled = onChanged == null;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: value ? (disabled ? PColors.gray[3] : theme.primary) : theme.surface,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: value ? (disabled ? PColors.gray[3] : theme.primary) : theme.border,
          width: 1.5,
        ),
      ),
      child: value
          ? CustomPaint(painter: _CheckPainter(color: theme.primaryText))
          : null,
    );

    return MouseRegion(
      cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => onChanged!(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            box,
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

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.28);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) => oldDelegate.color != color;
}

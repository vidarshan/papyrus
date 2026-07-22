import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';

/// A round, minimal-chrome icon button (Mantine's ActionIcon).
class PapyrusIconButton extends StatefulWidget {
  const PapyrusIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 38,
    this.color,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  @override
  State<PapyrusIconButton> createState() => _PapyrusIconButtonState();
}

class _PapyrusIconButtonState extends State<PapyrusIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final disabled = widget.onPressed == null;
    final color = widget.color ?? theme.textSecondary;

    return MouseRegion(
      cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? PColors.gray[1] : const Color(0x00000000),
            borderRadius: BorderRadius.circular(PRadius.sm),
          ),
          child: IconTheme(
            data: IconThemeData(
              color: disabled ? theme.textDisabled : color,
              size: widget.size * 0.5,
            ),
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

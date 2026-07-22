import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';

/// A Mantine-style Card: surface with border, radius and padding. Pass
/// [onTap] to make the whole card an interactive target with hover/press
/// feedback (a subtle lift on hover, a slight scale-down on press) instead
/// of wrapping it in a bare GestureDetector at each call site.
class PapyrusCard extends StatefulWidget {
  const PapyrusCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PSpacing.md),
    this.radius = PRadius.md,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  State<PapyrusCard> createState() => _PapyrusCardState();
}

class _PapyrusCardState extends State<PapyrusCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final interactive = widget.onTap != null;
    final lifted = interactive && (_hovered || _pressed);
    final pressScale = _pressed ? 0.98 : 1.0;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: widget.padding,
      transform: Matrix4.identity()
        ..scaleByDouble(pressScale, pressScale, 1.0, 1.0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: PColors.black.withValues(alpha: lifted ? 0.09 : 0.05),
            blurRadius: lifted ? 16 : 10,
            offset: Offset(0, lifted ? 6 : 3),
          ),
        ],
      ),
      child: widget.child,
    );

    if (!interactive) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: card,
        ),
      ),
    );
  }
}

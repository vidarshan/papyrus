import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'loader.dart';

enum PButtonVariant { filled, light, outline, subtle }

enum PButtonSize { xs, sm, md, lg, xl }

class _ButtonSizeSpec {
  const _ButtonSizeSpec(this.height, this.paddingX, this.fontSize);
  final double height;
  final double paddingX;
  final double fontSize;
}

const _sizeSpecs = {
  PButtonSize.xs: _ButtonSizeSpec(30, 12, PFontSize.xs),
  PButtonSize.sm: _ButtonSizeSpec(36, 16, PFontSize.sm),
  PButtonSize.md: _ButtonSizeSpec(42, 18, PFontSize.md),
  PButtonSize.lg: _ButtonSizeSpec(48, 22, PFontSize.lg),
  PButtonSize.xl: _ButtonSizeSpec(54, 26, PFontSize.xl),
};

/// A Mantine-style Button: filled / light / outline / subtle variants,
/// five sizes, optional loading state and leading icon.
class PapyrusButton extends StatefulWidget {
  const PapyrusButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PButtonVariant.filled,
    this.size = PButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
    this.leading,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final PButtonVariant variant;
  final PButtonSize size;
  final bool loading;
  final bool fullWidth;
  final Widget? leading;
  final Color? color;

  @override
  State<PapyrusButton> createState() => _PapyrusButtonState();
}

class _PapyrusButtonState extends State<PapyrusButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.loading;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final spec = _sizeSpecs[widget.size]!;
    final base = widget.color ?? theme.primary;
    final pressScale = _pressed && !_disabled ? 0.97 : 1.0;

    Color background;
    Color foreground;
    Border? border;

    switch (widget.variant) {
      case PButtonVariant.filled:
        background = _pressed
            ? _darken(base, 0.12)
            : _hovered
            ? _darken(base, 0.06)
            : base;
        foreground = theme.primaryText;
        border = null;
        break;
      case PButtonVariant.light:
        background = _pressed
            ? PColors.primary[2]
            : _hovered
            ? PColors.primary[1]
            : PColors.primary[0];
        foreground = base;
        border = null;
        break;
      case PButtonVariant.outline:
        background = _pressed
            ? PColors.primary[0]
            : _hovered
            ? PColors.gray[0]
            : const Color(0x00000000);
        foreground = base;
        border = Border.all(color: base, width: 1);
        break;
      case PButtonVariant.subtle:
        background = _pressed
            ? PColors.gray[2]
            : _hovered
            ? PColors.gray[1]
            : const Color(0x00000000);
        foreground = base;
        border = null;
        break;
    }

    if (_disabled) {
      background = widget.variant == PButtonVariant.filled
          ? PColors.gray[2]
          : const Color(0x00000000);
      foreground = theme.textDisabled;
      border = widget.variant == PButtonVariant.outline
          ? Border.all(color: theme.border, width: 1)
          : null;
    }

    final content = widget.loading
        ? PapyrusLoader(size: spec.fontSize + 2, color: foreground)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: foreground,
                    size: spec.fontSize + 4,
                  ),
                  child: widget.leading!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  color: foreground,
                  fontSize: spec.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return MouseRegion(
      cursor: _disabled ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: _disabled
            ? null
            : (_) => setState(() => _pressed = true),
        onPointerUp: _disabled ? null : (_) => setState(() => _pressed = false),
        onPointerCancel: _disabled
            ? null
            : (_) => setState(() => _pressed = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _disabled ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: spec.height,
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: spec.paddingX),
            transform: Matrix4.identity()
              ..scaleByDouble(pressScale, pressScale, 1.0, 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(PRadius.sm),
              border: border,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

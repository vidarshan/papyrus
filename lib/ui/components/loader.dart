import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';

/// A small rotating-arc spinner, painted directly instead of using
/// Material's CircularProgressIndicator.
class PapyrusLoader extends StatefulWidget {
  const PapyrusLoader({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  State<PapyrusLoader> createState() => _PapyrusLoaderState();
}

class _PapyrusLoaderState extends State<PapyrusLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? PapyrusTheme.of(context).primary;
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _LoaderPainter(color: color),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      0,
      3.14159 * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) =>
      oldDelegate.color != color;
}

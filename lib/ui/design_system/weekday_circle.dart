import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class WeekdayCircle extends StatelessWidget {
  const WeekdayCircle({super.key, this.progress = 0, this.large = false});

  final double progress;
  final bool large;

  bool get filled => progress >= 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = large ? 40.0 : 28.0;
    return Semantics(
      selected: filled,
      child: CustomPaint(
        size: Size.square(size),
        painter: _CircleProgressPainter(
          progress: progress.clamp(0, 1),
          color: colorScheme.primary,
          border: filled ? colorScheme.primary : colorScheme.outline,
        ),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  const _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.border,
  });

  final double progress;
  final Color color;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        -math.pi / 2,
        math.pi * 2 * progress,
        true,
        Paint()..color = color,
      );
    }
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.border != border;
  }
}

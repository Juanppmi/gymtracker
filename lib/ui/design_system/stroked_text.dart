import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:material_ui/material_ui.dart';

class StrokedText extends StatelessWidget {
  const StrokedText(this.data, {super.key, this.style, this.strokeWidth = 2});

  final String data;
  final TextStyle? style;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? DefaultTextStyle.of(context).style;
    final inset = strokeWidth / 2;
    return CustomPaint(
      painter: _LetterStrokePainter(
        text: data,
        style: resolved,
        strokeWidth: strokeWidth,
        strokeColor: appWhite,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Text(
          data,
          style: resolved.foreground == null
              ? resolved
              : resolved.copyWith(foreground: null),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _LetterStrokePainter extends CustomPainter {
  _LetterStrokePainter({
    required this.text,
    required this.style,
    required this.strokeWidth,
    required this.strokeColor,
    required this.textDirection,
    required this.textScaler,
  });

  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;
  final TextDirection textDirection;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          color: null,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeJoin = StrokeJoin.round
            ..color = strokeColor,
        ),
      ),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
      ellipsis: '\u2026',
    )..layout(maxWidth: (size.width - strokeWidth).clamp(0.0, double.infinity));
    painter.paint(canvas, Offset(strokeWidth / 2, strokeWidth / 2));
  }

  @override
  bool shouldRepaint(covariant _LetterStrokePainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.textScaler != textScaler;
  }
}

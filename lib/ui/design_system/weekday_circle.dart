import 'package:material_ui/material_ui.dart';

class WeekdayCircle extends StatelessWidget {
  const WeekdayCircle({super.key, required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: filled,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? colorScheme.primary : Colors.transparent,
          border: Border.all(
            color: filled ? colorScheme.primary : colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

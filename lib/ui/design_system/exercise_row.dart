import 'package:gymtracker/ui/design_system/stroked_text.dart';
import 'package:material_ui/material_ui.dart';

class ExerciseRow extends StatelessWidget {
  const ExerciseRow({
    super.key,
    required this.name,
    required this.muscleGroup,
    required this.weight,
    required this.sets,
    required this.reps,
  });

  final String name;
  final String muscleGroup;
  final String weight;
  final String sets;
  final String reps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrokedText(name, style: Theme.of(context).textTheme.titleMedium),
        Text(muscleGroup),
        Text('$weight · $sets · $reps'),
      ],
    );
  }
}

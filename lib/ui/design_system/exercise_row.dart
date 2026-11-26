import 'package:gymtracker/ui/exercise/exercise_thumbnail.dart';
import 'package:material_ui/material_ui.dart';

class ExerciseRow extends StatelessWidget {
  const ExerciseRow({
    super.key,
    required this.name,
    required this.nameEn,
    required this.muscleGroup,
    required this.weight,
    required this.sets,
    required this.reps,
  });

  final String name;
  final String nameEn;
  final String muscleGroup;
  final String weight;
  final String sets;
  final String reps;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExerciseThumbnail(nameEn: nameEn),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              Text(muscleGroup),
              Text('$weight · $sets · $reps'),
            ],
          ),
        ),
      ],
    );
  }
}

class WorkoutDraft {
  const WorkoutDraft({
    required this.exerciseId,
    required this.nameEn,
    required this.namePt,
    required this.muscleGroup,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.position,
  });

  final int exerciseId;
  final String nameEn;
  final String namePt;
  final String muscleGroup;
  final double weight;
  final int sets;
  final int reps;
  final int position;

  String get weightLabel {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }
    return weight.toString();
  }
}

class PerformedExercise {
  const PerformedExercise({
    required this.exerciseId,
    required this.position,
    required this.weight,
    required this.sets,
    required this.reps,
  });

  final int exerciseId;
  final int position;
  final double weight;
  final int sets;
  final int reps;
}

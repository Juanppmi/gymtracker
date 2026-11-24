class RoutineExerciseItem {
  const RoutineExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.nameEn,
    required this.namePt,
    required this.muscleGroup,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.position,
  });

  final int id;
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

  RoutineExerciseItem copyWith({double? weight, int? sets, int? reps}) {
    return RoutineExerciseItem(
      id: id,
      exerciseId: exerciseId,
      nameEn: nameEn,
      namePt: namePt,
      muscleGroup: muscleGroup,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      position: position,
    );
  }
}

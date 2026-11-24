import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/routine_exercise_item.dart';

final routineEditorProvider = AsyncNotifierProvider.autoDispose
    .family<RoutineEditorNotifier, List<RoutineExerciseItem>, int>(
      RoutineEditorNotifier.new,
    );

class RoutineEditorNotifier extends AsyncNotifier<List<RoutineExerciseItem>> {
  RoutineEditorNotifier(this.routineId);

  final int routineId;

  @override
  Future<List<RoutineExerciseItem>> build() {
    return ref.watch(gymRepositoryProvider).listRoutineExercises(routineId);
  }

  Future<void> addExercise(int exerciseId) async {
    final repository = ref.read(gymRepositoryProvider);
    await repository.addExerciseToRoutine(routineId, exerciseId);
    state = AsyncData(await repository.listRoutineExercises(routineId));
  }

  Future<void> updateNumbers({
    required int id,
    required double weight,
    required int sets,
    required int reps,
  }) async {
    await ref
        .read(gymRepositoryProvider)
        .updateRoutineExercise(id: id, weight: weight, sets: sets, reps: reps);
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData([
      for (final item in current)
        if (item.id == id)
          item.copyWith(weight: weight, sets: sets, reps: reps)
        else
          item,
    ]);
  }

  Future<void> remove(int id) async {
    final repository = ref.read(gymRepositoryProvider);
    await repository.removeRoutineExercise(id);
    state = AsyncData(await repository.listRoutineExercises(routineId));
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final updated = [...current];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    await ref.read(gymRepositoryProvider).reorderRoutineExercises(routineId, [
      for (final entry in updated) entry.id,
    ]);
    state = AsyncData(
      await ref.read(gymRepositoryProvider).listRoutineExercises(routineId),
    );
  }
}

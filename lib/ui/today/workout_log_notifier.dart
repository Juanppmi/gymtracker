import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/workout_draft.dart';

final workoutDraftProvider = AsyncNotifierProvider.autoDispose
    .family<WorkoutDraftNotifier, List<WorkoutDraft>, int>(
      WorkoutDraftNotifier.new,
    );

class WorkoutDraftNotifier extends AsyncNotifier<List<WorkoutDraft>> {
  WorkoutDraftNotifier(this.routineId);

  final int routineId;

  @override
  Future<List<WorkoutDraft>> build() {
    return ref.watch(gymRepositoryProvider).loadWorkoutDraft(routineId);
  }
}

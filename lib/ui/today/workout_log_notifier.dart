import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/clock.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/week.dart';
import 'package:gymtracker/data/workout_draft.dart';

typedef WorkoutKey = (int, int);

final workoutDraftProvider = AsyncNotifierProvider.autoDispose
    .family<WorkoutDraftNotifier, List<WorkoutDraft>, WorkoutKey>(
      WorkoutDraftNotifier.new,
    );

class WorkoutDraftNotifier extends AsyncNotifier<List<WorkoutDraft>> {
  WorkoutDraftNotifier(this.key);

  final WorkoutKey key;

  @override
  Future<List<WorkoutDraft>> build() {
    final repository = ref.watch(gymRepositoryProvider);
    final weekStart = weekStartOf(ref.watch(clockProvider));
    return repository.loadWorkoutDraft(
      weekStart: weekStart,
      weekday: key.$1,
      routineId: key.$2,
    );
  }
}

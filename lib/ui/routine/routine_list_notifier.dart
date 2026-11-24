import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';

final routineListProvider =
    AsyncNotifierProvider<RoutineListNotifier, List<Routine>>(
      RoutineListNotifier.new,
    );

class RoutineListNotifier extends AsyncNotifier<List<Routine>> {
  @override
  Future<List<Routine>> build() {
    return ref.watch(gymRepositoryProvider).listRoutines();
  }

  Future<void> create(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await ref.read(gymRepositoryProvider).createRoutine(trimmed);
    ref.invalidateSelf();
  }

  Future<void> rename(int id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await ref.read(gymRepositoryProvider).renameRoutine(id, trimmed);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(gymRepositoryProvider).deleteRoutine(id);
    ref.invalidateSelf();
  }
}

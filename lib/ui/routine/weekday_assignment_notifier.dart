import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';

final weekdayAssignmentsProvider =
    AsyncNotifierProvider<
      WeekdayAssignmentsNotifier,
      List<WeekdayAssignmentItem>
    >(WeekdayAssignmentsNotifier.new);

class WeekdayAssignmentsNotifier
    extends AsyncNotifier<List<WeekdayAssignmentItem>> {
  @override
  Future<List<WeekdayAssignmentItem>> build() {
    return ref.watch(gymRepositoryProvider).listWeekdayAssignments();
  }

  Future<void> assign(int weekday, int routineId) async {
    final repository = ref.read(gymRepositoryProvider);
    await repository.assignRoutineToWeekday(weekday, routineId);
    state = AsyncData(await repository.listWeekdayAssignments());
  }

  Future<void> remove(int id) async {
    final repository = ref.read(gymRepositoryProvider);
    await repository.removeWeekdayAssignment(id);
    state = AsyncData(await repository.listWeekdayAssignments());
  }

  Future<void> reload() async {
    state = AsyncData(
      await ref.read(gymRepositoryProvider).listWeekdayAssignments(),
    );
  }
}

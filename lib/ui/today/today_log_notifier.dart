import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/clock.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/week.dart';
import 'package:gymtracker/data/week_snapshot.dart';
import 'package:gymtracker/ui/routine/weekday_assignment_notifier.dart';

final todayLogProvider = AsyncNotifierProvider<TodayLogNotifier, WeekSnapshot>(
  TodayLogNotifier.new,
);

class TodayLogNotifier extends AsyncNotifier<WeekSnapshot> {
  @override
  Future<WeekSnapshot> build() async {
    final repository = ref.watch(gymRepositoryProvider);
    final weekStart = weekStartOf(ref.watch(clockProvider));
    final assignments = await ref.watch(weekdayAssignmentsProvider.future);
    final sessions = await repository.sessionsForWeek(weekStart);
    return WeekSnapshot(
      weekStart: weekStart,
      assignments: assignments,
      logged: {
        for (final session in sessions) (session.weekday, session.routineId),
      },
    );
  }
}

import 'package:gymtracker/data/weekday_assignment_item.dart';

class WeekSnapshot {
  const WeekSnapshot({
    required this.weekStart,
    required this.assignments,
    required this.logged,
    this.checkedCounts = const <(int, int), int>{},
    this.exerciseCounts = const <int, int>{},
  });

  final DateTime weekStart;
  final List<WeekdayAssignmentItem> assignments;
  final Set<(int, int)> logged;
  final Map<(int, int), int> checkedCounts;
  final Map<int, int> exerciseCounts;

  double progressFor(int weekday) {
    final assigned = [
      for (final item in assignments)
        if (item.weekday == weekday) item.routineId,
    ];
    if (assigned.isEmpty) {
      return 0;
    }
    final done = assigned
        .where((routineId) => logged.contains((weekday, routineId)))
        .length;
    return done / assigned.length;
  }

  bool isFilled(int weekday) => progressFor(weekday) >= 1;

  int exerciseCount(int routineId) => exerciseCounts[routineId] ?? 0;

  int checkedCount(int weekday, int routineId) {
    return checkedCounts[(weekday, routineId)] ?? 0;
  }

  List<WeekdayAssignmentItem> routinesFor(int weekday) {
    return [
      for (final item in assignments)
        if (item.weekday == weekday) item,
    ];
  }
}

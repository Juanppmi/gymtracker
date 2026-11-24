import 'package:gymtracker/data/weekday_assignment_item.dart';

class WeekSnapshot {
  const WeekSnapshot({
    required this.weekStart,
    required this.assignments,
    required this.logged,
  });

  final DateTime weekStart;
  final List<WeekdayAssignmentItem> assignments;
  final Set<(int, int)> logged;

  bool isFilled(int weekday) {
    final assigned = [
      for (final item in assignments)
        if (item.weekday == weekday) item.routineId,
    ];
    if (assigned.isEmpty) {
      return false;
    }
    return assigned.every((routineId) => logged.contains((weekday, routineId)));
  }

  List<WeekdayAssignmentItem> routinesFor(int weekday) {
    return [
      for (final item in assignments)
        if (item.weekday == weekday) item,
    ];
  }
}

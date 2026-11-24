import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:gymtracker/data/db/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exercises,
    Routines,
    RoutineExercises,
    WeekdayAssignments,
    WorkoutSessions,
    WorkoutExercises,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'gym_tracker'));

  @override
  int get schemaVersion => 1;
}

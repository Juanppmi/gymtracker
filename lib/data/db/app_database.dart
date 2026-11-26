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
    ExerciseChecks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'gym_tracker'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(exerciseChecks);
      }
    },
  );
}

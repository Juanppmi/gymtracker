import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/routine_exercise_item.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';
import 'package:gymtracker/data/workout_draft.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return GymRepository(database);
});

class GymRepository {
  GymRepository(this._database);

  final AppDatabase _database;

  Future<void> ensureSeeded() async {
    final existing = await _database.select(_database.exercises).get();
    if (existing.isNotEmpty) {
      return;
    }

    final script = await rootBundle.loadString('assets/seed/exercises.sql');
    final statements = script
        .split(';')
        .map((statement) => statement.trim())
        .where((statement) => statement.isNotEmpty);

    await _database.transaction(() async {
      for (final statement in statements) {
        await _database.customStatement(statement);
      }
    });
  }

  Future<List<Exercise>> listExercises() {
    return (_database.select(
      _database.exercises,
    )..orderBy([(exercise) => OrderingTerm(expression: exercise.id)])).get();
  }

  Future<List<Routine>> listRoutines() {
    return (_database.select(_database.routines)..orderBy([
          (routine) => OrderingTerm(expression: routine.name),
          (routine) => OrderingTerm(expression: routine.id),
        ]))
        .get();
  }

  Future<void> createRoutine(String name) {
    return _database
        .into(_database.routines)
        .insert(RoutinesCompanion.insert(name: name));
  }

  Future<void> renameRoutine(int id, String name) {
    return (_database.update(_database.routines)
          ..where((routine) => routine.id.equals(id)))
        .write(RoutinesCompanion(name: Value(name)));
  }

  Future<void> deleteRoutine(int id) {
    return (_database.delete(
      _database.routines,
    )..where((routine) => routine.id.equals(id))).go();
  }

  Future<List<RoutineExerciseItem>> listRoutineExercises(int routineId) async {
    final rows =
        await (_database.select(_database.routineExercises).join([
                innerJoin(
                  _database.exercises,
                  _database.exercises.id.equalsExp(
                    _database.routineExercises.exerciseId,
                  ),
                ),
              ])
              ..where(_database.routineExercises.routineId.equals(routineId))
              ..orderBy([
                OrderingTerm(expression: _database.routineExercises.position),
                OrderingTerm(expression: _database.routineExercises.id),
              ]))
            .get();

    return [
      for (final row in rows)
        RoutineExerciseItem(
          id: row.readTable(_database.routineExercises).id,
          exerciseId: row.readTable(_database.exercises).id,
          nameEn: row.readTable(_database.exercises).nameEn,
          namePt: row.readTable(_database.exercises).namePt,
          muscleGroup: row.readTable(_database.exercises).muscleGroup,
          weight: row.readTable(_database.routineExercises).weight,
          sets: row.readTable(_database.routineExercises).sets,
          reps: row.readTable(_database.routineExercises).reps,
          position: row.readTable(_database.routineExercises).position,
        ),
    ];
  }

  Future<void> addExerciseToRoutine(int routineId, int exerciseId) async {
    final positions =
        await (_database.select(_database.routineExercises)
              ..where((row) => row.routineId.equals(routineId)))
            .map((row) => row.position)
            .get();
    final nextPosition = positions.isEmpty ? 0 : positions.reduce(max) + 1;
    await _database
        .into(_database.routineExercises)
        .insert(
          RoutineExercisesCompanion.insert(
            routineId: routineId,
            exerciseId: exerciseId,
            weight: 0,
            sets: 3,
            reps: 10,
            position: nextPosition,
          ),
        );
  }

  Future<void> updateRoutineExercise({
    required int id,
    required double weight,
    required int sets,
    required int reps,
  }) {
    return (_database.update(
      _database.routineExercises,
    )..where((row) => row.id.equals(id))).write(
      RoutineExercisesCompanion(
        weight: Value(weight),
        sets: Value(sets),
        reps: Value(reps),
      ),
    );
  }

  Future<void> removeRoutineExercise(int id) {
    return (_database.delete(
      _database.routineExercises,
    )..where((row) => row.id.equals(id))).go();
  }

  Future<List<WeekdayAssignmentItem>> listWeekdayAssignments() async {
    final rows =
        await (_database.select(_database.weekdayAssignments).join([
              innerJoin(
                _database.routines,
                _database.routines.id.equalsExp(
                  _database.weekdayAssignments.routineId,
                ),
              ),
            ])..orderBy([
              OrderingTerm(expression: _database.weekdayAssignments.weekday),
              OrderingTerm(expression: _database.weekdayAssignments.id),
            ]))
            .get();

    return [
      for (final row in rows)
        WeekdayAssignmentItem(
          id: row.readTable(_database.weekdayAssignments).id,
          weekday: row.readTable(_database.weekdayAssignments).weekday,
          routineId: row.readTable(_database.routines).id,
          routineName: row.readTable(_database.routines).name,
        ),
    ];
  }

  Future<void> assignRoutineToWeekday(int weekday, int routineId) async {
    final existing =
        await (_database.select(_database.weekdayAssignments)..where(
              (row) =>
                  row.weekday.equals(weekday) & row.routineId.equals(routineId),
            ))
            .get();
    if (existing.isNotEmpty) {
      return;
    }
    await _database
        .into(_database.weekdayAssignments)
        .insert(
          WeekdayAssignmentsCompanion.insert(
            weekday: weekday,
            routineId: routineId,
          ),
        );
  }

  Future<void> removeWeekdayAssignment(int id) {
    return (_database.delete(
      _database.weekdayAssignments,
    )..where((row) => row.id.equals(id))).go();
  }

  Future<void> reorderRoutineExercises(int routineId, List<int> orderedIds) {
    return _database.transaction(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        await (_database.update(_database.routineExercises)..where(
              (row) =>
                  row.id.equals(orderedIds[index]) &
                  row.routineId.equals(routineId),
            ))
            .write(RoutineExercisesCompanion(position: Value(index)));
      }
    });
  }

  Future<List<WorkoutSession>> sessionsForWeek(DateTime weekStart) {
    return (_database.select(
      _database.workoutSessions,
    )..where((row) => row.weekStart.equals(weekStart))).get();
  }

  Future<List<WorkoutDraft>> loadWorkoutDraft({
    required DateTime weekStart,
    required int weekday,
    required int routineId,
  }) async {
    final session = await _sessionFor(weekStart, weekday, routineId);
    if (session == null) {
      final planned = await listRoutineExercises(routineId);
      return [
        for (final item in planned)
          WorkoutDraft(
            exerciseId: item.exerciseId,
            nameEn: item.nameEn,
            namePt: item.namePt,
            muscleGroup: item.muscleGroup,
            weight: item.weight,
            sets: item.sets,
            reps: item.reps,
            position: item.position,
          ),
      ];
    }

    final rows =
        await (_database.select(_database.workoutExercises).join([
                innerJoin(
                  _database.exercises,
                  _database.exercises.id.equalsExp(
                    _database.workoutExercises.exerciseId,
                  ),
                ),
              ])
              ..where(_database.workoutExercises.sessionId.equals(session.id))
              ..orderBy([
                OrderingTerm(expression: _database.workoutExercises.position),
                OrderingTerm(expression: _database.workoutExercises.id),
              ]))
            .get();

    return [
      for (final row in rows)
        WorkoutDraft(
          exerciseId: row.readTable(_database.exercises).id,
          nameEn: row.readTable(_database.exercises).nameEn,
          namePt: row.readTable(_database.exercises).namePt,
          muscleGroup: row.readTable(_database.exercises).muscleGroup,
          weight: row.readTable(_database.workoutExercises).weight,
          sets: row.readTable(_database.workoutExercises).sets,
          reps: row.readTable(_database.workoutExercises).reps,
          position: row.readTable(_database.workoutExercises).position,
        ),
    ];
  }

  Future<void> saveWorkout({
    required DateTime weekStart,
    required int weekday,
    required int routineId,
    required DateTime performedOn,
    required List<PerformedExercise> exercises,
  }) {
    return _database.transaction(() async {
      final existing = await _sessionFor(weekStart, weekday, routineId);
      final int sessionId;
      if (existing == null) {
        sessionId = await _database
            .into(_database.workoutSessions)
            .insert(
              WorkoutSessionsCompanion.insert(
                weekStart: weekStart,
                weekday: weekday,
                routineId: routineId,
                performedOn: performedOn,
              ),
            );
      } else {
        sessionId = existing.id;
        await (_database.update(_database.workoutSessions)
              ..where((row) => row.id.equals(sessionId)))
            .write(WorkoutSessionsCompanion(performedOn: Value(performedOn)));
        await (_database.delete(
          _database.workoutExercises,
        )..where((row) => row.sessionId.equals(sessionId))).go();
      }

      for (final exercise in exercises) {
        await _database
            .into(_database.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                sessionId: sessionId,
                exerciseId: exercise.exerciseId,
                position: exercise.position,
                weight: exercise.weight,
                sets: exercise.sets,
                reps: exercise.reps,
              ),
            );
      }
    });
  }

  Future<WorkoutSession?> _sessionFor(
    DateTime weekStart,
    int weekday,
    int routineId,
  ) {
    return (_database.select(_database.workoutSessions)..where(
          (row) =>
              row.weekStart.equals(weekStart) &
              row.weekday.equals(weekday) &
              row.routineId.equals(routineId),
        ))
        .getSingleOrNull();
  }
}

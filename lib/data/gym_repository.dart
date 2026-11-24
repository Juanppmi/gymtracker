import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/routine_exercise_item.dart';

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
}

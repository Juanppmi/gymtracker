import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';

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
    return (_database.select(_database.exercises)
          ..orderBy([(exercise) => OrderingTerm(expression: exercise.id)]))
        .get();
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
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/muscle_group.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh database loads the seed once', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = GymRepository(database);

    await repository.ensureSeeded();
    final first = await repository.listExercises();
    await repository.ensureSeeded();
    final second = await repository.listExercises();

    expect(first, hasLength(136));
    expect(second.map((exercise) => exercise.id), first.map((exercise) => exercise.id));
    expect(first.map((exercise) => exercise.muscleGroup).toSet(), muscleGroups.toSet());
    expect(
      first.firstWhere((exercise) => exercise.id == 1),
      isA<Exercise>()
          .having((exercise) => exercise.nameEn, 'nameEn', 'Bench press')
          .having((exercise) => exercise.namePt, 'namePt', 'Supino reto')
          .having((exercise) => exercise.muscleGroup, 'muscleGroup', 'chest'),
    );

    await database.close();
  });

  test('new exercises are added without replacing stored ones', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = GymRepository(database);
    await database.customStatement(
      "INSERT INTO exercises (id, name_en, name_pt, muscle_group) VALUES (1, 'Bench press', 'Supino reto', 'chest')",
    );

    await repository.ensureSeeded();
    await repository.ensureSeeded();
    final exercises = await repository.listExercises();

    expect(exercises, hasLength(136));
    expect(exercises.where((exercise) => exercise.id == 1), hasLength(1));
    expect(
      exercises.firstWhere((exercise) => exercise.id == 1).nameEn,
      'Bench press',
    );
    expect(exercises.map((exercise) => exercise.id).toSet(), hasLength(136));

    await database.close();
  });
}

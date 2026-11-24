import 'package:drift/drift.dart';

class Exercises extends Table {
  IntColumn get id => integer()();
  TextColumn get nameEn => text()();
  TextColumn get namePt => text()();
  TextColumn get muscleGroup => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().references(
    Routines,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  RealColumn get weight => real()();
  IntColumn get sets => integer()();
  IntColumn get reps => integer()();
  IntColumn get position => integer()();
}

class WeekdayAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get weekday => integer()();
  IntColumn get routineId => integer().references(
    Routines,
    #id,
    onDelete: KeyAction.cascade,
  )();
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStart => dateTime()();
  IntColumn get weekday => integer()();
  IntColumn get routineId => integer().references(
    Routines,
    #id,
    onDelete: KeyAction.cascade,
  )();
  DateTimeColumn get performedOn => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {weekStart, weekday, routineId},
  ];
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(
    WorkoutSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get position => integer()();
  RealColumn get weight => real()();
  IntColumn get sets => integer()();
  IntColumn get reps => integer()();
}

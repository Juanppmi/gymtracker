import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/clock.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/week.dart';
import 'package:gymtracker/data/week_snapshot.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';
import 'package:gymtracker/data/workout_draft.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/ui/design_system/weekday_circle.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late GymRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GymRepository(database);
  });

  tearDown(() => database.close());

  test('a day is filled only when every assigned routine is logged', () {
    const tuesday = DateTime.tuesday;
    final open = WeekSnapshot(
      weekStart: DateTime(2026, 11, 23),
      assignments: const [
        WeekdayAssignmentItem(
          id: 1,
          weekday: tuesday,
          routineId: 1,
          routineName: 'Push day',
        ),
        WeekdayAssignmentItem(
          id: 2,
          weekday: tuesday,
          routineId: 2,
          routineName: 'Pull day',
        ),
      ],
      logged: {(tuesday, 1)},
    );
    expect(open.isFilled(tuesday), isFalse);
    expect(open.isFilled(DateTime.monday), isFalse);

    final done = WeekSnapshot(
      weekStart: open.weekStart,
      assignments: open.assignments,
      logged: {(tuesday, 1), (tuesday, 2)},
    );
    expect(done.isFilled(tuesday), isTrue);
  });

  test('finishing again updates the same session', () async {
    await repository.ensureSeeded();
    await repository.createRoutine('Push day');
    await repository.addExerciseToRoutine(1, 1);
    final weekStart = DateTime(2026, 11, 23);

    await repository.saveWorkout(
      weekStart: weekStart,
      weekday: DateTime.tuesday,
      routineId: 1,
      performedOn: DateTime(2026, 11, 24),
      exercises: const [
        PerformedExercise(
          exerciseId: 1,
          position: 0,
          weight: 20,
          sets: 3,
          reps: 10,
        ),
      ],
    );
    await repository.saveWorkout(
      weekStart: weekStart,
      weekday: DateTime.tuesday,
      routineId: 1,
      performedOn: DateTime(2026, 11, 24, 1),
      exercises: const [
        PerformedExercise(
          exerciseId: 1,
          position: 0,
          weight: 25,
          sets: 4,
          reps: 8,
        ),
      ],
    );

    final sessions = await repository.sessionsForWeek(weekStart);
    expect(sessions, hasLength(1));
    final saved = await repository.loadWorkoutDraft(
      weekStart: weekStart,
      weekday: DateTime.tuesday,
      routineId: 1,
    );
    expect(saved.single.weight, 25);
    expect(saved.single.sets, 4);
    expect(saved.single.reps, 8);
  });

  testWidgets('Today logs the performed workout and switches days', (
    tester,
  ) async {
    final today = DateTime(2026, 11, 24);
    expect(today.weekday, DateTime.tuesday);

    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      await repository.ensureSeeded();
      await repository.createRoutine('Push day');
      await repository.createRoutine('Legs');
      await repository.addExerciseToRoutine(1, 1);
      await repository.assignRoutineToWeekday(DateTime.tuesday, 1);
      await repository.assignRoutineToWeekday(DateTime.wednesday, 2);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(today),
        ],
        child: const GymTrackerApp(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Push day'), findsOneWidget);
    expect(find.text('Legs'), findsNothing);
    expect(_circle(tester, DateTime.tuesday).filled, isFalse);

    await tester.tap(find.byKey(Key('day-${DateTime.wednesday}')));
    await tester.pumpAndSettle();
    expect(find.text('Legs'), findsOneWidget);
    expect(find.text('Push day'), findsNothing);

    await tester.tap(find.byKey(Key('day-${DateTime.tuesday}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push day'));
    await tester.pumpAndSettle();

    expect(await _fieldText(tester, 'log-weight-0'), '0');
    expect(await _fieldText(tester, 'log-sets-0'), '3');
    expect(await _fieldText(tester, 'log-reps-0'), '10');
    await _enterField(tester, 'log-weight-0', '20');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(_circle(tester, DateTime.tuesday).filled, isTrue);
    expect(_circle(tester, DateTime.wednesday).filled, isFalse);

    await tester.tap(find.text('Push day'));
    await tester.pumpAndSettle();
    expect(await _fieldText(tester, 'log-weight-0'), '20');
    await _enterField(tester, 'log-weight-0', '25');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    final saved = await repository.loadWorkoutDraft(
      weekStart: weekStartOf(today),
      weekday: DateTime.tuesday,
      routineId: 1,
    );
    expect(saved.single.weight, 25);
    expect(await repository.sessionsForWeek(weekStartOf(today)), hasLength(1));
  });
}

WeekdayCircle _circle(WidgetTester tester, int weekday) {
  return tester.widget<WeekdayCircle>(
    find.descendant(
      of: find.byKey(Key('day-$weekday')),
      matching: find.byType(WeekdayCircle),
    ),
  );
}

Future<void> _enterField(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<String> _fieldText(WidgetTester tester, String key) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  return tester.widget<TextField>(field).controller!.text;
}

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/main.dart';
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

  test('a routine keeps exercise order, numbers, and removal', () async {
    await repository.ensureSeeded();
    await repository.createRoutine('Push day');
    await repository.addExerciseToRoutine(1, 1);
    await repository.addExerciseToRoutine(1, 3);

    var items = await repository.listRoutineExercises(1);
    expect(items.map((item) => item.exerciseId), [1, 3]);
    expect(items.first.weight, 0);
    expect(items.first.sets, 3);
    expect(items.first.reps, 10);

    await repository.updateRoutineExercise(
      id: items.first.id,
      weight: 20,
      sets: 4,
      reps: 8,
    );
    await repository.reorderRoutineExercises(1, [items[1].id, items.first.id]);
    await repository.removeRoutineExercise(items[1].id);

    items = await repository.listRoutineExercises(1);
    expect(items.single.exerciseId, 1);
    expect(items.single.weight, 20);
    expect(items.single.sets, 4);
    expect(items.single.reps, 8);
  });

  testWidgets('the editor adds, edits, reorders, and removes exercises', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await repository.ensureSeeded();
      await repository.createRoutine('Push day');
    });

    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gymRepositoryProvider.overrideWithValue(repository)],
        child: const GymTrackerApp(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Routines'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push day'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Chest'));
    await tester.pumpAndSettle();
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.byKey(const Key('exercise-image-Bench press')), findsOneWidget);
    expect(find.text('Lat pulldown'), findsNothing);
    await tester.tap(find.text('Bench press'));
    await tester.pumpAndSettle();

    expect(await _fieldText(tester, 'weight-1'), '0');
    expect(await _fieldText(tester, 'sets-1'), '3');
    expect(await _fieldText(tester, 'reps-1'), '10');

    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cardio'));
    await tester.pumpAndSettle();
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Bench press'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Back'));
    await tester.pumpAndSettle();
    expect(find.text('Lat pulldown'), findsOneWidget);
    expect(find.text('Running'), findsNothing);
    await tester.tap(find.text('Lat pulldown'));
    await tester.pumpAndSettle();

    await _enterField(tester, 'weight-1', '20');
    await _enterField(tester, 'sets-1', '4');
    await _enterField(tester, 'reps-1', '8');
    await _enterField(tester, 'weight-2', '30');
    await _enterField(tester, 'sets-2', '5');
    await _enterField(tester, 'reps-2', '12');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.getTopLeft(find.text('Bench press')).dy,
      lessThan(tester.getTopLeft(find.text('Lat pulldown')).dy),
    );
    await tester.drag(find.byKey(const Key('drag-1')), const Offset(0, 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.getTopLeft(find.text('Lat pulldown')).dy,
      lessThan(tester.getTopLeft(find.text('Bench press')).dy),
    );

    await tester.tap(find.byKey(const Key('remove-2')));
    await tester.pumpAndSettle();
    expect(find.text('Lat pulldown'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push day'));
    await tester.pumpAndSettle();

    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Lat pulldown'), findsNothing);
    expect(await _fieldText(tester, 'weight-1'), '20');
    expect(await _fieldText(tester, 'sets-1'), '4');
    expect(await _fieldText(tester, 'reps-1'), '8');
  });
}

Future<void> _enterField(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
}

Future<String> _fieldText(WidgetTester tester, String key) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field);
  final textField = tester.widget<TextField>(field);
  return textField.controller!.text;
}

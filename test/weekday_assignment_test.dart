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

  test('a weekday can hold several routines and drop one', () async {
    await repository.createRoutine('Push day');
    await repository.createRoutine('Pull day');
    await repository.createRoutine('Legs');

    await repository.assignRoutineToWeekday(DateTime.monday, 1);
    await repository.assignRoutineToWeekday(DateTime.monday, 2);
    await repository.assignRoutineToWeekday(DateTime.wednesday, 3);
    await repository.assignRoutineToWeekday(DateTime.monday, 1);

    var items = await repository.listWeekdayAssignments();
    expect(items.map((item) => item.routineName), [
      'Push day',
      'Pull day',
      'Legs',
    ]);
    expect(items.map((item) => item.weekday), [
      DateTime.monday,
      DateTime.monday,
      DateTime.wednesday,
    ]);

    await repository.removeWeekdayAssignment(items.first.id);
    items = await repository.listWeekdayAssignments();
    expect(items.map((item) => item.routineName), ['Pull day', 'Legs']);
  });

  testWidgets('the Routine tab assigns routines to weekdays', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      await repository.createRoutine('Push day');
      await repository.createRoutine('Pull day');
      await repository.createRoutine('Legs');
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gymRepositoryProvider.overrideWithValue(repository)],
        child: const GymTrackerApp(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Monday')).dy,
      lessThan(tester.getTopLeft(find.text('Sunday')).dy),
    );

    await _assign(tester, DateTime.monday, 'Push day');
    await _assign(tester, DateTime.monday, 'Pull day');
    await _assign(tester, DateTime.wednesday, 'Legs');

    expect(find.text('Push day'), findsOneWidget);
    expect(find.text('Pull day'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('remove-assignment-1')));
    await tester.tap(find.byKey(const Key('remove-assignment-1')));
    await tester.pumpAndSettle();

    expect(find.text('Push day'), findsNothing);
    expect(find.text('Pull day'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Pull day')).dy,
      lessThan(tester.getTopLeft(find.text('Wednesday')).dy),
    );
  });
}

Future<void> _assign(WidgetTester tester, int weekday, String name) async {
  final button = find.byKey(Key('assign-$weekday'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

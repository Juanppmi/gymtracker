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

  test('a routine can be created, renamed, and deleted', () async {
    await repository.createRoutine('Push day');
    await repository.renameRoutine(1, 'Pull day');
    final renamed = await repository.listRoutines();
    expect(renamed.single.name, 'Pull day');

    await repository.deleteRoutine(1);
    expect(await repository.listRoutines(), isEmpty);
  });

  testWidgets('the routine list adds, renames, and deletes after confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [gymRepositoryProvider.overrideWithValue(repository)],
        child: const GymTrackerApp(locale: Locale('en')),
      ),
    );

    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Routines'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Push day');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Push day'), findsOneWidget);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pull day');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Pull day'), findsOneWidget);
    expect(find.text('Push day'), findsNothing);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Pull day'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Pull day'), findsNothing);
    expect(find.text('No routines yet'), findsOneWidget);
  });
}

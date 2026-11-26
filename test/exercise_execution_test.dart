import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/exercise_executions.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every exercise has a description in both languages', () {
    expect(
      exerciseExecutions.keys,
      List<int>.generate(126, (index) => index + 1),
    );
    for (final text in exerciseExecutions.values) {
      expect(text.en.trim(), isNotEmpty);
      expect(text.pt.trim(), isNotEmpty);
    }
    expect(
      executionDescription(exerciseId: 1, languageCode: 'en'),
      contains('lower the bar to your chest'),
    );
    expect(
      executionDescription(exerciseId: 1, languageCode: 'pt'),
      contains('desça a barra até o peito'),
    );
    expect(
      exerciseImagePath('Bench press', 'png'),
      'assets/exercises/Bench press.png',
    );
  });

  testWidgets('Execution shows the description without the image', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = GymRepository(database);
    addTearDown(database.close);

    await tester.runAsync(() async {
      await repository.ensureSeeded();
      await repository.createRoutine('Push day');
      await repository.addExerciseToRoutine(1, 1);
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
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('routine-list-screen')),
        matching: find.text('Push day'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('exercise-image-Bench press')), findsOneWidget);

    await tester.tap(find.byKey(const Key('execution-1')));
    await tester.pumpAndSettle();

    expect(find.text('Bench press'), findsWidgets);
    expect(find.textContaining('lower the bar to your chest'), findsOneWidget);
    expect(find.byKey(const Key('execution-image')), findsNothing);
  });
}

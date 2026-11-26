import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/l10n/locale_resolution.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/ui/design_system/app_button.dart';
import 'package:gymtracker/ui/design_system/confirm_dialog.dart';
import 'package:gymtracker/ui/design_system/exercise_row.dart';
import 'package:gymtracker/ui/design_system/weekday_circle.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test(
    'Portuguese locales use Portuguese and every other locale uses English',
    () {
      expect(
        resolveAppLocale(const Locale('pt', 'BR'), const [
          Locale('en'),
          Locale('pt'),
        ]),
        const Locale('pt'),
      );
      expect(
        resolveAppLocale(const Locale('pt'), const [
          Locale('en'),
          Locale('pt'),
        ]),
        const Locale('pt'),
      );
      expect(
        resolveAppLocale(const Locale('pt', 'PT'), const [
          Locale('en'),
          Locale('pt'),
        ]),
        const Locale('pt'),
      );
      expect(
        resolveAppLocale(const Locale('en'), const [
          Locale('en'),
          Locale('pt'),
        ]),
        const Locale('en'),
      );
      expect(
        resolveAppLocale(const Locale('es'), const [
          Locale('en'),
          Locale('pt'),
        ]),
        const Locale('en'),
      );
      expect(
        resolveAppLocale(null, const [Locale('en'), Locale('pt')]),
        const Locale('en'),
      );
    },
  );

  testWidgets('English tabs are Today and Routine', (tester) async {
    await pumpGymApp(tester, const Locale('en'));

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
  });

  testWidgets('Portuguese tabs are Hoje and Ficha', (tester) async {
    await pumpGymApp(tester, const Locale('pt', 'BR'));
    await tester.pumpAndSettle();

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ficha'), findsOneWidget);
  });

  testWidgets('a Portuguese phone without a region still shows Portuguese', (
    tester,
  ) async {
    await pumpGymApp(tester, const Locale('pt'));

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ficha'), findsOneWidget);
  });

  testWidgets('the Routine tab shows the routine screen', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymRepositoryProvider.overrideWithValue(GymRepository(database)),
        ],
        child: const GymTrackerApp(locale: Locale('en')),
      ),
    );

    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('routine-screen')), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
  });

  testWidgets('a weekday circle reports whether it is filled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [WeekdayCircle(progress: 0), WeekdayCircle(progress: 1)],
          ),
        ),
      ),
    );

    final circles = tester.widgetList<WeekdayCircle>(
      find.byType(WeekdayCircle),
    );
    expect(circles.map((circle) => circle.filled), [false, true]);
  });

  testWidgets('an exercise row shows its name and numbers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExerciseRow(
            name: 'Bench press',
            nameEn: 'Bench press',
            muscleGroup: 'Chest',
            weight: '20 kg',
            sets: '3',
            reps: '10',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('20 kg · 3 · 10'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('exercise-image-Bench press'))),
      const Size(96, 96),
    );
  });

  testWidgets('confirmation returns false until the user confirms', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return AppButton(
              label: 'Delete',
              onPressed: () async {
                result = await confirmAction(
                  context,
                  title: 'Delete routine',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Confirm',
                  cancelLabel: 'Cancel',
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}

Future<void> pumpGymApp(WidgetTester tester, Locale locale) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gymRepositoryProvider.overrideWithValue(GymRepository(database)),
      ],
      child: GymTrackerApp(locale: locale),
    ),
  );
}

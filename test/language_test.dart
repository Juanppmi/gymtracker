import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/ui/language/app_language.dart';
import 'package:gymtracker/ui/language/app_language_store.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a saved language is restored', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'portuguese'});
    final stored = SharedPreferencesAppLanguageStore(
      await SharedPreferences.getInstance(),
    );
    expect(stored.read(), AppLanguage.portuguese);

    await stored.write(AppLanguage.english);
    final restored = SharedPreferencesAppLanguageStore(
      await SharedPreferences.getInstance(),
    );
    expect(restored.read(), AppLanguage.english);

    SharedPreferences.setMockInitialValues({'app_language': 'other'});
    final unknown = SharedPreferencesAppLanguageStore(
      await SharedPreferences.getInstance(),
    );
    expect(unknown.read(), AppLanguage.system);
  });

  testWidgets('the app language changes without the phone', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymRepositoryProvider.overrideWithValue(GymRepository(database)),
        ],
        child: const GymTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-portuguese')));
    await tester.pumpAndSettle();
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ficha'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-english')));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Hoje'), findsNothing);
  });
}

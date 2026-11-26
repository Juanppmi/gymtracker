import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:gymtracker/ui/theme/theme_mode_store.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a saved theme is restored', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final stored = SharedPreferencesThemeModeStore(
      await SharedPreferences.getInstance(),
    );
    expect(stored.read(), ThemeMode.dark);

    await stored.write(ThemeMode.light);
    final restored = SharedPreferencesThemeModeStore(
      await SharedPreferences.getInstance(),
    );
    expect(restored.read(), ThemeMode.light);

    SharedPreferences.setMockInitialValues({'theme_mode': 'other'});
    final unknown = SharedPreferencesThemeModeStore(
      await SharedPreferences.getInstance(),
    );
    expect(unknown.read(), ThemeMode.system);
  });

  testWidgets('the app bar switches light and dark without the phone', (
    tester,
  ) async {
    await pumpGymApp(tester, const Locale('en'));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.light);
    expect(_theme(tester).colorScheme.primary, appPurple);
    expect(_theme(tester).colorScheme.onPrimary, appWhite);
    expect(_theme(tester).scaffoldBackgroundColor, appWhite);
    expect(_theme(tester).colorScheme.onSurface, appBlack);
    expect(find.byKey(const Key('app-title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-button')));
    await tester.pumpAndSettle();
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.dark);
    expect(_theme(tester).scaffoldBackgroundColor, appBlack);
    expect(_theme(tester).colorScheme.onSurface, appWhite);
    expect(_theme(tester).colorScheme.primary, appPurple);
    expect(_theme(tester).colorScheme.onPrimary, appWhite);

    await tester.tap(find.byKey(const Key('theme-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-light')));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.byKey(const Key('theme-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-system')));
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.light);
  });

  testWidgets('the theme menu is in Portuguese', (tester) async {
    await pumpGymApp(tester, const Locale('pt'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-button')));
    await tester.pumpAndSettle();
    expect(find.text('Sistema'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Escuro'), findsOneWidget);
  });
}

Brightness _brightness(WidgetTester tester) {
  return _theme(tester).brightness;
}

ThemeData _theme(WidgetTester tester) {
  return Theme.of(tester.element(find.byKey(const Key('today-screen'))));
}

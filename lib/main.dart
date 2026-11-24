import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_l10n;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/l10n/locale_resolution.dart';
import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:gymtracker/ui/navigation/home_shell.dart';
import 'package:gymtracker/ui/theme/theme_mode_controller.dart';
import 'package:gymtracker/ui/theme/theme_mode_store.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeModeStore = await SharedPreferencesThemeModeStore.open();
  final container = ProviderContainer(
    overrides: [themeModeStoreProvider.overrideWithValue(themeModeStore)],
  );
  await container.read(gymRepositoryProvider).ensureSeeded();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GymTrackerApp(),
    ),
  );
}

class GymTrackerApp extends ConsumerWidget {
  const GymTrackerApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: locale,
      localeResolutionCallback: resolveAppLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        flutter_l10n.GlobalWidgetsLocalizations.delegate,
        cupertino.GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_localizations/flutter_localizations.dart' as flutter_l10n;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/l10n/locale_resolution.dart';
import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:gymtracker/ui/navigation/home_shell.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(gymRepositoryProvider).ensureSeeded();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GymTrackerApp(),
    ),
  );
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
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

import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/app_title.dart';
import 'package:gymtracker/ui/design_system/stroked_text.dart';
import 'package:gymtracker/ui/language/app_language_button.dart';
import 'package:gymtracker/ui/routine/routine_screen.dart';
import 'package:gymtracker/ui/theme/theme_mode_button.dart';
import 'package:gymtracker/ui/today/today_screen.dart';
import 'package:material_ui/material_ui.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const AppTitle(),
          actions: const [AppLanguageButton(), ThemeModeButton()],
          bottom: TabBar(
            tabs: [
              Tab(child: StrokedText(l10n.today)),
              Tab(child: StrokedText(l10n.routine)),
            ],
          ),
        ),
        body: const TabBarView(children: [TodayScreen(), RoutineScreen()]),
      ),
    );
  }
}

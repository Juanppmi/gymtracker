import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/routine/routine_screen.dart';
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
          title: Text(l10n.appTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.today),
              Tab(text: l10n.routine),
            ],
          ),
        ),
        body: const TabBarView(
          children: [TodayScreen(), RoutineScreen()],
        ),
      ),
    );
  }
}

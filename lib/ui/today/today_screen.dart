import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/clock.dart';
import 'package:gymtracker/data/weekday.dart';
import 'package:gymtracker/data/week_snapshot.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/weekday_circle.dart';
import 'package:gymtracker/ui/routine/weekday_label.dart';
import 'package:gymtracker/ui/today/today_log_notifier.dart';
import 'package:gymtracker/ui/today/workout_log_screen.dart';
import 'package:material_ui/material_ui.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  int? _selectedWeekday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(clockProvider).weekday;
    final selected = _selectedWeekday ?? today;
    final log = ref.watch(todayLogProvider);

    return SizedBox.expand(
      key: const Key('today-screen'),
      child: log.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (snapshot) {
          final routines = snapshot.routinesFor(selected);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: Row(
                  children: [
                    for (final weekday in weekdaysMondayFirst)
                      Expanded(
                        child: InkWell(
                          key: Key('day-$weekday'),
                          onTap: () =>
                              setState(() => _selectedWeekday = weekday),
                          child: Column(
                            children: [
                              WeekdayCircle(
                                progress: snapshot.progressFor(weekday),
                                large: weekday == today,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                weekdayShortLabel(l10n, weekday),
                                style: TextStyle(
                                  fontSize: weekday == today ? 16 : null,
                                  fontWeight: weekday == selected
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (routines.isEmpty)
                      Text(l10n.noRoutinesThisDay)
                    else
                      for (final routine in routines)
                        _TodayRoutineTile(
                          routine: routine,
                          weekday: selected,
                          snapshot: snapshot,
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayRoutineTile extends StatelessWidget {
  const _TodayRoutineTile({
    required this.routine,
    required this.weekday,
    required this.snapshot,
  });

  final WeekdayAssignmentItem routine;
  final int weekday;
  final WeekSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            routine.routineName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: SizedBox(
                height: 80,
                child: FilledButton(
                  key: Key('open-today-${routine.routineId}'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(80),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => WorkoutLogScreen(
                          weekday: weekday,
                          routineId: routine.routineId,
                          routineName: routine.routineName,
                        ),
                      ),
                    );
                  },
                  child: Text(_label(l10n)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n) {
    final total = snapshot.exerciseCount(routine.routineId);
    final checked = snapshot.checkedCount(weekday, routine.routineId);
    final logged = snapshot.logged.contains((weekday, routine.routineId));
    if (total > 0 && (checked >= total || (logged && checked == 0))) {
      return l10n.review;
    }
    if (checked > 0) {
      return l10n.continueWorkout;
    }
    return l10n.startWorkout;
  }
}

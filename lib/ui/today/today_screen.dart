import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/clock.dart';
import 'package:gymtracker/data/weekday.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/weekday_circle.dart';
import 'package:gymtracker/ui/design_system/white_outline.dart';
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
    final selected = _selectedWeekday ?? ref.watch(clockProvider).weekday;
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
                              WeekdayCircle(filled: snapshot.isFilled(weekday)),
                              const SizedBox(height: 4),
                              WhiteOutline(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                child: Text(
                                  weekdayShortLabel(l10n, weekday),
                                  style: TextStyle(
                                    color: weekday == selected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    fontWeight: weekday == selected
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: WhiteOutline(
                    child: Text(
                      weekdayLabel(l10n, selected),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
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
                        _TodayRoutineTile(routine: routine, weekday: selected),
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
  const _TodayRoutineTile({required this.routine, required this.weekday});

  final WeekdayAssignmentItem routine;
  final int weekday;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('today-routine-${routine.routineId}'),
      contentPadding: EdgeInsets.zero,
      title: WhiteOutline(
        child: Text(
          routine.routineName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      onTap: () {
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
    );
  }
}

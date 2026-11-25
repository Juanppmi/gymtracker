import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/weekday.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/app_button.dart';
import 'package:gymtracker/ui/design_system/stroked_text.dart';
import 'package:gymtracker/ui/routine/routine_list_screen.dart';
import 'package:gymtracker/ui/routine/weekday_assignment_notifier.dart';
import 'package:gymtracker/ui/routine/weekday_label.dart';
import 'package:material_ui/material_ui.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final assignments = ref.watch(weekdayAssignmentsProvider);

    return SizedBox.expand(
      key: const Key('routine-screen'),
      child: assignments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppButton(
                label: l10n.routineList,
                onPressed: () => _openRoutineList(context, ref),
              ),
              const SizedBox(height: 24),
              for (final weekday in weekdaysMondayFirst) ...[
                _WeekdaySection(
                  weekday: weekday,
                  assignments: [
                    for (final item in items)
                      if (item.weekday == weekday) item,
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openRoutineList(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const RoutineListScreen()),
    );
    if (context.mounted) {
      await ref.read(weekdayAssignmentsProvider.notifier).reload();
    }
  }
}

class _WeekdaySection extends ConsumerWidget {
  const _WeekdaySection({required this.weekday, required this.assignments});

  final int weekday;
  final List<WeekdayAssignmentItem> assignments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: StrokedText(
            weekdayLabel(l10n, weekday),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final assignment in assignments)
          ListTile(
            key: Key('assignment-${assignment.id}'),
            contentPadding: EdgeInsets.zero,
            title: StrokedText(
              assignment.routineName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: TextButton(
              key: Key('remove-assignment-${assignment.id}'),
              onPressed: () {
                ref
                    .read(weekdayAssignmentsProvider.notifier)
                    .remove(assignment.id);
              },
              child: Text(l10n.remove),
            ),
          ),
        AppButton(
          key: Key('assign-$weekday'),
          label: l10n.assignRoutine,
          onPressed: () => _assign(context, ref),
        ),
      ],
    );
  }

  Future<void> _assign(BuildContext context, WidgetRef ref) async {
    final routines = await ref.read(gymRepositoryProvider).listRoutines();
    final assignedIds = {for (final item in assignments) item.routineId};
    final available = [
      for (final routine in routines)
        if (!assignedIds.contains(routine.id)) routine,
    ];
    if (!context.mounted) {
      return;
    }
    final routineId = await _pickRoutine(context, available);
    if (routineId == null || !context.mounted) {
      return;
    }
    await ref
        .read(weekdayAssignmentsProvider.notifier)
        .assign(weekday, routineId);
  }
}

Future<int?> _pickRoutine(BuildContext context, List<Routine> routines) {
  final l10n = AppLocalizations.of(context);
  return showDialog<int>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Align(
          alignment: Alignment.centerLeft,
          child: StrokedText(
            l10n.assignRoutine,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        children: [
          if (routines.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(l10n.noRoutines),
            ),
          for (final routine in routines)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(routine.id),
              child: Text(routine.name),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      );
    },
  );
}

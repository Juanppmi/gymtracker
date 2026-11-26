import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/weekday.dart';
import 'package:gymtracker/data/weekday_assignment_item.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/app_button.dart';
import 'package:gymtracker/ui/routine/routine_editor_screen.dart';
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
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: l10n.routineList,
                  onPressed: () => _openRoutineList(context, ref),
                ),
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
    final rows = assignments.isEmpty
        ? [
            _RoutineControls(
              addKey: Key('assign-$weekday'),
              onAdd: () => _assign(context, ref),
              removeTooltip: l10n.remove,
              addTooltip: l10n.assignRoutine,
            ),
          ]
        : [
            for (var index = 0; index < assignments.length; index++)
              _RoutineControls(
                key: Key('assignment-${assignments[index].id}'),
                name: assignments[index].routineName,
                removeKey: Key('remove-assignment-${assignments[index].id}'),
                addKey: index == 0 ? Key('assign-$weekday') : null,
                onRemove: () {
                  ref
                      .read(weekdayAssignmentsProvider.notifier)
                      .remove(assignments[index].id);
                },
                onAdd: () => _assign(context, ref),
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => RoutineEditorScreen(
                        routineId: assignments[index].routineId,
                        routineName: assignments[index].routineName,
                      ),
                    ),
                  );
                },
                removeTooltip: l10n.remove,
                addTooltip: l10n.assignRoutine,
              ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          weekdayLabel(l10n, weekday),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...rows,
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

class _RoutineControls extends StatelessWidget {
  const _RoutineControls({
    super.key,
    this.name,
    this.removeKey,
    this.addKey,
    this.onRemove,
    required this.onAdd,
    this.onOpen,
    required this.removeTooltip,
    required this.addTooltip,
  });

  final String? name;
  final Key? removeKey;
  final Key? addKey;
  final VoidCallback? onRemove;
  final VoidCallback onAdd;
  final VoidCallback? onOpen;
  final String removeTooltip;
  final String addTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          key: removeKey,
          tooltip: removeTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: onRemove,
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          key: addKey,
          tooltip: addTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: onAdd,
          icon: const Icon(Icons.add),
        ),
        if (name != null)
          FilledButton(
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
            ),
            onPressed: onOpen,
            child: Text(name!),
          ),
      ],
    );
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
          child: Text(
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

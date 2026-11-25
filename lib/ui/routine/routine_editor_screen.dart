import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/exercise_executions.dart';
import 'package:gymtracker/data/routine_exercise_item.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/exercise/exercise_execution_sheet.dart';
import 'package:gymtracker/ui/design_system/app_button.dart';
import 'package:gymtracker/ui/design_system/app_text_field.dart';
import 'package:gymtracker/ui/design_system/exercise_row.dart';
import 'package:gymtracker/ui/routine/exercise_catalog_screen.dart';
import 'package:gymtracker/ui/routine/exercise_labels.dart';
import 'package:gymtracker/ui/routine/routine_editor_notifier.dart';
import 'package:material_ui/material_ui.dart';

class RoutineEditorScreen extends ConsumerWidget {
  const RoutineEditorScreen({
    super.key,
    required this.routineId,
    required this.routineName,
  });

  final int routineId;
  final String routineName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exercises = ref.watch(routineEditorProvider(routineId));

    return Scaffold(
      key: const Key('routine-editor-screen'),
      appBar: AppBar(title: Text(routineName)),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          return ReorderableListView(
            padding: const EdgeInsets.all(16),
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) {
              ref
                  .read(routineEditorProvider(routineId).notifier)
                  .reorder(oldIndex, newIndex);
            },
            footer: AppButton(
              label: l10n.addExercise,
              onPressed: () => _openCatalog(context, ref),
            ),
            children: [
              for (var index = 0; index < items.length; index++)
                _EditorTile(
                  key: ValueKey(items[index].id),
                  routineId: routineId,
                  index: index,
                  item: items[index],
                ),
            ],
          );
        },
      ),
    );
  }

  void _openCatalog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExerciseCatalogScreen(
          onPicked: (exercise) {
            return ref
                .read(routineEditorProvider(routineId).notifier)
                .addExercise(exercise.id);
          },
        ),
      ),
    );
  }
}

class _EditorTile extends ConsumerStatefulWidget {
  const _EditorTile({
    super.key,
    required this.routineId,
    required this.index,
    required this.item,
  });

  final int routineId;
  final int index;
  final RoutineExerciseItem item;

  @override
  ConsumerState<_EditorTile> createState() => _EditorTileState();
}

class _EditorTileState extends ConsumerState<_EditorTile> {
  late final TextEditingController _weight = TextEditingController(
    text: widget.item.weightLabel,
  );
  late final TextEditingController _sets = TextEditingController(
    text: widget.item.sets.toString(),
  );
  late final TextEditingController _reps = TextEditingController(
    text: widget.item.reps.toString(),
  );

  @override
  void dispose() {
    _weight.dispose();
    _sets.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: SizedBox(
              key: Key('drag-${item.id}'),
              width: 48,
              height: 48,
              child: const Icon(Icons.drag_handle),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExerciseRow(
                  name: localizedExerciseName(
                    languageCode: languageCode,
                    nameEn: item.nameEn,
                    namePt: item.namePt,
                  ),
                  muscleGroup: muscleGroupLabel(l10n, item.muscleGroup),
                  weight: item.weightLabel,
                  sets: item.sets.toString(),
                  reps: item.reps.toString(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: Key('weight-${item.id}'),
                        label: l10n.weight,
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => _save(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        key: Key('sets-${item.id}'),
                        label: l10n.sets,
                        controller: _sets,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _save(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        key: Key('reps-${item.id}'),
                        label: l10n.reps,
                        controller: _reps,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _save(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      key: Key('execution-${item.id}'),
                      onPressed: () {
                        showExerciseExecution(
                          context,
                          title: localizedExerciseName(
                            languageCode: languageCode,
                            nameEn: item.nameEn,
                            namePt: item.namePt,
                          ),
                          description: executionDescription(
                            exerciseId: item.exerciseId,
                            languageCode: languageCode,
                          ),
                          nameEn: item.nameEn,
                        );
                      },
                      child: Text(l10n.execution),
                    ),
                    const Spacer(),
                    TextButton(
                      key: Key('remove-${item.id}'),
                      onPressed: () {
                        ref
                            .read(
                              routineEditorProvider(widget.routineId).notifier,
                            )
                            .remove(item.id);
                      },
                      child: Text(l10n.remove),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final weight = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    final sets = int.tryParse(_sets.text.trim());
    final reps = int.tryParse(_reps.text.trim());
    if (weight == null || sets == null || reps == null) {
      return;
    }
    ref
        .read(routineEditorProvider(widget.routineId).notifier)
        .updateNumbers(
          id: widget.item.id,
          weight: weight,
          sets: sets,
          reps: reps,
        );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/clock.dart';
import 'package:gymtracker/data/exercise_executions.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/week.dart';
import 'package:gymtracker/data/workout_draft.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/app_button.dart';
import 'package:gymtracker/ui/design_system/app_text_field.dart';
import 'package:gymtracker/ui/design_system/exercise_row.dart';
import 'package:gymtracker/ui/exercise/exercise_execution_sheet.dart';
import 'package:gymtracker/ui/routine/exercise_labels.dart';
import 'package:gymtracker/ui/today/today_log_notifier.dart';
import 'package:gymtracker/ui/today/workout_log_notifier.dart';
import 'package:material_ui/material_ui.dart';

class WorkoutLogScreen extends ConsumerStatefulWidget {
  const WorkoutLogScreen({
    super.key,
    required this.weekday,
    required this.routineId,
    required this.routineName,
  });

  final int weekday;
  final int routineId;
  final String routineName;

  @override
  ConsumerState<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen> {
  final Map<int, TextEditingController> _weights = {};
  final Map<int, TextEditingController> _sets = {};
  final Map<int, TextEditingController> _reps = {};
  var _controllersReady = false;

  @override
  void dispose() {
    for (final controller in _weights.values) {
      controller.dispose();
    }
    for (final controller in _sets.values) {
      controller.dispose();
    }
    for (final controller in _reps.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(workoutDraftProvider(widget.routineId));

    return Scaffold(
      key: const Key('workout-log-screen'),
      appBar: AppBar(title: Text(widget.routineName)),
      body: draft.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          _ensureControllers(items);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [for (final item in items) _tile(context, item)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: l10n.finish,
                  onPressed: () => _finish(items),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _ensureControllers(List<WorkoutDraft> items) {
    if (_controllersReady) {
      return;
    }
    for (final item in items) {
      _weights[item.position] = TextEditingController(text: item.weightLabel);
      _sets[item.position] = TextEditingController(text: item.sets.toString());
      _reps[item.position] = TextEditingController(text: item.reps.toString());
    }
    _controllersReady = true;
  }

  Widget _tile(BuildContext context, WorkoutDraft item) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                  key: Key('log-weight-${item.position}'),
                  label: l10n.weight,
                  controller: _weights[item.position],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  key: Key('log-sets-${item.position}'),
                  label: l10n.sets,
                  controller: _sets[item.position],
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  key: Key('log-reps-${item.position}'),
                  label: l10n.reps,
                  controller: _reps[item.position],
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: Key('log-execution-${item.position}'),
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
          ),
        ],
      ),
    );
  }

  Future<void> _finish(List<WorkoutDraft> items) async {
    final exercises = <PerformedExercise>[];
    for (final item in items) {
      final weight = double.tryParse(
        _weights[item.position]!.text.trim().replaceAll(',', '.'),
      );
      final sets = int.tryParse(_sets[item.position]!.text.trim());
      final reps = int.tryParse(_reps[item.position]!.text.trim());
      if (weight == null || sets == null || reps == null) {
        return;
      }
      exercises.add(
        PerformedExercise(
          exerciseId: item.exerciseId,
          position: item.position,
          weight: weight,
          sets: sets,
          reps: reps,
        ),
      );
    }

    final performedOn = ref.read(clockProvider);
    await ref
        .read(gymRepositoryProvider)
        .saveWorkout(
          weekStart: weekStartOf(performedOn),
          weekday: widget.weekday,
          routineId: widget.routineId,
          performedOn: performedOn,
          exercises: exercises,
        );
    ref.invalidate(todayLogProvider);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

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
  final Set<(int, int)> _checked = {};
  final Set<int> _open = {};
  var _controllersReady = false;
  var _checksReady = false;
  var _logged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChecks();
    });
  }

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
          if (!_checksReady) {
            return const Center(child: CircularProgressIndicator());
          }
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                key: Key('check-${item.position}'),
                value: _isChecked(item),
                onChanged: (value) => _toggle(item, value ?? false),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_open.contains(item.position)) {
                        _open.remove(item.position);
                      } else {
                        _open.add(item.position);
                      }
                    });
                  },
                  child: ExerciseRow(
                    name: localizedExerciseName(
                      languageCode: languageCode,
                      nameEn: item.nameEn,
                      namePt: item.namePt,
                    ),
                    nameEn: item.nameEn,
                    muscleGroup: muscleGroupLabel(l10n, item.muscleGroup),
                    weight: item.weightLabel,
                    sets: item.sets.toString(),
                    reps: item.reps.toString(),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _open.contains(item.position)
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
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
                  )
                : const SizedBox(width: double.infinity, height: 0),
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
                );
              },
              child: Text(l10n.execution),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadChecks() async {
    final repository = ref.read(gymRepositoryProvider);
    final weekStart = weekStartOf(ref.read(clockProvider));
    final checks = await repository.checksFor(
      weekStart: weekStart,
      weekday: widget.weekday,
      routineId: widget.routineId,
    );
    final logged = await repository.hasWorkout(
      weekStart: weekStart,
      weekday: widget.weekday,
      routineId: widget.routineId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _checked
        ..clear()
        ..addAll(checks.map((check) => (check.exerciseId, check.position)));
      _logged = logged;
      _checksReady = true;
    });
  }

  bool _isChecked(WorkoutDraft item) {
    if (_logged && _checked.isEmpty) {
      return true;
    }
    return _checked.contains((item.exerciseId, item.position));
  }

  Future<void> _toggle(WorkoutDraft item, bool checked) async {
    final draft = ref.read(workoutDraftProvider(widget.routineId)).value;
    if (draft == null) {
      return;
    }
    if (_logged && _checked.isEmpty) {
      _checked.addAll(draft.map((entry) => (entry.exerciseId, entry.position)));
      for (final entry in draft) {
        await _storeCheck(entry, true);
      }
    }
    if (checked) {
      _checked.add((item.exerciseId, item.position));
    } else {
      _checked.remove((item.exerciseId, item.position));
    }
    await _storeCheck(item, checked);
    if (!mounted) {
      return;
    }
    setState(() {});

    final complete =
        draft.isNotEmpty && draft.every((entry) => _isChecked(entry));
    if (complete) {
      await _finish(draft, pop: false);
      return;
    }
    if (!checked) {
      await ref
          .read(gymRepositoryProvider)
          .deleteWorkout(
            weekStart: weekStartOf(ref.read(clockProvider)),
            weekday: widget.weekday,
            routineId: widget.routineId,
          );
      _logged = false;
    }
    ref.invalidate(todayLogProvider);
  }

  Future<void> _storeCheck(WorkoutDraft item, bool checked) {
    final repository = ref.read(gymRepositoryProvider);
    return repository.setExerciseChecked(
      weekStart: weekStartOf(ref.read(clockProvider)),
      weekday: widget.weekday,
      routineId: widget.routineId,
      exerciseId: item.exerciseId,
      position: item.position,
      checked: checked,
    );
  }

  Future<void> _finish(List<WorkoutDraft> items, {bool pop = true}) async {
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
    for (final item in items) {
      await _storeCheck(item, true);
    }
    _checked
      ..clear()
      ..addAll(items.map((item) => (item.exerciseId, item.position)));
    _logged = true;

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
    if (pop && mounted) {
      Navigator.of(context).pop();
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/data/gym_repository.dart';
import 'package:gymtracker/data/muscle_group.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/white_outline.dart';
import 'package:gymtracker/ui/routine/exercise_labels.dart';
import 'package:material_ui/material_ui.dart';

final exerciseCatalogProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(gymRepositoryProvider).listExercises();
});

class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({super.key, required this.onPicked});

  final Future<void> Function(Exercise exercise) onPicked;

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends ConsumerState<ExerciseCatalogScreen> {
  String? _muscleGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(exerciseCatalogProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      key: const Key('exercise-catalog-screen'),
      appBar: AppBar(title: Text(l10n.addExercise)),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (exercises) {
          final visible = [
            for (final exercise in exercises)
              if (_muscleGroup == null || exercise.muscleGroup == _muscleGroup)
                exercise,
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.allMuscleGroups),
                    selected: _muscleGroup == null,
                    onSelected: (_) => setState(() => _muscleGroup = null),
                  ),
                  for (final group in muscleGroups)
                    ChoiceChip(
                      label: Text(muscleGroupLabel(l10n, group)),
                      selected: _muscleGroup == group,
                      onSelected: (_) => setState(() => _muscleGroup = group),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              for (final exercise in visible)
                ListTile(
                  key: Key('catalog-${exercise.id}'),
                  title: WhiteOutline(
                    child: Text(
                      localizedExerciseName(
                        languageCode: languageCode,
                        nameEn: exercise.nameEn,
                        namePt: exercise.namePt,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  subtitle: Text(muscleGroupLabel(l10n, exercise.muscleGroup)),
                  onTap: () async {
                    await widget.onPicked(exercise);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

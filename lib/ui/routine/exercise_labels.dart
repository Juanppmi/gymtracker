import 'package:gymtracker/l10n/app_localizations.dart';

String localizedExerciseName({
  required String languageCode,
  required String nameEn,
  required String namePt,
}) {
  return languageCode == 'pt' ? namePt : nameEn;
}

String muscleGroupLabel(AppLocalizations l10n, String muscleGroup) {
  return switch (muscleGroup) {
    'chest' => l10n.muscleChest,
    'back' => l10n.muscleBack,
    'shoulders' => l10n.muscleShoulders,
    'biceps' => l10n.muscleBiceps,
    'triceps' => l10n.muscleTriceps,
    'legs' => l10n.muscleLegs,
    'glutes' => l10n.muscleGlutes,
    'abs' => l10n.muscleAbs,
    'cardio' => l10n.muscleCardio,
    _ => muscleGroup,
  };
}

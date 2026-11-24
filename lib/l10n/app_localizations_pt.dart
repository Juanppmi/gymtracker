// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get today => 'Hoje';

  @override
  String get routine => 'Ficha';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get routineList => 'Fichas';

  @override
  String get addRoutine => 'Adicionar ficha';

  @override
  String get update => 'Atualizar';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteRoutineTitle => 'Excluir ficha';

  @override
  String deleteRoutineMessage(String name) {
    return 'Excluir $name?';
  }

  @override
  String get routineName => 'Nome';

  @override
  String get newRoutineTitle => 'Nova ficha';

  @override
  String get renameRoutineTitle => 'Renomear ficha';

  @override
  String get noRoutines => 'Nenhuma ficha ainda';

  @override
  String get addExercise => 'Adicionar exercício';

  @override
  String get remove => 'Remover';

  @override
  String get weight => 'Peso (kg)';

  @override
  String get sets => 'Séries';

  @override
  String get reps => 'Repetições';

  @override
  String get allMuscleGroups => 'Todos';

  @override
  String get muscleChest => 'Peito';

  @override
  String get muscleBack => 'Costas';

  @override
  String get muscleShoulders => 'Ombros';

  @override
  String get muscleBiceps => 'Bíceps';

  @override
  String get muscleTriceps => 'Tríceps';

  @override
  String get muscleLegs => 'Pernas';

  @override
  String get muscleGlutes => 'Glúteos';

  @override
  String get muscleAbs => 'Abdômen';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get monday => 'Segunda';

  @override
  String get tuesday => 'Terça';

  @override
  String get wednesday => 'Quarta';

  @override
  String get thursday => 'Quinta';

  @override
  String get friday => 'Sexta';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get assignRoutine => 'Atribuir ficha';

  @override
  String get mondayShort => 'Seg';

  @override
  String get tuesdayShort => 'Ter';

  @override
  String get wednesdayShort => 'Qua';

  @override
  String get thursdayShort => 'Qui';

  @override
  String get fridayShort => 'Sex';

  @override
  String get saturdayShort => 'Sáb';

  @override
  String get sundayShort => 'Dom';

  @override
  String get finish => 'Concluir';

  @override
  String get noRoutinesThisDay => 'Nenhuma ficha neste dia';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';
}

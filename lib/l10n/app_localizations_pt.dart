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
}

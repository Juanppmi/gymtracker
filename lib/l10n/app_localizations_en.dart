// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get today => 'Today';

  @override
  String get routine => 'Routine';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get routineList => 'Routines';

  @override
  String get addRoutine => 'Add routine';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get deleteRoutineTitle => 'Delete routine';

  @override
  String deleteRoutineMessage(String name) {
    return 'Delete $name?';
  }

  @override
  String get routineName => 'Name';

  @override
  String get newRoutineTitle => 'New routine';

  @override
  String get renameRoutineTitle => 'Rename routine';

  @override
  String get noRoutines => 'No routines yet';
}

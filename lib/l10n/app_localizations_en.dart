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

  @override
  String get addExercise => 'Add exercise';

  @override
  String get remove => 'Remove';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get allMuscleGroups => 'All';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleLegs => 'Legs';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleAbs => 'Abs';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get assignRoutine => 'Assign routine';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get finish => 'Finish';

  @override
  String get noRoutinesThisDay => 'No routines this day';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}

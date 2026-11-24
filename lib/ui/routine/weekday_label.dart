import 'package:gymtracker/l10n/app_localizations.dart';

String weekdayLabel(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.monday,
    DateTime.tuesday => l10n.tuesday,
    DateTime.wednesday => l10n.wednesday,
    DateTime.thursday => l10n.thursday,
    DateTime.friday => l10n.friday,
    DateTime.saturday => l10n.saturday,
    DateTime.sunday => l10n.sunday,
    _ => '$weekday',
  };
}

String weekdayShortLabel(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.mondayShort,
    DateTime.tuesday => l10n.tuesdayShort,
    DateTime.wednesday => l10n.wednesdayShort,
    DateTime.thursday => l10n.thursdayShort,
    DateTime.friday => l10n.fridayShort,
    DateTime.saturday => l10n.saturdayShort,
    DateTime.sunday => l10n.sundayShort,
    _ => '$weekday',
  };
}

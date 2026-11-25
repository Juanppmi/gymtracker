import 'package:material_ui/material_ui.dart';

enum AppLanguage { system, english, portuguese }

Locale? localeFor(AppLanguage language) {
  return switch (language) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.portuguese => const Locale('pt'),
  };
}

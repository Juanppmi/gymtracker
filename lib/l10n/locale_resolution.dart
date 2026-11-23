import 'package:material_ui/material_ui.dart';

/// Portuguese phone locales use Portuguese. Every other locale uses English.
Locale resolveAppLocale(Locale? deviceLocale, Iterable<Locale> supportedLocales) {
  if (deviceLocale?.languageCode == 'pt') {
    return const Locale('pt');
  }
  return const Locale('en');
}

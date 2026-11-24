import 'package:material_ui/material_ui.dart';

ThemeData buildAppTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B6B4A),
      brightness: brightness,
    ),
  );
}

import 'package:material_ui/material_ui.dart';

const appPurple = Color(0xFF7B2CBF);
const appBlack = Color(0xFF000000);
const appWhite = Color(0xFFFFFFFF);

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final background = dark ? appBlack : appWhite;
  final foreground = dark ? appWhite : appBlack;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: appPurple,
      brightness: brightness,
    ).copyWith(primary: appPurple, surface: background, onSurface: foreground),
    scaffoldBackgroundColor: background,
  );
}

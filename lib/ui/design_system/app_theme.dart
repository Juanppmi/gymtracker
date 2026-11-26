import 'package:material_ui/material_ui.dart';

const appPurple = Color(0xFF7B2CBF);
const appBlack = Color(0xFF000000);
const appWhite = Color(0xFFFFFFFF);

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? appBlack : appWhite;
  final onSurface = dark ? appWhite : appBlack;
  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: appPurple,
      onPrimary: appWhite,
      secondary: appPurple,
      onSecondary: appWhite,
      error: const Color(0xFFFF8A80),
      onError: appBlack,
      surface: surface,
      onSurface: onSurface,
    ),
    scaffoldBackgroundColor: surface,
    canvasColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: onSurface,
      unselectedLabelColor: onSurface,
      indicatorColor: appPurple,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      textStyle: TextStyle(color: onSurface),
    ),
    iconTheme: const IconThemeData(color: appPurple),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: appPurple,
        foregroundColor: appWhite,
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: appPurple,
        foregroundColor: appWhite,
        shape: buttonShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: onSurface),
      floatingLabelStyle: TextStyle(color: onSurface),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: onSurface),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: appPurple, width: 2),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: onSurface),
      bodyMedium: TextStyle(color: onSurface),
      labelLarge: const TextStyle(color: appWhite),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: dark ? const Color(0xFF14001F) : const Color(0xFFF3E9FB),
      selectedColor: appPurple,
      labelStyle: TextStyle(color: onSurface),
      secondaryLabelStyle: const TextStyle(color: appWhite),
      side: const BorderSide(color: appPurple),
      showCheckmark: false,
    ),
    dialogTheme: DialogThemeData(backgroundColor: surface),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface),
  );
}

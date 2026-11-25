import 'package:material_ui/material_ui.dart';

const appPurple = Color(0xFF7B2CBF);
const appBlack = Color(0xFF000000);
const appWhite = Color(0xFFFFFFFF);

ThemeData buildAppTheme(Brightness brightness) {
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
      surface: appBlack,
      onSurface: appWhite,
    ),
    scaffoldBackgroundColor: appBlack,
    canvasColor: appBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBlack,
      foregroundColor: appPurple,
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: appPurple,
      unselectedLabelColor: appPurple,
      indicatorColor: appPurple,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: appBlack,
      textStyle: TextStyle(color: appPurple),
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
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: appPurple),
      floatingLabelStyle: TextStyle(color: appPurple),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appPurple, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: appPurple, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: appPurple, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: appWhite),
      bodyMedium: TextStyle(color: appWhite),
      labelLarge: TextStyle(color: appWhite),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF14001F),
      selectedColor: appPurple,
      labelStyle: TextStyle(color: appWhite),
      secondaryLabelStyle: TextStyle(color: appWhite),
      side: BorderSide(color: appPurple),
      showCheckmark: false,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: appBlack),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: appBlack),
  );
}

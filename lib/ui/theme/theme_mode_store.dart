import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeModeStore {
  ThemeMode read();

  Future<void> write(ThemeMode mode);
}

class MemoryThemeModeStore implements ThemeModeStore {
  ThemeMode _mode = ThemeMode.system;

  @override
  ThemeMode read() => _mode;

  @override
  Future<void> write(ThemeMode mode) async {
    _mode = mode;
  }
}

class SharedPreferencesThemeModeStore implements ThemeModeStore {
  SharedPreferencesThemeModeStore(this._preferences);

  static const key = 'theme_mode';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesThemeModeStore> open() async {
    return SharedPreferencesThemeModeStore(
      await SharedPreferences.getInstance(),
    );
  }

  @override
  ThemeMode read() {
    return switch (_preferences.getString(key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> write(ThemeMode mode) {
    return _preferences.setString(key, mode.name);
  }
}

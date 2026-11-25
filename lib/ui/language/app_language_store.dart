import 'package:gymtracker/ui/language/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppLanguageStore {
  AppLanguage read();

  Future<void> write(AppLanguage language);
}

class MemoryAppLanguageStore implements AppLanguageStore {
  AppLanguage _language = AppLanguage.system;

  @override
  AppLanguage read() => _language;

  @override
  Future<void> write(AppLanguage language) async {
    _language = language;
  }
}

class SharedPreferencesAppLanguageStore implements AppLanguageStore {
  SharedPreferencesAppLanguageStore(this._preferences);

  static const key = 'app_language';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesAppLanguageStore> open() async {
    return SharedPreferencesAppLanguageStore(
      await SharedPreferences.getInstance(),
    );
  }

  @override
  AppLanguage read() {
    return switch (_preferences.getString(key)) {
      'english' => AppLanguage.english,
      'portuguese' => AppLanguage.portuguese,
      _ => AppLanguage.system,
    };
  }

  @override
  Future<void> write(AppLanguage language) {
    return _preferences.setString(key, language.name);
  }
}

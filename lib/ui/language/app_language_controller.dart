import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/ui/language/app_language.dart';
import 'package:gymtracker/ui/language/app_language_store.dart';

final appLanguageStoreProvider = Provider<AppLanguageStore>(
  (ref) => MemoryAppLanguageStore(),
);

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => ref.watch(appLanguageStoreProvider).read();

  Future<void> use(AppLanguage language) async {
    state = language;
    await ref.read(appLanguageStoreProvider).write(language);
  }
}

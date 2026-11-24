import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/ui/theme/theme_mode_store.dart';
import 'package:material_ui/material_ui.dart';

final themeModeStoreProvider = Provider<ThemeModeStore>(
  (ref) => MemoryThemeModeStore(),
);

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(themeModeStoreProvider).read();

  Future<void> use(ThemeMode mode) async {
    state = mode;
    await ref.read(themeModeStoreProvider).write(mode);
  }
}

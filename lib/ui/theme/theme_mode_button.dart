import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/theme/theme_mode_controller.dart';
import 'package:material_ui/material_ui.dart';

class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    return PopupMenuButton<ThemeMode>(
      key: const Key('theme-button'),
      tooltip: l10n.theme,
      icon: const Icon(Icons.brightness_6),
      initialValue: mode,
      onSelected: (selected) {
        unawaited(ref.read(themeModeProvider.notifier).use(selected));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          key: const Key('theme-system'),
          value: ThemeMode.system,
          child: Text(l10n.themeSystem),
        ),
        PopupMenuItem(
          key: const Key('theme-light'),
          value: ThemeMode.light,
          child: Text(l10n.themeLight),
        ),
        PopupMenuItem(
          key: const Key('theme-dark'),
          value: ThemeMode.dark,
          child: Text(l10n.themeDark),
        ),
      ],
    );
  }
}

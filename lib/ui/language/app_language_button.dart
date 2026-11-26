import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/language/app_language.dart';
import 'package:gymtracker/ui/language/app_language_controller.dart';
import 'package:material_ui/material_ui.dart';

class AppLanguageButton extends ConsumerWidget {
  const AppLanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    return PopupMenuButton<AppLanguage>(
      key: const Key('language-button'),
      tooltip: l10n.language,
      icon: const Icon(Icons.language),
      initialValue: language,
      onSelected: (selected) {
        unawaited(ref.read(appLanguageProvider.notifier).use(selected));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          key: const Key('language-system'),
          value: AppLanguage.system,
          child: Text(l10n.languageSystem),
        ),
        PopupMenuItem(
          key: const Key('language-english'),
          value: AppLanguage.english,
          child: Text(l10n.languageEnglish),
        ),
        PopupMenuItem(
          key: const Key('language-portuguese'),
          value: AppLanguage.portuguese,
          child: Text(l10n.languagePortuguese),
        ),
      ],
    );
  }
}

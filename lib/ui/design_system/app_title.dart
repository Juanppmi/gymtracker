import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:material_ui/material_ui.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('app-title'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A148C), appPurple, Color(0xFF12001F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x807B2CBF),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          AppLocalizations.of(context).appTitle,
          style: const TextStyle(color: appWhite, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

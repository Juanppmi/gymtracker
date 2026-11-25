import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:material_ui/material_ui.dart';

class WhiteOutline extends StatelessWidget {
  const WhiteOutline({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: appWhite, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: child,
      ),
    );
  }
}

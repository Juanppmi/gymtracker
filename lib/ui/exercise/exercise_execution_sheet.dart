import 'package:gymtracker/data/exercise_executions.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showExerciseExecution(
  BuildContext context, {
  required String title,
  required String description,
  required String nameEn,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final bottom = MediaQuery.paddingOf(context).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ExerciseImage(nameEn: nameEn),
            const SizedBox(height: 16),
            Text(description),
          ],
        ),
      );
    },
  );
}

class ExerciseImage extends StatelessWidget {
  const ExerciseImage({super.key, required this.nameEn});

  final String nameEn;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      exerciseImagePath(nameEn, 'png'),
      key: const Key('execution-image'),
      height: 220,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          exerciseImagePath(nameEn, 'jpg'),
          height: 220,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(height: 220);
          },
        );
      },
    );
  }
}

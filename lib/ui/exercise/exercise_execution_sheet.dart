import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:gymtracker/data/exercise_executions.dart';
import 'package:gymtracker/ui/design_system/app_theme.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

class ExerciseImage extends StatefulWidget {
  const ExerciseImage({super.key, required this.nameEn});

  final String nameEn;

  @override
  State<ExerciseImage> createState() => _ExerciseImageState();
}

class _ExerciseImageState extends State<ExerciseImage> {
  late final Future<Uint8List?> _bytes = loadExerciseImage(widget.nameEn);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF14001F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appPurple, width: 2),
      ),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: FutureBuilder<Uint8List?>(
          future: _bytes,
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes == null) {
              return const SizedBox.expand();
            }
            return Image.memory(
              bytes,
              key: const Key('execution-image'),
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}

Future<Uint8List?> loadExerciseImage(String nameEn) async {
  for (final extension in ['png', 'jpg']) {
    try {
      final data = await rootBundle.load(exerciseImagePath(nameEn, extension));
      return data.buffer.asUint8List();
    } on FlutterError {
      continue;
    }
  }
  return null;
}

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:gymtracker/data/exercise_executions.dart';
import 'package:gymtracker/ui/design_system/app_theme.dart';
import 'package:material_ui/material_ui.dart';

class ExerciseThumbnail extends StatefulWidget {
  const ExerciseThumbnail({super.key, required this.nameEn});

  final String nameEn;

  @override
  State<ExerciseThumbnail> createState() => _ExerciseThumbnailState();
}

class _ExerciseThumbnailState extends State<ExerciseThumbnail> {
  late final Future<Uint8List?> _bytes = loadExerciseImage(widget.nameEn);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF14001F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appPurple),
      ),
      child: SizedBox(
        width: 96,
        height: 96,
        child: FutureBuilder<Uint8List?>(
          future: _bytes,
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes == null) {
              return const SizedBox.expand();
            }
            return Image.memory(
              bytes,
              key: Key('exercise-image-${widget.nameEn}'),
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

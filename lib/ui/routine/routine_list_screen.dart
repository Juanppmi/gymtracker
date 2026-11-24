import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/db/app_database.dart';
import 'package:gymtracker/l10n/app_localizations.dart';
import 'package:gymtracker/ui/design_system/app_button.dart';
import 'package:gymtracker/ui/design_system/app_text_field.dart';
import 'package:gymtracker/ui/design_system/confirm_dialog.dart';
import 'package:gymtracker/ui/routine/routine_editor_screen.dart';
import 'package:gymtracker/ui/routine/routine_list_notifier.dart';
import 'package:material_ui/material_ui.dart';

class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final routines = ref.watch(routineListProvider);

    return Scaffold(
      key: const Key('routine-list-screen'),
      appBar: AppBar(title: Text(l10n.routineList)),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppButton(
                label: l10n.addRoutine,
                onPressed: () => _createRoutine(context, ref),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Text(l10n.noRoutines)
              else
                for (final routine in items) _RoutineTile(routine: routine),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askForName(context, title: l10n.newRoutineTitle);
    if (name == null || !context.mounted) {
      return;
    }
    await ref.read(routineListProvider.notifier).create(name);
  }
}

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      key: Key('routine-${routine.id}'),
      title: Text(routine.name),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => RoutineEditorScreen(
              routineId: routine.id,
              routineName: routine.name,
            ),
          ),
        );
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _rename(context, ref),
            child: Text(l10n.update),
          ),
          TextButton(
            onPressed: () => _delete(context, ref),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askForName(
      context,
      title: l10n.renameRoutineTitle,
      initialValue: routine.name,
    );
    if (name == null || !context.mounted) {
      return;
    }
    await ref.read(routineListProvider.notifier).rename(routine.id, name);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmAction(
      context,
      title: l10n.deleteRoutineTitle,
      message: l10n.deleteRoutineMessage(routine.name),
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await ref.read(routineListProvider.notifier).delete(routine.id);
  }
}

Future<String?> _askForName(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(title: title, initialValue: initialValue),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.initialValue});

  final String title;
  final String initialValue;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: AppTextField(label: l10n.routineName, controller: _controller),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

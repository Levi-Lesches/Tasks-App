import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/view_models.dart";
import "package:tasks/widgets.dart";

class TaskViewModel extends ViewModel {
  final Task task;
  late final titleEditor = TextEditor(changeTitle);
  late final descriptionEditor = TextEditor(changeDescription);

  TaskViewModel(this.task) {
    titleEditor.addListener(notifyListeners);
    descriptionEditor.addListener(notifyListeners);
  }

  void changeTitle(String value) {
    task.title = value;
    models.tasks.saveTasks();
    notifyListeners();
  }

  Future<void> changeDescription([String? value]) async {
    value ??= descriptionEditor.controller.text;
    task.description = value.trim().nullIfEmpty;
    await models.tasks.saveTasks();
    notifyListeners();
  }
}

class TaskPage extends ReactiveWidget<TaskViewModel> {
  final Task task;
  const TaskPage(this.task);

  @override
  TaskViewModel createModel() => TaskViewModel(task);

  @override
  Widget build(BuildContext context, TaskViewModel model) => Scaffold(
    appBar: AppBar(title: const Text("Edit Task")),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.titleEditor.isEditing)
            CreateTextField(
              editor: model.titleEditor,
              style: context.textTheme.headlineMedium,
            )
          else
            ListTile(
              title: Text(task.title),
              titleTextStyle: context.textTheme.headlineMedium,
              onTap: () => model.titleEditor.startEditing(task.title),
              contentPadding: EdgeInsets.zero,
              trailing: const Icon(Icons.edit),
            ),

          const Divider(),
          const SizedBox(height: 12),

          if (model.descriptionEditor.isEditing)
            TextButton.icon(
              label: const Text("Save"),
              icon: const Icon(Icons.save),
              onPressed: model.changeDescription,
            )
          else
            TextButton.icon(
              label: const Text("Edit description"),
              onPressed: () => model.descriptionEditor.startEditing(task.description),
              icon: const Icon(Icons.edit),
            ),

          const SizedBox(height: 12),

          if (model.descriptionEditor.isEditing) Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter):
                const ActivateIntent(),
              LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
              // ...WidgetsApp.defaultShortcuts,
            },
            child: Actions(
              actions: {
                ActivateIntent: CallbackAction(onInvoke: (_) => model.descriptionEditor.submit()),
                DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => model.descriptionEditor.cancel()),
                // ...WidgetsApp.defaultActions,
              },
              child: TextField(
                controller: model.descriptionEditor.controller,
                decoration: const InputDecoration(
                  hintText: "Description",
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                focusNode: model.descriptionEditor.focusNode,
              ),
            ),
          )
          else
            InkWell(
              onTap: () => model.descriptionEditor.startEditing(task.description),
              child: Text(
                task.description ?? "No Description",
                textAlign: TextAlign.start,
                style: context.textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    ),
  );
}

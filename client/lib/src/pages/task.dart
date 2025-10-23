import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/view_models.dart";
import "package:tasks/widgets.dart";

class TaskViewModel extends ViewModel {
  final Task task;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final descriptionFocus = FocusNode();

  TaskViewModel(this.task) {
    descriptionController.text = task.description ?? "";
  }

  bool isEditingTitle = false;
  bool isEditingDescription = true;

  void onCancelTitle() {
    isEditingTitle = false;
    notifyListeners();
  }

  void changeTitle(String value) {
    task.title = value;
    models.tasks.saveTasks();
    notifyListeners();
  }

  void editTitle() {
    titleController.text = task.title.trim();
    isEditingTitle = true;
    notifyListeners();
  }

  Future<void> changeDescription([String? value]) async {
    value ??= descriptionController.text;
    task.description = value.trim().nullIfEmpty;
    await models.tasks.saveTasks();
    notifyListeners();
    isEditingDescription = false;
    descriptionFocus.unfocus();
  }

  void editDescription() {
    descriptionController.text = task.description ?? "";
    isEditingDescription = true;
    descriptionFocus.requestFocus();
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
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model.isEditingTitle)
                  CreateTextField(
                    onCancel: model.onCancelTitle,
                    onSubmit: model.changeTitle,
                    controller: model.titleController,
                    style: context.textTheme.headlineMedium,
                  )
                else
                  ListTile(
                    title: Text(task.title),
                    titleTextStyle: context.textTheme.headlineMedium,
                    onTap: model.editTitle,
                    contentPadding: EdgeInsets.zero,
                    trailing: const Icon(Icons.edit),
                  ),

                const Divider(),
                const SizedBox(height: 12),

                if (model.isEditingDescription)
                  TextButton.icon(
                    label: const Text("Save"),
                    icon: const Icon(Icons.save),
                    onPressed: model.changeDescription,
                  )
                else
                  TextButton.icon(
                    label: const Text("Edit description"),
                    onPressed: model.editDescription,
                    icon: const Icon(Icons.edit),
                  ),
                const SizedBox(height: 12),


                if (model.isEditingDescription) Shortcuts(
                  shortcuts: {
                    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter):
                      const ActivateIntent(),
                  },
                  child: Actions(
                    actions: {ActivateIntent: CallbackAction(onInvoke: (_) => model.changeDescription())},
                    child: SizedBox(
                      height: 500,
                      child: TextField(
                        controller: model.descriptionController,
                        decoration: const InputDecoration(
                          hintText: "Description",
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                        focusNode: model.descriptionFocus,
                        // style: context.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                )
                else
                  InkWell(
                    onTap: model.editDescription,
                    child: Text(
                      task.description ?? "No Description",
                      textAlign: TextAlign.start,
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

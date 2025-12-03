import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/pages.dart";
import "package:tasks/view_models.dart";
import "package:tasks/widgets.dart";

class TaskTileViewModel extends ViewModel {
  late final editor = TextEditor(onEdit);

  final Task task;
  TaskTileViewModel(this.task) {
    editor.addListener(notifyListeners);
  }

  @override
  void dispose() {
    editor.dispose();
    super.dispose();
  }

  Future<void> changePriority(TaskPriority priority) async {
    task.priority = priority;
    task.modified();
    await models.tasks.saveTasks();
  }

  Future<void> changeStatus(TaskStatus status) async {
    task.status = status;
    task.modified();
    await models.tasks.saveTasks();
  }

  Future<void> onEdit(String value) async {
    if (value.trim().isEmpty) {
      return models.tasks.deleteTask(task);
    } else {
      task.title = value.trim();
      task.modified();
      await models.tasks.saveTasks();
    }
  }

  Future<void> changeDueDate(BuildContext context) async {
    final now = DateTime.now();
    final year = now.add(const Duration(days: 365));
    final result = await showDatePicker(context: context, firstDate: now, lastDate: year);
    if (result == null) return;
    task.dueDate = result;
    task.modified();
    await models.tasks.saveTasks();
  }
}

class TaskTile extends ReactiveWidget<TaskTileViewModel> {
  static double statusWidth(BuildContext context) =>
    context.isMobile ? 48 : 130;

  static double priorityWidth(BuildContext context) =>
    context.isMobile ? 48 : 112;

  static Widget adaptiveChip(BuildContext context, ChipData data) =>
    context.isMobile ? iconChip(data) : desktopChip(data);

  final Task task;
  TaskTile(this.task) : super(key: ValueKey(task));

  @override
  TaskTileViewModel createModel() => TaskTileViewModel(task);

  @override
  Widget build(BuildContext context, TaskTileViewModel model) => Row(
    children: [
      Expanded(
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
          onTap: () => model.editor.startEditing(task.title),
          title: model.editor.isEditing
            ? CreateTextField(
              editor: model.editor,
              hint: "New Task",
            ) : oneLine(task.title),
          subtitle: task.bodyText == null
            ? null : oneLine(task.bodyText!),
          isThreeLine: task.isThreeLine,
          leading: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => models.tasks.deleteTask(task),
          ),
          contentPadding: EdgeInsets.zero,
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => router.pushNamed(
              Routes.task,
              extra: task,
              pathParameters: {"id": task.id.value},
            ),
          ),
        ),
      ),
      SizedBox(
        height: task.bodyText == null ? 40 : 60,
        child: const VerticalDivider(),
      ),
      MenuPicker(
        width: statusWidth(context),
        selectedValue: task.status,
        allValues: TaskStatus.values,
        builder: (value) => adaptiveChip(context, value.toChip()),
        onChanged: model.changeStatus,
      ),
      SizedBox(
        height: task.bodyText == null ? 40 : 60,
        child: const VerticalDivider(),
      ),
      MenuPicker(
        width: priorityWidth(context),
        selectedValue: task.priority,
        allValues: TaskPriority.values,
        builder: (value) => adaptiveChip(context, value.toChip()),
        onChanged: model.changePriority,
      ),
    ],
  );
}

import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/pages.dart";
import "package:tasks/widgets.dart";

import "utils.dart";

class TaskTile extends StatefulWidget {
  final Task task;
  TaskTile(this.task) : super(key: ValueKey(task));

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool isHovering = false;
  late final taskEditor = TextEditor(onEdit);

  Future<void> changePriority(TaskPriority priority) async {
    widget.task.priority = priority;
    await models.tasks.saveTasks();
  }

  Future<void> changeStatus(TaskStatus status) async {
    widget.task.status = status;
    await models.tasks.saveTasks();
  }

  Future<void> onEdit(String value) async {
    if (value.trim().isEmpty) {
      return models.tasks.deleteTask(widget.task);
    } else {
      widget.task.title = value.trim();
      await models.tasks.saveTasks();
    }
  }

  Future<void> changeDueDate() async {
    final now = DateTime.now();
    final year = now.add(const Duration(days: 365));
    final result = await showDatePicker(context: context, firstDate: now, lastDate: year);
    if (result == null) return;
    widget.task.dueDate = result;
    await models.tasks.saveTasks();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (event) => setState(() => isHovering = true),
    onExit: (event) => setState(() => isHovering = false),
    child: Row(
      children: [
        Expanded(
          child: ListTile(
            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            onTap: () => taskEditor.startEditing(widget.task.title),
            title: taskEditor.isEditing
              ? CreateTextField(
                editor: taskEditor,
                hint: "New Task",
              ) : oneLine(widget.task.title),
            subtitle: widget.task.bodyText == null
              ? null : oneLine(widget.task.bodyText!),
            isThreeLine: widget.task.isThreeLine,
            leading: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => models.tasks.deleteTask(widget.task),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => router.pushNamed(
                Routes.task,
                extra: widget.task,
                pathParameters: {"id": widget.task.id.value},
              ),
            ),
          ),
        ),
        SizedBox(
          height: widget.task.bodyText == null ? 40 : 60,
          child: const VerticalDivider(),
        ),
        MenuPicker(
          width: 130,
          selectedValue: widget.task.status,
          allValues: TaskStatus.values,
          builder: (value) => desktopChip(value.toChip()),
          onChanged: changeStatus,
        ),
        SizedBox(
          height: widget.task.bodyText == null ? 40 : 60,
          child: const VerticalDivider(),
        ),
        MenuPicker(
          width: 112,
          selectedValue: widget.task.priority,
          allValues: TaskPriority.values,
          builder: (value) => desktopChip(value.toChip()),
          onChanged: changePriority,
        ),
      ],
    ),
  );
}

import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/pages.dart";
import "package:tasks/widgets.dart";

class TaskTile extends StatefulWidget {
  final Task task;
  TaskTile(this.task) : super(key: ValueKey(task));

  @override
  State<TaskTile> createState() => _TaskTileState();
}

enum _EditState {
  title,
  description,
}

class _TaskTileState extends State<TaskTile> {
  final controller = TextEditingController();
  final focus = FocusNode();
  bool isHovering = false;
  _EditState? editState;
  late final originalCategory = models.tasks.getCategory(widget.task.originalCategoryID);

  Future<void> changePriority(TaskPriority priority) async {
    widget.task.priority = priority;
    await models.tasks.saveTasks();
  }

  Future<void> changeStatus(TaskStatus status) async {
    widget.task.status = status;
    await models.tasks.saveTasks();
  }

  Future<void> onEdit(String value) async {
    switch (editState) {
      case _EditState.title: widget.task.title = value;
      case _EditState.description: widget.task.description = value.nullIfEmpty;
      case null:
    }
    await models.tasks.saveTasks();
  }

  void cancelEdit() {
    focus.unfocus();
    setState(() => editState = null);
  }

  void editTitle() {
    controller.text = widget.task.title;
    setState(() => editState = _EditState.title);
  }

  void editDescription() {
    controller.text = widget.task.description ?? "";
    setState(() => editState = _EditState.description);
  }

  Future<void> changeDueDate() async {
    final now = DateTime.now();
    final year = now.add(const Duration(days: 365));
    final result = await showDatePicker(context: context, firstDate: now, lastDate: year);
    if (result == null) return;
    widget.task.dueDate = result;
    await models.tasks.saveTasks();
  }

  Future<void> restore() => models.tasks.restoreTask(widget.task);

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (event) => setState(() => isHovering = true),
    onExit: (event) => setState(() => isHovering = false),
    child: Row(
      children: [
        Expanded(
          child: ListTile(
            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            onTap: editTitle,
            focusNode: focus,
            title: editState != null
              ? CreateTextField(
                controller: controller,
                onCancel: cancelEdit,
                onSubmit: onEdit,
                hint: switch (editState) {
                  _EditState.title => "New Task",
                  _EditState.description => "Description",
                  null => "",
                },
              ) : Text(widget.task.title),
            subtitle: widget.task.bodyText == null ? null : Text(widget.task.bodyText!),
            isThreeLine: widget.task.isThreeLine,
            leading: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => models.tasks.deleteTask(widget.task),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => router.pushNamed(
            Routes.task,
            extra: widget.task,
            pathParameters: {"id": widget.task.id.value},
          ),
        ),
        SizedBox(
          height: widget.task.bodyText == null ? 40 : 60,
          child: const VerticalDivider(),
        ),
        SizedBox(
          width: 100,
          child: TextButton(
            onPressed: changeDueDate,
            child: widget.task.dueDate == null
              ? const Text("--")
              : Text(formatDate(widget.task.dueDate!)),
          ),
        ),
        SizedBox(
          height: widget.task.bodyText == null ? 40 : 60,
          child: const VerticalDivider(),
        ),
        if (widget.task.categoryID == doneCategory.id)
          if (originalCategory != null) SizedBox(
            width: 130,
            child: Tooltip(
              message: "Restore to ${originalCategory!.title}",
              child: TextButton(
                onPressed: restore,
                child: Text(originalCategory?.title ?? "N/A", maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          )
          else
            const Text("--")
        else
          MenuPicker(
            width: 130,
            selectedValue: widget.task.status,
            allValues: TaskStatus.values,
            builder: propertyChip,
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
          builder: propertyChip,
          onChanged: changePriority,
        ),
      ],
    ),
  );
}

import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/widgets.dart";

class TaskTile extends StatefulWidget {
  final Task task;
  TaskTile(this.task) : super(key: ValueKey(task));

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool isHovering = false;

  Color? getTextColor(Color? backgroundColor) {
    if (backgroundColor == null) return null;
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return switch (brightness) {
      Brightness.dark => Colors.white,
      Brightness.light => Colors.black,
    };
  }

  Widget propertyChip(HasChip property) => Chip(
    label: Text(
      property.toString(),
      style: TextStyle(color: getTextColor(property.color)),
    ),
    avatar: Icon(
      property.icon,
      color: getTextColor(property.color),
    ),
    backgroundColor: property.color,
  );

  Future<void> changePriority(TaskPriority priority) async {
    widget.task.priority = priority;
    await models.tasks.saveTasks();
  }

  Future<void> changeStatus(TaskStatus status) async {
    widget.task.status = status;
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
            visualDensity: const VisualDensity(vertical: -4),
            title: Text(widget.task.title),
            subtitle: widget.task.bodyText == null ? null : Text(widget.task.bodyText!),
            isThreeLine: widget.task.isThreeLine,
            leading: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => models.tasks.deleteTask(widget.task),
            ),
          ),
        ),
        MenuPicker(
          selectedValue: widget.task.status,
          allValues: TaskStatus.values,
          builder: propertyChip,
          onChanged: changeStatus,
        ),
        const SizedBox(width: 8),
        MenuPicker(
          selectedValue: widget.task.priority,
          allValues: TaskPriority.values,
          builder: propertyChip,
          onChanged: changePriority,
        ),
      ],
    ),
  );
}
